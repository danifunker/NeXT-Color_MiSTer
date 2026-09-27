//============================================================================
//  tb_tc_scsi -- self-checking unit test of rtl/tc_scsi.sv + rtl/tc_tdma.sv
//  (Verilator --timing).
//
//  The CPU side is the Rev 3.3 v74 ROM's SCSI/DMA code transliterated
//  routine by routine from rom-dissassembly/Rev_3.3_v74.asm ("HS n" =
//  rom-dissassembly/hardware-summary.md section n): post_scsi_test
//  $01004a2a / post_ext_scsi_test $01004ada (HS 9.5), the $704-path writes
//  (HS 0.3 step 14), scsi_init $0100d9b4, dma_init $0100e8cc, scsi_start
//  $0100dc44, scsi_run_cmd $0100db8e, scsi_intr $0100dd4e and its state
//  table $01012a3c, scsi_phase_dispatch $0100df9e, scsi_msgin_done
//  $0100e11e, scsi_abort $0100e188, sd_open $0100e1ec, sd_find_target
//  $0100e2f8, sd_inquiry $0100e356, sd_read_capacity $0100e40a,
//  sd_request_sense $0100e49a, sd_start_unit_wait_ready $0100e548, sd_read
//  $0100e646, sd_command $0100e750, dma_setup_chain $0100e94a,
//  dma_cleanup $0100ea5a, dma_start $0100eacc, dma_stop $0100eb90.  The
//  register writes, their order and the polling are the ROM's; mem_move
//  (the CPU copying between buffers) works on the DRAM model directly.
//
//  Around the DUTs: a behavioural DRAM (8 MB bank 0 at $04000000, random
//  2..7-clock latency, m_err outside it) that also checks every DMA
//  access lies inside the descriptors dma_start programmed and that DMA
//  writes are sequential longwords of 16-byte lines; an HPS block-device
//  model (hps_io handshake with the late final sd_buff_wr strobe) serving
//  a 2 MB disk image with a per-block pattern on slot/target 1 and the
//  window LBAs the way Main_MiSTer support/next/next_scsi.cpp answers
//  them (INQUIRY, READ CAPACITY, MODE SENSE; length at bytes 510..511).
//
//  Time base: tc_scsi runs with CLK_HZ = 4 MHz here, so its "microsecond"
//  (ESP interrupt delay, select timeout, DMA pacing) is 4 clocks; the
//  CPU's delay_us() uses the same unit.  The CPU's own waits of a second
//  or more (scsi_init's 2 s after the bus reset) are divided by 1000:
//  the ESP answers the bus reset after 500 us, so only simulation time
//  changes, not the register sequence.
//
//  Prints "PASS: ..." or "FAIL: ..." and exits non-zero on failure.
//  Run: bash verilator/unit/run_tb_tc_scsi.sh
//============================================================================
`timescale 1ns/1ps

module tb_tc_scsi;

localparam int CLK_HZ  = 4_000_000;
localparam int US      = CLK_HZ / 1_000_000;   // clocks per tc_scsi microsecond
localparam int POLL_US = 10000;                // scsi_run_cmd: delay_us(10000) per poll

// bench memory map (all in DRAM bank 0)
localparam logic [31:0] DRAM_BASE = 32'h0400_0000;
localparam int          DRAM_WORDS = 1 << 21;              // 8 MB
localparam logic [31:0] SC        = 32'h0400_1000;         // softc (mem_alloc $21e)
localparam logic [31:0] SD        = 32'h0400_2000;         // sd struct (mem_alloc $70)
localparam logic [31:0] SD_BUF    = (SD + 32'h2D) & ~32'hF; // sd's 16-byte aligned buffer
localparam logic [31:0] BOUNCE    = 32'h047F_0000;         // 64 KB below the top, 8 KB aligned
localparam logic [31:0] RDBUF     = 32'h0410_0000;         // boot_fs sector cache
localparam logic [31:0] WRBUF     = 32'h0420_0000;

// TDMA register offsets in the device page (ioMemTabTurbo.c)
localparam logic [16:0] T_CSR   = 17'h00010, T_NEXT = 17'h04010, T_LIMIT = 17'h04014,
                        T_START = 17'h04018, T_STOP = 17'h0401C, T_INIT  = 17'h04210;

localparam int DISK_UNIT   = 1;                 // target/slot of the disk image
localparam int DISK_BLOCKS = 4096;              // 2 MB

//----------------------------------------------------------------------------
// clock, reset, DUTs
//----------------------------------------------------------------------------
logic clk = 1'b0;
always #15 clk = ~clk;                          // ~33 MHz
logic reset = 1'b1;

logic        esp_stb = 0, esp_we = 0;
logic  [5:2] esp_addr = 0;
logic  [3:0] esp_be = 0;
logic [31:0] esp_wdata = 0;
wire  [31:0] esp_rdata;
wire         esp_ack;

logic        dma_stb = 0, dma_we = 0;
logic [16:2] dma_addr = 0;
logic  [3:0] dma_be = 0;
logic [31:0] dma_wdata = 0;
wire  [31:0] dma_rdata;
wire         dma_ack;

wire         m_req, m_we;
wire  [31:2] m_addr;
wire   [3:0] m_be;
wire  [31:0] m_wdata;
logic        m_ack = 0, m_err = 0;
logic [31:0] m_rdata = 0;

wire         ch_req, ch_we, ch_eval, ch_ack, ch_err;
wire  [31:0] ch_wdata, ch_rdata;
wire         ch_enable, ch_dev2m, ch_room, ch_at_limit, ch_bufreset;
wire   [3:0] ch_bufofs;

// the sound-out channel's client (tc_kms in the machine)
logic        so_req = 0;
wire         so_ack, so_avail;
wire  [31:0] so_rdata;
int          so_words = 0;
logic [31:0] so_got [$];
always @(posedge clk) if (so_ack) begin
	so_words++;
	so_got.push_back(so_rdata);
end

// the DSP channel's client (tc_dsp in the machine): one byte per request
logic        dd_req = 0, dd_we = 0;
logic  [7:0] dd_wdata = 0;
wire         dd_ack, dd_avail, dd_blkend;
wire   [7:0] dd_rdata;
int          dd_bytes = 0, dd_blkends = 0;
logic  [7:0] dd_got [$];
always @(posedge clk) begin
	if (dd_ack) begin
		dd_bytes++;
		dd_got.push_back(dd_rdata);
	end
	if (dd_blkend) dd_blkends++;
end

wire         int_scsi, int_scsi_dma;
wire         int_snd_out_dma, int_snd_in_dma, int_printer_dma, int_dsp_dma,
             int_en_tx_dma, int_en_rx_dma;

logic  [5:0] img_mounted = 0;
logic [63:0] img_size = 0;
wire   [2:0] sd_unit;
wire  [31:0] sd_lba;
wire         sd_rd, sd_wr;
logic        sd_ack = 0;
logic [13:0] sd_buff_addr = 0;
logic  [7:0] sd_buff_dout = 0;
wire   [7:0] sd_buff_din;
logic        sd_buff_wr = 0;
wire         sd_busy, cd_fwd_stb;

tc_scsi #(.CLK_HZ(CLK_HZ)) scsi (
	.clk(clk), .reset(reset),
	.stb(esp_stb), .we(esp_we), .addr(esp_addr), .be(esp_be), .wdata(esp_wdata),
	.rdata(esp_rdata), .ack(esp_ack),
	.ch_req(ch_req), .ch_we(ch_we), .ch_wdata(ch_wdata), .ch_eval(ch_eval),
	.ch_ack(ch_ack), .ch_rdata(ch_rdata), .ch_err(ch_err),
	.ch_enable(ch_enable), .ch_dev2m(ch_dev2m), .ch_room(ch_room), .ch_at_limit(ch_at_limit),
	.ch_bufreset(ch_bufreset), .ch_bufofs(ch_bufofs),
	.int_scsi(int_scsi),
	.img_mounted(img_mounted), .img_readonly(1'b0), .img_size(img_size),
	.sd_unit(sd_unit), .sd_lba(sd_lba), .sd_rd(sd_rd), .sd_wr(sd_wr), .sd_ack_in(sd_ack),
	.sd_buff_addr(sd_buff_addr), .sd_buff_dout(sd_buff_dout), .sd_buff_din(sd_buff_din),
	.sd_buff_wr(sd_buff_wr), .sd_busy(sd_busy), .sd_hold(1'b0), .cd_fwd_stb(cd_fwd_stb)
);

tc_tdma dma (
	.clk(clk), .reset(reset),
	.stb(dma_stb), .we(dma_we), .addr(dma_addr), .be(dma_be), .wdata(dma_wdata),
	.rdata(dma_rdata), .ack(dma_ack),
	.m_req(m_req), .m_we(m_we), .m_addr(m_addr), .m_be(m_be), .m_wdata(m_wdata),
	.m_ack(m_ack), .m_rdata(m_rdata), .m_err(m_err),
	.sc_req(ch_req), .sc_we(ch_we), .sc_wdata(ch_wdata), .sc_eval(ch_eval),
	.sc_ack(ch_ack), .sc_rdata(ch_rdata), .sc_err(ch_err),
	.sc_enable(ch_enable), .sc_dev2m(ch_dev2m), .sc_room(ch_room), .sc_at_limit(ch_at_limit),
	.sc_bufreset(ch_bufreset), .sc_bufofs(ch_bufofs),
	.et_req(1'b0), .et_ack(), .et_rdata(), .et_n(), .et_err(), .et_enable(), .et_room(),
	.et_done(1'b0),
	.er_req(1'b0), .er_wdata(32'd0), .er_n(3'd0), .er_ack(), .er_err(), .er_enable(),
	.er_room(), .er_eof(1'b0), .er_full(1'b0), .er_nibble(),
	.so_req(so_req), .so_ack(so_ack), .so_rdata(so_rdata), .so_avail(so_avail),
	.dd_req(dd_req), .dd_we(dd_we), .dd_wdata(dd_wdata), .dd_ack(dd_ack),
	.dd_rdata(dd_rdata), .dd_avail(dd_avail), .dd_blkend(dd_blkend),
	.int_scsi_dma(int_scsi_dma), .int_snd_out_dma(int_snd_out_dma),
	.int_snd_in_dma(int_snd_in_dma), .int_printer_dma(int_printer_dma),
	.int_dsp_dma(int_dsp_dma), .int_en_tx_dma(int_en_tx_dma), .int_en_rx_dma(int_en_rx_dma)
);

//----------------------------------------------------------------------------
// checking
//----------------------------------------------------------------------------
int errors = 0, checks = 0;

task automatic check(input bit cond, input string what);
	checks++;
	if (!cond) begin
		errors++;
		$display("[%0t] CHECK FAILED: %s", $time, what);
	end
endtask

//----------------------------------------------------------------------------
// DRAM model: bank 0, 8 MB; m_err outside it.  Every DMA access is checked
// against the windows dma_start programmed (win_*), and DMA writes must be
// sequential longwords filling 16-byte lines.
//----------------------------------------------------------------------------
logic [31:0] dram [0:DRAM_WORDS-1];
logic [31:0] win_lo0 = 0, win_hi0 = 0, win_lo1 = 0, win_hi1 = 0;
logic        win_any = 0;           // a DMA access outside a window is an error
int          dma_wr_words = 0, dma_rd_words = 0, dma_errs = 0;
logic [31:0] last_wr = 0;
logic        mem_busy = 0;
int          mem_lat = 0;
logic [15:0] lfsr = 16'hACE1;

function automatic bit in_dram(input logic [31:0] a);
	return a >= DRAM_BASE && a < DRAM_BASE + DRAM_WORDS * 4;
endfunction

always @(posedge clk) begin
	m_ack <= 1'b0;
	m_err <= 1'b0;
	lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
	if (!mem_busy) begin
		// a new access (not the cycle that acknowledges the previous one)
		if (m_req && !m_ack && !m_err) begin
			mem_busy <= 1'b1;
			mem_lat  <= 2 + int'(lfsr[2:0]) % 6;
		end
	end
	else if (mem_lat != 0) mem_lat <= mem_lat - 1;
	else begin
		logic [31:0] a;
		a = {m_addr, 2'b00};
		mem_busy <= 1'b0;
		if (win_any && !((a >= win_lo0 && a < win_hi0) || (a >= win_lo1 && a < win_hi1)))
			check(0, $sformatf("DMA %s at %08x outside the programmed windows", m_we ? "write" : "read", a));
		if (!in_dram(a)) begin
			m_err <= 1'b1;
			dma_errs++;
		end
		else begin
			if (m_we) begin
				if (m_be[3]) dram[(a - DRAM_BASE) >> 2][31:24] = m_wdata[31:24];
				if (m_be[2]) dram[(a - DRAM_BASE) >> 2][23:16] = m_wdata[23:16];
				if (m_be[1]) dram[(a - DRAM_BASE) >> 2][15:8]  = m_wdata[15:8];
				if (m_be[0]) dram[(a - DRAM_BASE) >> 2][7:0]   = m_wdata[7:0];
				if (a[3:2] != 2'd0)
					check(a == last_wr + 4, $sformatf("DMA write %08x does not continue the line after %08x", a, last_wr));
				last_wr = a;
				dma_wr_words++;
			end
			else begin
				m_rdata <= dram[(a - DRAM_BASE) >> 2];
				dma_rd_words++;
			end
			m_ack <= 1'b1;
		end
	end
end

// CPU-side memory access (the ROM's mem_move and buffer reads)
function automatic logic [7:0] mem_rb(input logic [31:0] a);
	logic [31:0] w;
	w = dram[(a - DRAM_BASE) >> 2];
	return w[31 - 8 * a[1:0] -: 8];
endfunction

task automatic mem_wb(input logic [31:0] a, input logic [7:0] v);
	dram[(a - DRAM_BASE) >> 2][31 - 8 * a[1:0] -: 8] = v;
endtask

function automatic logic [31:0] mem_rl(input logic [31:0] a);
	return {mem_rb(a), mem_rb(a + 1), mem_rb(a + 2), mem_rb(a + 3)};
endfunction

task automatic mem_move(input logic [31:0] src, input logic [31:0] dst, input int n);
	for (int i = 0; i < n; i++) mem_wb(dst + i, mem_rb(src + i));
endtask

//----------------------------------------------------------------------------
// HPS model: the disk image and Main_MiSTer support/next/next_scsi.cpp
//----------------------------------------------------------------------------
logic  [7:0] disk [0:DISK_BLOCKS*512-1];
logic [63:0] unit_size [0:3];           // next_mount_hook: bytes per unit
logic  [7:0] win_buf [0:511];
int          sd_reads = 0, sd_writes = 0, win_reads = 0;

function automatic logic [7:0] pat(input int b, input int k);
	logic [31:0] v;
	v = b * 32'd2654435761 + k * 32'd40503 + (b >> 4);
	return v[23:16] ^ v[7:0];
endfunction

function automatic int unit_blocks(input int unit);
	return (unit < 4) ? int'(unit_size[unit] >> 9) : 0;
endfunction

function automatic bit unit_is_cd(input int unit);
	return unit == 3;                   // NEXT_CDROM_SLOT
endfunction

// resp_inquiry
function automatic int resp_inquiry(input int unit, input bit lun_nz);
	string vend = "Previous", prod;
	bit cd = unit_is_cd(unit);
	prod = cd ? "CD-ROM          " : "HDD             ";
	win_buf[0] = lun_nz ? 8'h7F : cd ? 8'h05 : 8'h00;
	win_buf[1] = cd ? 8'h80 : 8'h00;
	win_buf[2] = 8'h01;
	win_buf[3] = 8'h01;
	win_buf[4] = 8'h31;
	win_buf[7] = 8'h1C;
	for (int i = 0; i < 8; i++)  win_buf[8 + i]  = vend[i];
	for (int i = 0; i < 16; i++) win_buf[16 + i] = prod[i];
	win_buf[32] = cd ? "1" : "B";
	return 54;
endfunction

// resp_capacity
function automatic int resp_capacity(input int unit);
	logic [31:0] last;
	last = unit_blocks(unit) - 1;
	win_buf[0] = last[31:24]; win_buf[1] = last[23:16];
	win_buf[2] = last[15:8];  win_buf[3] = last[7:0];
	win_buf[6] = 8'h02;
	return 8;
endfunction

// page_bytes (disk pages; 0x0E / 0x2A are CD-only and not modelled here)
function automatic int page_bytes(input int unit, input logic [7:0] page, input int o);
	logic [31:0] blocks, cyl;
	blocks = unit_blocks(unit);
	cyl = (blocks >> 7) + ((blocks & 127) != 0 ? 1 : 0);
	case (page)
	8'h00: begin win_buf[o+1] = 8'h02; win_buf[o+2] = 8'h80; return 4; end
	8'h01: begin win_buf[o] = 8'h01; win_buf[o+1] = 8'h02; win_buf[o+3] = 8'h1B; return 4; end
	8'h03: begin win_buf[o] = 8'h03; win_buf[o+1] = 8'h16; win_buf[o+11] = 8'd32; win_buf[o+12] = 8'h02;
	             win_buf[o+15] = 8'h01; win_buf[o+20] = 8'h80; return 24; end
	8'h04: begin win_buf[o] = 8'h04; win_buf[o+1] = 8'h12;
	             win_buf[o+2] = cyl[23:16]; win_buf[o+3] = cyl[15:8]; win_buf[o+4] = cyl[7:0];
	             win_buf[o+5] = 8'd4; return 20; end
	default: return 0;
	endcase
endfunction

// resp_mode_sense
function automatic int resp_mode_sense(input int unit, input bit dbd, input logic [7:0] cdb2);
	logic [7:0] page;
	logic [1:0] pc;
	logic [31:0] blocks;
	int len, n;
	page = cdb2 & 8'h3F;
	pc = cdb2[7:6];
	blocks = unit_blocks(unit);
	len = dbd ? 4 : 12;
	if (pc == 1 || pc == 3) return 0;
	if (page == 8'h3F) begin
		len += page_bytes(unit, 8'h01, len);
		len += page_bytes(unit, 8'h03, len);
		len += page_bytes(unit, 8'h04, len);
		len += page_bytes(unit, 8'h00, len);
	end
	else begin
		n = page_bytes(unit, page, len);
		if (n == 0) return 0;
		len += n;
	end
	win_buf[0] = 8'(len - 1);
	win_buf[2] = unit_is_cd(unit) ? 8'h80 : 8'h00;
	win_buf[3] = 8'h08;
	if (!dbd) begin
		win_buf[5] = blocks[23:16]; win_buf[6] = blocks[15:8]; win_buf[7] = blocks[7:0];
		win_buf[10] = 8'h02;
	end
	return len;
endfunction

// next_scsi_window_fill
task automatic host_fill(input logic [31:0] lba);
	int unit, fl, len;
	logic [7:0] op, a;
	for (int i = 0; i < 512; i++) win_buf[i] = 8'h00;
	unit = int'(lba[23:20]);
	fl   = int'(lba[19:16]);
	op   = lba[15:8];
	a    = lba[7:0];
	len  = 0;
	if (lba >= 32'h7E00_0000 && unit < 4) begin
		case (op)
		8'h12: len = resp_inquiry(unit, fl[3]);
		8'h25: len = resp_capacity(unit);
		8'h1A: len = resp_mode_sense(unit, fl[0], a);
		default: len = 0;
		endcase
	end
	win_buf[510] = 8'(len >> 8);
	win_buf[511] = 8'(len);
endtask

// the mount hook
always @(negedge clk)
	for (int u = 0; u < 4; u++) if (img_mounted[u]) unit_size[u] = img_size;

// hps_io block handshake: one byte every other clock; like hps_io, the
// final sd_buff_wr strobe of a read arrives after sd_ack has dropped.
typedef enum logic [1:0] {H_IDLE, H_RD, H_WR} hst_t;
hst_t        hst = H_IDLE;
logic        hph = 0, hwin = 0;
logic [31:0] hlba = 0;
logic  [2:0] hunit = 0;

always @(posedge clk) begin
	sd_buff_wr <= 1'b0;
	case (hst)
	H_IDLE: begin
		if (sd_rd || sd_wr) begin
			hlba  <= sd_lba;
			hunit <= sd_unit;
			hwin  <= (sd_lba >= 32'h7C00_0000);
			hph   <= 1'b0;
			sd_ack <= 1'b1;
			sd_buff_addr <= 14'd0;
			if (sd_lba >= 32'h7C00_0000) begin
				check(sd_unit == 3'd3, "a window request must use slot 3");
				if (sd_rd) begin host_fill(sd_lba); win_reads++; end
			end
			else begin
				check(int'(sd_unit) == DISK_UNIT, $sformatf("sector access on unit %0d", sd_unit));
				check(sd_lba < DISK_BLOCKS, "sector LBA beyond the image");
				if (sd_rd) sd_reads++; else sd_writes++;
			end
			hst <= sd_rd ? H_RD : H_WR;
		end
	end
	H_RD: begin
		if (!hph) begin
			sd_buff_dout <= hwin ? win_buf[sd_buff_addr[8:0]]
			                     : disk[{hlba[11:0], sd_buff_addr[8:0]}];
			sd_buff_wr <= 1'b1;
			hph <= 1'b1;
			if (sd_buff_addr[8:0] == 9'd511) begin
				sd_ack <= 1'b0;
				hst <= H_IDLE;
			end
		end
		else begin
			hph <= 1'b0;
			sd_buff_addr <= sd_buff_addr + 14'd1;
		end
	end
	H_WR: begin
		// registered buffer read: sample one clock after the address
		if (!hph) hph <= 1'b1;
		else begin
			hph <= 1'b0;
			if (!hwin) disk[{hlba[11:0], sd_buff_addr[8:0]}] = sd_buff_din;
			if (sd_buff_addr[8:0] == 9'd511) begin
				sd_ack <= 1'b0;
				hst <= H_IDLE;
			end
			else sd_buff_addr <= sd_buff_addr + 14'd1;
		end
	end
	default: hst <= H_IDLE;
	endcase
end

//----------------------------------------------------------------------------
// device port accesses (tc_machine contract).  One server process drives
// both ports; the ROM routines post a request and wait for it, so the
// simulator does not inline a copy of the handshake into every call site
// of every caller.
//----------------------------------------------------------------------------
bit          bus_req = 0;              // level: a request is pending
bit          bus_esp, bus_w;
logic [16:0] bus_off;
logic  [3:0] bus_be;
logic [31:0] bus_wd, bus_rd;
int          acc_timeout;

initial forever begin
	wait (bus_req);
	@(posedge clk);
	if (bus_esp) begin
		esp_stb   <= 1'b1;
		esp_we    <= bus_w;
		esp_addr  <= bus_off[5:2];
		esp_be    <= bus_be;
		esp_wdata <= bus_wd;
	end
	else begin
		dma_stb   <= 1'b1;
		dma_we    <= bus_w;
		dma_addr  <= bus_off[16:2];
		dma_be    <= bus_be;
		dma_wdata <= bus_wd;
	end
	@(posedge clk);
	esp_stb <= 1'b0;
	dma_stb <= 1'b0;
	acc_timeout = 0;
	while (!(bus_esp ? esp_ack : dma_ack) && acc_timeout < 16) begin
		@(posedge clk);
		acc_timeout = acc_timeout + 1;
	end
	check(bus_esp ? esp_ack : dma_ack, bus_esp ? "ESP port: no ack" : "TDMA port: no ack");
	bus_rd = bus_esp ? esp_rdata : dma_rdata;
	bus_req = 0;
end

task automatic esp_acc(input bit w, input logic [5:0] off, input logic [7:0] v, output logic [7:0] r);
	bus_esp = 1'b1;
	bus_w   = w;
	bus_off = {11'd0, off};
	bus_be  = 4'b1000 >> off[1:0];
	bus_wd  = {4{v}};
	bus_req = 1'b1;
	wait (!bus_req);
	r = bus_rd[31 - 8 * off[1:0] -: 8];
endtask

task automatic esp_w(input logic [5:0] off, input logic [7:0] v);
	logic [7:0] r;
	esp_acc(1'b1, off, v, r);
endtask

task automatic esp_r(input logic [5:0] off, output logic [7:0] v);
	esp_acc(1'b0, off, 8'h00, v);
endtask

task automatic tdma_acc(input bit w, input logic [16:0] off, input logic [3:0] be,
                        input logic [31:0] v, output logic [31:0] r);
	bus_esp = 1'b0;
	bus_w   = w;
	bus_off = off;
	bus_be  = be;
	bus_wd  = v;
	bus_req = 1'b1;
	wait (!bus_req);
	r = bus_rd;
endtask

task automatic tdma_w(input logic [16:0] off, input logic [31:0] v);
	logic [31:0] r;
	tdma_acc(1'b1, off, 4'hF, v, r);
endtask

task automatic tdma_r(input logic [16:0] off, output logic [31:0] v);
	tdma_acc(1'b0, off, 4'hF, 32'd0, v);
endtask

task automatic delay_us(input int n);
	int d;
	d = (n >= 1000000) ? n / 1000 : n;
	repeat (d * US) @(posedge clk);
endtask

//----------------------------------------------------------------------------
// the ROM's SCSI driver state: softc (sc+...) and the sd struct (sd+...)
//----------------------------------------------------------------------------
int          sc_state;                 // $20c
bit          sc_cur;                   // $210 != 0
logic [31:0] sc_addr, sc_resid;        // $214, $218
logic  [7:0] sc_stat, sc_seq, sc_ist;  // $20d, $20e, $20f
logic  [7:0] sc_msg;                   // $21c
logic [31:0] sc_flags;                 // $2c
logic [31:0] sc_dir;                   // $20 (dma_start direction)
logic [31:0] sc_csr_save, sc_next_save;// $24, $28 (dma_stop)
logic [31:0] sc_tail_dst, sc_tail_n;   // $30, $34
logic [31:0] sc_scratch, sc_bounce;    // $38, $e4
logic [31:0] sc_caller, sc_len;        // $e0, $e8
logic [31:0] dsc_start [0:1];          // the chain at sc+$f4
logic [31:0] dsc_limit [0:1];
bit          dsc_two;

logic  [7:0] dv_target, dv_lun, dv_dir;    // sd+0, +1, +2
logic  [7:0] dv_cdb [0:11];                // sd+4..
logic [31:0] dv_addr, dv_len, dv_resid;    // sd+$10, +$14, +$18
logic  [7:0] dv_status, dv_state;          // sd+$1c, +$1d

int aborts = 0, timeouts = 0, interrupts = 0;
bit expect_chained = 0;                // a read that ends on its first window
bit ack_running = 0;                   // acknowledge COMPLETE like a driver would
logic [31:0] csr_sticky = 32'd0;       // BUSEXC once a bus error happened (dma.c:1160)
logic [31:0] bd_blksize, bd_lastlba;

task automatic cdb_clear();
	for (int i = 0; i < 12; i++) dv_cdb[i] = 8'h00;
endtask

// dma_init $0100e8cc
task automatic dma_init();
	sc_flags = {sc_flags[31:16], sc_flags[15:0] & 16'h8FFF};
	tdma_w(T_CSR, 32'h0010_0000);
	sc_scratch = (SC + 32'h4F) & ~32'hF;
	sc_bounce  = BOUNCE;
endtask

// scsi_init $0100d9b4 (runs in its own process, see scsi_init())
task automatic scsi_init_body();
	logic [7:0] b;
	// $02114108 &= ~$40 deselects the floppy (82077 control, not this DUT)
	sc_state = 0;                       // clr.b $20c(a4)
	sc_flags = 32'd6;                   // $2c = 6
	dma_init();
	esp_w(6'h20, 8'h22); delay_us(10);
	esp_w(6'h20, 8'h20); delay_us(10);
	esp_w(6'h08, 8'h57);
	esp_w(6'h09, 8'h05);                // Turbo: 25 MHz ESP clock -> CCF 5
	esp_w(6'h05, 8'h99);                // select timeout
	esp_w(6'h07, 8'h00);
	esp_w(6'h06, 8'h05);
	esp_w(6'h03, 8'h03);                // SCSI bus reset
	delay_us(2000000);
	esp_r(6'h05, b); sc_ist = b;
	esp_r(6'h05, b); sc_ist = b;
	esp_w(6'h08, 8'h17);
endtask

bit init_req = 0;
initial forever begin
	wait (init_req);
	scsi_init_body();
	init_req = 0;
end

task automatic scsi_init();
	init_req = 1'b1;
	wait (!init_req);
endtask

// dma_stop $0100eb90
task automatic dma_stop();
	logic [31:0] v;
	tdma_r(T_CSR, v);
	sc_csr_save = v & 32'h1B00_0000;
	tdma_w(T_CSR, 32'h0010_0000);
	tdma_r(T_NEXT, sc_next_save);
	sc_flags = {sc_flags[31:16], sc_flags[15:0] & 16'h8FFF};
	win_any = 1'b1;                     // no DMA may move after dma_stop
	win_lo0 = 0; win_hi0 = 0; win_lo1 = 0; win_hi1 = 0;
endtask

// dma_setup_chain $0100e94a
task automatic dma_setup_chain(input logic [31:0] addr, input logic [31:0] len, input logic [31:0] dir);
	logic [31:0] d0;
	sc_caller = addr;
	sc_len = len;
	if (dir == 0) mem_move(addr, sc_bounce, int'(len));
	dsc_start[0] = sc_bounce;
	dsc_limit[0] = sc_bounce + len;
	dsc_two = 0;
	sc_tail_n = 0;
	if (dir == 32'h0004_0000) begin
		d0 = dsc_limit[0] - dsc_start[0];
		if (!($signed(d0) > 127)) begin
			// short transfer: all of it through the scratch buffer
			sc_tail_n   = d0;
			sc_tail_dst = dsc_start[0];
			dsc_start[0] = sc_scratch;
			dsc_limit[0] = (sc_scratch + d0 + 32'd15) & ~32'hF;
		end
		else begin
			// the last partial burst lands in the scratch buffer
			sc_tail_dst  = dsc_limit[0] & ~32'hF;
			sc_tail_n    = dsc_limit[0] - sc_tail_dst;
			dsc_limit[0] = sc_tail_dst;
			dsc_two = 1;
			dsc_start[1] = sc_scratch;
			dsc_limit[1] = sc_scratch + 32'h20;
		end
	end
	else begin
		dsc_limit[0] = (dsc_limit[0] + 32'd15) & ~32'hF;
		dsc_two = 1;
		dsc_start[1] = sc_scratch;
		dsc_limit[1] = sc_scratch + 32'h30;
	end
endtask

// dma_start $0100eacc
task automatic dma_start(input logic [31:0] dir);
	check(dsc_start[0][3:0] == 0 && (!dsc_two || dsc_start[1][3:0] == 0),
	      "dma_start: bad DMA buffer alignment");
	sc_dir = dir;
	win_any = 1'b1;
	win_lo0 = dsc_start[0]; win_hi0 = dsc_limit[0];
	win_lo1 = dsc_two ? dsc_start[1] : 0;
	win_hi1 = dsc_two ? dsc_limit[1] : 0;
	tdma_w(T_CSR, dir | 32'h0010_0000 | 32'h0080_0000);    // RESET | BUFRESET
	tdma_w(T_NEXT,  dsc_start[0]);
	tdma_w(T_LIMIT, dsc_limit[0]);
	if (dsc_two) begin
		tdma_w(T_START, dsc_start[1]);
		tdma_w(T_STOP,  dsc_limit[1]);
		tdma_w(T_CSR, dir | 32'h0003_0000);                 // SETENABLE | SETSUPDATE
		sc_flags |= 32'h2000;
	end
	else tdma_w(T_CSR, dir | 32'h0001_0000);                // SETENABLE
	sc_flags |= 32'h1000;
endtask

// dma_cleanup $0100ea5a
task automatic dma_cleanup(input logic [31:0] resid);
	dma_stop();
	if ($signed(resid) < 0) $display("dma_cleanup: negative resid");
	if ($signed(resid) < $signed(sc_tail_n))
		mem_move(sc_scratch, sc_tail_dst, int'(sc_tail_n - resid));
	if (sc_dir == 32'h0004_0000) mem_move(sc_bounce, sc_caller, int'(sc_len));
endtask

// scsi_abort $0100e188
task automatic scsi_abort(input string msg);
	aborts++;
	$display("[%0t] sc: %s", $time, msg);
	if (sc_state == 4) begin
		esp_w(6'h20, 8'h20);
		dma_stop();
	end
	sc_state = 0;
	if (sc_cur) begin
		if (dv_state == 0) dv_state = 3;
		sc_cur = 0;
	end
	scsi_init();
endtask

// scsi_start $0100dc44
task automatic scsi_start();
	int len;
	logic [7:0] ctl;
	case (dv_cdb[0] & 8'hE0)
	8'h00, 8'hC0:        begin len = 6;  ctl = dv_cdb[5];  end
	8'h20, 8'h40, 8'hE0: begin len = 10; ctl = dv_cdb[9];  end
	8'hA0:               begin len = 12; ctl = dv_cdb[11]; end
	default:             begin len = -1; ctl = 8'h00;      end
	endcase
	dv_state = 0;
	dv_resid = dv_len;
	dv_status = 0;
	if (len < 0 || ctl != 0) begin dv_state = 4; return; end
	if (sc_state != 0) scsi_abort("scstart: bad state");
	sc_cur = 1;
	sc_addr = dv_addr;
	sc_resid = dv_len;
	sc_state = 1;
	esp_w(6'h03, 8'h01);                        // flush FIFO
	delay_us(10);
	esp_w(6'h04, dv_target);
	esp_w(6'h02, 8'h80 | (dv_lun & 8'h07));     // IDENTIFY
	for (int i = 0; i < len; i++) esp_w(6'h02, dv_cdb[i]);
	esp_w(6'h03, 8'h42);                        // SELECT WITH ATN
endtask

// scsi_msgin_done $0100e11e
task automatic scsi_msgin_done();
	if (!sc_cur) begin scsi_abort("scmsgin: no current sd"); return; end
	if (sc_msg != 0) begin
		$display("SCSI unexpected msg:%0d", sc_msg);
		scsi_abort("Unexpected msg");
		return;
	end
	if (!sc_ist[3]) begin scsi_abort("scmsgin: no FUNCCMPLT"); return; end
	sc_state = 5;
	esp_w(6'h03, 8'h12);                        // MESSAGE ACCEPTED
endtask

// scsi_phase_dispatch $0100df9e
task automatic scsi_phase_dispatch();
	esp_w(6'h03, 8'h01);                        // flush FIFO
	case (sc_stat & 8'h07)
	8'd0: begin                                 // DATA OUT
		if (dv_dir != 0) begin scsi_abort("SCSI bad i/o direction"); return; end
		if (sc_resid == 0) begin
			sc_state = 6;
			esp_w(6'h00, 8'h00); esp_w(6'h01, 8'h01); esp_w(6'h02, 8'h00);
			esp_w(6'h03, 8'h00); esp_w(6'h03, 8'h98);
		end
		else begin
			sc_state = 4;
			dma_setup_chain(sc_addr, sc_resid, 32'd0);
			dma_start(32'd0);
			esp_w(6'h00, sc_resid[7:0]);
			esp_w(6'h01, sc_resid[15:8]);
			esp_w(6'h03, 8'h00);
			esp_w(6'h03, 8'h90);                // DMA transfer information
			esp_w(6'h20, 8'h30);
		end
	end
	8'd1: begin                                 // DATA IN
		if (dv_dir == 0) begin scsi_abort("SCSI bad i/o direction"); return; end
		if (sc_resid == 0) begin
			sc_state = 6;
			esp_w(6'h00, 8'h00); esp_w(6'h01, 8'h01);
			esp_w(6'h03, 8'h00); esp_w(6'h03, 8'h98);   // DMA transfer pad
		end
		else begin
			sc_state = 4;
			dma_setup_chain(sc_addr, sc_resid, 32'h0004_0000);
			dma_start(32'h0004_0000);
			esp_w(6'h00, sc_resid[7:0]);
			esp_w(6'h01, sc_resid[15:8]);
			esp_w(6'h03, 8'h00);
			esp_w(6'h03, 8'h90);
			esp_w(6'h20, 8'h38);
		end
	end
	8'd3: begin                                 // STATUS
		sc_state = 3;
		esp_w(6'h03, 8'h11);                    // ICCS
	end
	8'd7: begin                                 // MESSAGE IN
		sc_state = 7;
		esp_w(6'h03, 8'h00);
		esp_w(6'h03, 8'h10);
	end
	8'd6: scsi_abort("SCSI msgout phase");
	default: scsi_abort("SCSI command phase");
	endcase
endtask

// scsi_intr $0100dd4e
task automatic scsi_intr();
	logic [7:0] b, hi, lo;
	logic [31:0] old;
	interrupts++;
	if (sc_state == 4 && expect_chained) begin
		// the transfer ended on the first window: the channel already runs
		// on Start/Stop (the scratch window) with COMPLETE set
		check(dma.c_en[0] && dma.c_cmp[0] && !dma.c_sup[0] && int_scsi_dma,
		      "at the ESP interrupt the chain has moved to Start/Stop with COMPLETE");
		if (ack_running) begin
			logic [31:0] v;
			tdma_w(T_CSR, 32'h000C_0000);          // DEV2M | CLRCOMPLETE
			tdma_r(T_CSR, v);
			check(v == 32'h0100_0000, $sformatf("CLRCOMPLETE on a running channel: CSR %08x", v));
			check(!int_scsi_dma, "CLRCOMPLETE releases INT_SCSI_DMA");
		end
	end
	if (sc_state == 4) begin
		delay_us(20);
		if (dv_dir != 0) begin
			for (int i = 0; i <= 3; i++) begin       // flush the channel buffer
				esp_w(6'h20, 8'h3C); delay_us(5);
				esp_w(6'h20, 8'h38); delay_us(5);
			end
			delay_us(20);
		end
		esp_w(6'h20, 8'h20);
	end
	esp_r(6'h04, sc_stat);
	esp_r(6'h06, sc_seq);
	esp_r(6'h05, sc_ist);
	check(sc_ist != 8'h00, "an ESP interrupt with no cause");
	if (sc_ist[7]) begin
		for (int i = 0; i <= 9; i++) begin
			delay_us(1000000);
			esp_r(6'h05, sc_ist);
			if (!sc_ist[7]) return;
		end
		esp_w(6'h08, 8'h57);
		dv_state = 5;
		return;
	end
	if (sc_stat[6] || sc_ist[6]) begin scsi_abort("software error"); return; end
	if (sc_stat[5]) begin scsi_abort("parity error"); return; end
	case (sc_state)
	1: begin                                    // selected
		if (sc_ist[5]) begin
			timeouts++;
			dv_state = 1;
			sc_state = 0;
			sc_cur = 0;
			return;
		end
		if (((sc_seq & 7) == 4 || (sc_seq & 7) == 2) && sc_ist == 8'h18) sc_state = 2;
		else begin scsi_abort("selection failed"); return; end
	end
	6: sc_state = 2;                            // after PAD
	4: begin                                    // DMA done
		old = sc_resid;
		esp_r(6'h01, hi);
		esp_r(6'h00, lo);
		sc_resid = {16'd0, hi, lo};
		sc_addr = sc_addr + (old - sc_resid);
		sc_state = 2;
		dma_cleanup(sc_resid);
		if ((sc_flags & 32'h4000) != 0) begin scsi_abort("bus error"); return; end
	end
	3: begin                                    // after ICCS
		if (sc_ist[5]) begin scsi_abort("target aborted"); return; end
		if (!sc_ist[3]) begin scsi_abort("fifo level"); return; end
		esp_r(6'h07, b);
		if ((b & 8'h1F) != 2) begin scsi_abort("fifo level"); return; end
		sc_state = 2;
		esp_r(6'h02, dv_status);
		esp_r(6'h02, sc_msg);
		scsi_msgin_done();
	end
	7: begin                                    // after TI in MESSAGE IN
		if (sc_ist[5]) begin scsi_abort("target aborted2"); return; end
		esp_r(6'h07, b);
		if ((b & 8'h1F) != 1) begin scsi_abort("msgin fifo level"); return; end
		esp_r(6'h02, sc_msg);
		scsi_msgin_done();
	end
	5: begin                                    // disconnected
		sc_state = 0;
		sc_cur = 0;
		dv_resid = sc_resid;
		dv_state = 2;
	end
	default: begin scsi_abort("scintr program error"); return; end
	endcase
	if (sc_state == 2) scsi_phase_dispatch();
endtask

// scsi_run_cmd $0100db8e (runs in its own process, see scsi_run_cmd())
task automatic scsi_run_cmd_body(output bit ok);
	int d2;
	ok = 0;
	scsi_start();
	d2 = 0;
	if (dv_state == 0) begin
		forever begin
			delay_us(POLL_US);
			while (!int_scsi) begin
				delay_us(POLL_US);
				d2++;
				if (d2 > 1000) begin scsi_abort("Didn't complete"); return; end
			end
			scsi_intr();
			if (dv_state != 0) break;
		end
	end
	ok = (dv_state == 2 && dv_status == 0);
endtask

bit run_req = 0, run_ok;
initial forever begin
	wait (run_req);
	scsi_run_cmd_body(run_ok);
	run_req = 0;
end

task automatic scsi_run_cmd(output bit ok);
	run_req = 1'b1;
	wait (!run_req);
	ok = run_ok;
endtask

// sd_request_sense $0100e49a
task automatic sd_request_sense();
	bit ok;
	for (int t = 0; t <= 2; t++) begin
		cdb_clear();
		dv_cdb[0] = 8'h03; dv_cdb[1] = {dv_lun[2:0], 5'd0}; dv_cdb[4] = 8'h0E;
		dv_addr = SD_BUF;
		dv_len = 32'd14;
		dv_dir = 8'd1;
		scsi_run_cmd(ok);
		if (ok) return;
		if (dv_state == 2 && dv_status == 8'h08) delay_us(1000000);
	end
	$display("REQ SENSE failed");
endtask

// sd_command $0100e750
task automatic sd_command(output bit ok);
	scsi_run_cmd(ok);
	if (ok) return;
	case (dv_state)
	8'd2: begin
		if (dv_status == 8'h02) sd_request_sense();
		else if (dv_status == 8'h08) delay_us(1000000);
	end
	8'd1, 8'd3, 8'd4, 8'd5: ;
	default: $display("sdcmd bad state: %0d", dv_state);
	endcase
	ok = 0;
endtask

// sd_inquiry $0100e356
task automatic sd_inquiry(input int target, input int lun, output bit found);
	bit ok;
	logic [7:0] t;
	found = 0;
	for (int d2 = 0; d2 <= 2; d2++) begin
		cdb_clear();
		dv_cdb[0] = 8'h12; dv_cdb[1] = {3'(lun), 5'd0}; dv_cdb[4] = 8'h42;
		dv_target = 8'(target);
		dv_lun = 8'(lun);
		dv_addr = SD_BUF;
		dv_len = 32'h42;
		dv_dir = 8'd1;
		sd_command(ok);
		if (ok) begin
			t = mem_rb(SD_BUF);
			if (t == 0 || t == 4 || t == 5 || t == 7 || t == 8) begin found = 1; return; end
		end
		if (dv_state == 5) return;
	end
endtask

// sd_find_target $0100e2f8
task automatic sd_find_target(input int n, input int lun, output int target);
	int d3;
	bit found;
	d3 = -1;
	target = -1;
	for (int d2 = 0; d2 <= 6; d2++) begin
		sd_inquiry(d2, lun, found);
		if (found) d3++;
		else if (dv_state == 5) return;
		if (d3 == n) begin target = d2; return; end
	end
endtask

// sd_start_unit_wait_ready $0100e548
task automatic sd_start_unit_wait_ready();
	bit ok;
	int d2;
	for (int t = 0; t <= 2; t++) begin
		cdb_clear();
		dv_cdb[0] = 8'h1B; dv_cdb[1] = {dv_lun[2:0], 5'd1}; dv_cdb[4] = 8'h01;
		dv_len = 0;
		sd_command(ok);
		if (ok) break;
	end
	d2 = 0;
	forever begin
		if (d2 == 0) d2 = -1;
		else begin
			if (d2 < 0) begin $display("waiting for drive to come ready"); d2 = 1; end
			else d2++;
			delay_us(1000000);
		end
		cdb_clear();
		dv_cdb[1] = {dv_lun[2:0], 5'd0};
		dv_len = 0;
		sd_command(ok);
		if (ok) break;
	end
endtask

// sd_read_capacity $0100e40a
task automatic sd_read_capacity(output bit ok);
	for (int t = 0; t <= 2; t++) begin
		cdb_clear();
		dv_cdb[0] = 8'h25; dv_cdb[1] = {dv_lun[2:0], 5'd0};
		dv_addr = SD_BUF;
		dv_len = 32'd8;
		dv_dir = 8'd1;
		sd_command(ok);
		if (ok) return;
	end
	$display("READ CAPACITY failed");
endtask

// sd_read $0100e646: READ(6), returns bytes read or -1
task automatic sd_read(input logic [31:0] blkno, input logic [31:0] addr, input logic [31:0] len,
                       output int got);
	bit ok;
	logic [31:0] n;
	got = -1;
	n = (len - 1 + bd_blksize) / bd_blksize;
	if (n * bd_blksize != len) begin $display("bad dev blk size %0d", bd_blksize); return; end
	for (int t = 0; t <= 2; t++) begin
		cdb_clear();
		dv_cdb[0] = 8'h08;
		dv_cdb[1] = {dv_lun[2:0], blkno[20:16]};
		dv_cdb[2] = blkno[15:8];
		dv_cdb[3] = blkno[7:0];
		dv_cdb[4] = (n == 256) ? 8'd0 : n[7:0];
		dv_len = len;
		dv_addr = addr;
		dv_dir = 8'd1;
		sd_command(ok);
		if (ok) begin got = int'(len - dv_resid); return; end
	end
	$display("READ failed");
endtask

//----------------------------------------------------------------------------
// test helpers
//----------------------------------------------------------------------------
function automatic int buf_mismatches(input logic [31:0] addr, input int lba, input int n);
	int bad = 0;
	for (int i = 0; i < n; i++)
		if (mem_rb(addr + i) != disk[(lba * 512) + i]) bad++;
	return bad;
endfunction

task automatic read_and_check(input int lba, input int nblk);
	int got, bad;
	expect_chained = 1;
	sd_read(lba, RDBUF, nblk * 512, got);
	expect_chained = 0;
	check(got == nblk * 512, $sformatf("sd_read(%0d, %0d blocks) returned %0d", lba, nblk, got));
	bad = buf_mismatches(RDBUF, lba, nblk * 512);
	check(bad == 0, $sformatf("sd_read(%0d, %0d blocks): %0d bytes differ", lba, nblk, bad));
	bad = buf_mismatches(BOUNCE, lba, nblk * 512);
	check(bad == 0, $sformatf("sd_read(%0d, %0d blocks): bounce buffer differs in %0d bytes", lba, nblk, bad));
	// the chain completed and stopped; Next = end of the 32-byte scratch window
	check(sc_csr_save == (32'h0800_0000 | csr_sticky),
	      $sformatf("sd_read: CSR at dma_stop %08x, want COMPLETE only", sc_csr_save));
	check(sc_next_save == sc_scratch + 32'h20, $sformatf("sd_read: Next at stop %08x, want %08x",
	      sc_next_save, sc_scratch + 32'h20));
	check(!int_scsi_dma, "INT_SCSI_DMA released by dma_stop's RESET");
	$display("  read  LBA %4d x%2d  ok (%0d DMA writes so far)", lba, nblk, dma_wr_words);
endtask

task automatic fill_ram(input logic [31:0] a, input int n, input logic [7:0] v);
	for (int i = 0; i < n; i++) mem_wb(a + i, v);
endtask

// every Turbo DMA register (ioMemTabTurbo.c:37-106)
task automatic tdma_register_test();
	logic [31:0] v;
	logic [16:0] csr [0:6];
	logic [16:0] ptr;
	csr[0] = 17'h00010; csr[1] = 17'h00040; csr[2] = 17'h00080; csr[3] = 17'h00090;
	csr[4] = 17'h000D0; csr[5] = 17'h00110; csr[6] = 17'h00150;
	$display("TDMA registers");
	// pointers of all seven channels (Next/Limit/Start/Stop) read back
	for (int c = 0; c < 7; c++)
		for (int r = 0; r < 4; r++) begin
			ptr = csr[c] + 17'h04000 + 17'(4 * r);
			tdma_w(ptr, 32'h0400_0000 + 32'(c * 32'h1000 + r * 32'h100));
		end
	for (int c = 0; c < 7; c++)
		for (int r = 0; r < 4; r++) begin
			ptr = csr[c] + 17'h04000 + 17'(4 * r);
			tdma_r(ptr, v);
			check(v == 32'h0400_0000 + 32'(c * 32'h1000 + r * 32'h100),
			      $sformatf("channel %05x reg %0d reads %08x", csr[c], r, v));
		end
	// bit 12 of the offset is not decoded ($1EFFF): $02005044 = $02004044
	tdma_r(17'h05044, v);
	check(v == 32'h0400_1100, $sformatf("bit-12 alias of sound-out Limit reads %08x", v));
	// byte-lane write
	tdma_acc(1'b1, 17'h04048, 4'b0100, 32'h00AB_0000, v);
	tdma_r(17'h04048, v);
	check(v == 32'h04AB_1200, $sformatf("byte-lane write to sound-out Start: %08x", v));
	// saved limit $02004050: read-only (Ethernet RX saved_limit, no engine: 0)
	tdma_w(17'h04050, 32'h1234_5678);
	tdma_r(17'h04050, v);
	check(v == 32'd0, $sformatf("saved limit reads %08x", v));
	// plain registers $02004100-$0200410C, $02004140-$0200414C
	for (int r = 0; r < 4; r++) begin
		tdma_w(17'h04100 + 17'(4 * r), 32'hA000_0000 + 32'(r));
		tdma_w(17'h04140 + 17'(4 * r), 32'hB000_0000 + 32'(r));
	end
	for (int r = 0; r < 4; r++) begin
		tdma_r(17'h04100 + 17'(4 * r), v);
		check(v == 32'hA000_0000 + 32'(r), $sformatf("plain $0200410%0x reads %08x", 4 * r, v));
		tdma_r(17'h04140 + 17'(4 * r), v);
		check(v == 32'hB000_0000 + 32'(r), $sformatf("plain $0200414%0x reads %08x", 4 * r, v));
	end
	// the TX Start/Stop are still intact after the plain registers
	tdma_r(17'h0411C, v);
	check(v == 32'h0400_5300, $sformatf("Ethernet TX Stop reads %08x", v));
	// init registers: write = Next, read = Next
	for (int c = 0; c < 7; c++) begin
		tdma_w(csr[c] + 17'h04200, 32'h0500_0000 + 32'(c * 16));
		tdma_r(csr[c] + 17'h04000, v);
		check(v == 32'h0500_0000 + 32'(c * 16), $sformatf("init of %05x: Next %08x", csr[c], v));
		tdma_r(csr[c] + 17'h04200, v);
		check(v == 32'h0500_0000 + 32'(c * 16), $sformatf("init of %05x reads %08x", csr[c], v));
	end
	// the SCSI init register sets the channel buffer's fill offset
	tdma_w(T_INIT, 32'h0400_0008);
	@(posedge clk);
	check(scsi.dma_buf_limit == 5'd8 && scsi.dma_buf_size == 5'd0,
	      $sformatf("SCSI init: buffer limit %0d size %0d", scsi.dma_buf_limit, scsi.dma_buf_size));
	// CSR command semantics, every channel (TDMA_CSR_Write dma.c:1120-1178)
	for (int c = 0; c < 7; c++) begin
		tdma_w(csr[c] + 17'h04000, 32'h0400_0000);          // aligned Next/Limit for SCSI
		tdma_w(csr[c] + 17'h04004, 32'h0400_0100);
		tdma_w(csr[c], 32'h0010_0000);                      // RESET
		tdma_r(csr[c], v);
		check(v == 32'd0, $sformatf("CSR %05x after RESET: %08x", csr[c], v));
		tdma_w(csr[c], 32'h0003_0000);                      // SETENABLE | SETSUPDATE
		tdma_r(csr[c], v);
		check(v == 32'h0300_0000, $sformatf("CSR %05x after SETENABLE|SETSUPDATE: %08x", csr[c], v));
		tdma_w(csr[c], 32'h0068_0000);                      // CLRCOMPLETE|SETCOMPLETE|FLUSH
		tdma_r(csr[c], v);
		check(v == 32'h0300_0000, $sformatf("CSR %05x after SETCOMPLETE|FLUSH: %08x", csr[c], v));
		tdma_w(csr[c] | 17'h01000, 32'h0010_0000);          // RESET through the bit-12 alias
		tdma_r(csr[c], v);
		check(v == 32'd0, $sformatf("CSR %05x after aliased RESET: %08x", csr[c], v));
	end
	check(!int_scsi_dma && !int_snd_out_dma && !int_snd_in_dma && !int_printer_dma &&
	      !int_dsp_dma && !int_en_tx_dma && !int_en_rx_dma, "no DMA interrupt from register writes");
	// SCSI: SETENABLE with a Next off a longword -> COMPLETE|BUSEXC (dma.c:395)
	tdma_w(T_NEXT, 32'h0400_0002);
	tdma_w(T_LIMIT, 32'h0400_0100);
	tdma_w(T_CSR, 32'h0004_0000 | 32'h0001_0000);
	tdma_r(T_CSR, v);
	check(v == 32'h1800_0000, $sformatf("misaligned SETENABLE: CSR %08x, want COMPLETE|BUSEXC", v));
	check(int_scsi_dma, "INT_SCSI_DMA follows COMPLETE");
	tdma_w(T_CSR, 32'h0008_0000);                           // CLRCOMPLETE on a stopped channel
	tdma_r(T_CSR, v);
	check(v == 32'h1800_0000, $sformatf("CLRCOMPLETE on a stopped channel: CSR %08x (kept)", v));
	tdma_w(T_CSR, 32'h0010_0000);
	tdma_r(T_CSR, v);
	check(v == 32'h1000_0000, $sformatf("RESET keeps BUSEXC (dma.c:1160): CSR %08x", v));
	check(!int_scsi_dma, "INT_SCSI_DMA released with COMPLETE");
	// SCSI: Limit off a 16-byte boundary is refused too
	tdma_w(T_NEXT, 32'h0400_0000);
	tdma_w(T_LIMIT, 32'h0400_0104);
	tdma_w(T_CSR, 32'h0001_0000);
	tdma_r(T_CSR, v);
	check(v == 32'h1800_0000, $sformatf("misaligned Limit: CSR %08x", v));
	tdma_w(T_CSR, 32'h0010_0000);
endtask

// the POST SCSI tests (HS 9.5)
task automatic post_scsi_tests();
	logic [7:0] b, b2;
	$display("POST SCSI FIFO test");
	esp_w(6'h20, 8'h02); delay_us(10);
	esp_w(6'h20, 8'h00); delay_us(10);
	esp_w(6'h03, 8'h02);
	esp_w(6'h03, 8'h00);
	for (int i = 0; i < 5; i++) esp_w(6'h02, 8'(i));
	esp_r(6'h07, b);
	check((b & 8'h1F) == 5, $sformatf("post_scsi_test: FIFO flags %02x, want 5", b));
	esp_r(6'h02, b);
	check(b == 0, $sformatf("post_scsi_test: first FIFO byte %02x", b));
	esp_r(6'h02, b);
	check(b == 1, $sformatf("post_scsi_test: second FIFO byte %02x", b));
	esp_r(6'h07, b);
	check((b & 8'h1F) == 3, $sformatf("post_scsi_test: FIFO flags %02x, want 3", b));
	$display("POST extended SCSI test");
	esp_w(6'h20, 8'h02); delay_us(10);
	esp_w(6'h20, 8'h00); delay_us(10);
	esp_w(6'h03, 8'h02);
	esp_w(6'h03, 8'h00);
	esp_w(6'h03, 8'h01);
	delay_us(10);
	esp_r(6'h07, b);
	check((b & 8'h1F) == 0, $sformatf("post_ext: FIFO flags after flush %02x", b));
	esp_w(6'h00, 8'h55); esp_w(6'h01, 8'h55); esp_w(6'h03, 8'h80);
	esp_r(6'h01, b); esp_r(6'h00, b2);
	check({b, b2} == 16'h5555, $sformatf("post_ext: counter %02x%02x, want 5555", b, b2));
	esp_w(6'h00, 8'hAA); esp_w(6'h01, 8'hAA); esp_w(6'h03, 8'h80);
	esp_r(6'h01, b); esp_r(6'h00, b2);
	check({b, b2} == 16'hAAAA, $sformatf("post_ext: counter %02x%02x, want AAAA", b, b2));
	for (int i = 0; i <= 255; i++) begin
		esp_w(6'h08, 8'(i));
		esp_r(6'h08, b);
		if (b != 8'(i)) begin check(0, $sformatf("post_ext: config %02x reads %02x", i, b)); break; end
	end
	esp_w(6'h08, 8'h00);
	esp_r(6'h05, b);
	esp_w(6'h03, 8'hFF);                         // illegal command
	delay_us(10);
	esp_r(6'h05, b);
	check(b[6], $sformatf("post_ext: interrupt status %02x after command $FF, want bit 6", b));
	esp_w(6'h03, 8'h02);
	esp_w(6'h03, 8'h00);
	check(!int_scsi, "INT_SCSI stays low with ENABLE_INT clear");
endtask

//----------------------------------------------------------------------------
// the test
//----------------------------------------------------------------------------
logic [7:0] exp_inq [0:53];
logic [7:0] exp_ms [0:63];

initial begin
	int target, got, bad, n;
	bit ok;
	logic [31:0] v;
	logic [7:0] b;

	for (int i = 0; i < DRAM_WORDS; i++) dram[i] = 32'hDEAD_BEEF;
	for (int bk = 0; bk < DISK_BLOCKS; bk++)
		for (int k = 0; k < 512; k++) disk[bk * 512 + k] = pat(bk, k);
	for (int u = 0; u < 4; u++) unit_size[u] = 0;
	sc_state = 0; sc_cur = 0; sc_flags = 0;

	repeat (8) @(posedge clk);
	reset <= 1'b0;
	repeat (4) @(posedge clk);
	// OSD mount of the disk on slot 1 (2 MB)
	img_size <= 64'(DISK_BLOCKS * 512);
	img_mounted <= 6'b000010;
	@(posedge clk);
	img_mounted <= 6'b000000;
	repeat (4) @(posedge clk);

	//------------------------------------------------------------
	tdma_register_test();
	post_scsi_tests();
	// the register tests left BUSEXC set (sticky, Previous): machine reset
	@(posedge clk); reset <= 1'b1;
	repeat (4) @(posedge clk); reset <= 1'b0;
	repeat (4) @(posedge clk);
	tdma_r(T_CSR, v);
	check(v == 32'd0, $sformatf("CSR after machine reset %08x", v));

	// $704 path (HS 0.3 step 14): ESP reset, SCSI bus reset
	esp_w(6'h20, 8'h02);
	esp_w(6'h03, 8'h03);

	//------------------------------------------------------------
	// sd_open $0100e1ec: scsi_init, the n-th responding target (n = 0)
	//------------------------------------------------------------
	$display("sd_open");
	scsi_init();
	check(!int_scsi, "scsi_init leaves INT_SCSI low");
	sd_find_target(0, 0, target);
	check(target == DISK_UNIT, $sformatf("sd_find_target found %0d, want %0d", target, DISK_UNIT));
	check(timeouts == 3, $sformatf("absent target 0 timed out %0d times, want 3 (sd_inquiry retries)", timeouts));
	check(sc_csr_save == 32'h0800_0000, $sformatf("INQUIRY: CSR at dma_stop %08x", sc_csr_save));
	check(sc_next_save == sc_scratch + 32'h50, $sformatf("INQUIRY: Next at stop %08x, want %08x",
	      sc_next_save, sc_scratch + 32'h50));
	check(dv_resid == 32'd12, $sformatf("INQUIRY residual %0d, want 66 - 54 = 12", dv_resid));
	n = resp_inquiry(DISK_UNIT, 0);
	for (int i = 0; i < 54; i++) exp_inq[i] = win_buf[i];
	bad = 0;
	for (int i = 0; i < 54; i++) if (mem_rb(SD_BUF + i) != exp_inq[i]) bad++;
	check(bad == 0, $sformatf("INQUIRY data: %0d of 54 bytes differ", bad));
	$display("  target %0d: '%s'", target, {mem_rb(SD_BUF + 8), mem_rb(SD_BUF + 9), mem_rb(SD_BUF + 10),
	         mem_rb(SD_BUF + 11), mem_rb(SD_BUF + 12), mem_rb(SD_BUF + 13), mem_rb(SD_BUF + 14),
	         mem_rb(SD_BUF + 15)});
	dv_target = 8'(target);
	dv_lun = 0;
	sd_start_unit_wait_ready();
	check(dv_state == 2 && dv_status == 0, "TEST UNIT READY: GOOD");
	sd_read_capacity(ok);
	check(ok, "READ CAPACITY completed");
	bd_lastlba = mem_rl(SD_BUF);
	bd_blksize = mem_rl(SD_BUF + 4);
	check(bd_lastlba == DISK_BLOCKS - 1, $sformatf("READ CAPACITY last LBA %0d", bd_lastlba));
	check(bd_blksize == 512, $sformatf("READ CAPACITY block length %0d", bd_blksize));
	$display("  capacity: last LBA %0d, %0d-byte blocks", bd_lastlba, bd_blksize);
	check(aborts == 0, "no scsi_abort so far");

	//------------------------------------------------------------
	// sd_read: READ(6) through the 2-descriptor chain
	//------------------------------------------------------------
	$display("sd_read");
	read_and_check(0, 1);
	ack_running = 1;                           // plus a driver-style acknowledge
	read_and_check(15, 16);                    // one boot_fs chunk ($2000)
	ack_running = 0;
	read_and_check(4093, 3);                   // the last blocks of the image
	read_and_check(1234, 7);

	// REQUEST SENSE after a READ past the end (sd_command, CHECK CONDITION)
	$display("READ past the end -> REQUEST SENSE");
	sd_read(DISK_BLOCKS + 5, RDBUF, 512, got);
	check(got == -1, "READ past the end fails");
	check(mem_rb(SD_BUF) == 8'hF0, $sformatf("sense byte 0 %02x, want F0 (valid)", mem_rb(SD_BUF)));
	check(mem_rb(SD_BUF + 2) == 8'h05, $sformatf("sense key %02x, want 5", mem_rb(SD_BUF + 2)));
	check(mem_rl(SD_BUF + 3) == DISK_BLOCKS + 5, $sformatf("sense information %08x", mem_rl(SD_BUF + 3)));
	check(mem_rb(SD_BUF + 12) == 8'h21, $sformatf("sense code %02x, want 21", mem_rb(SD_BUF + 12)));

	// the last partial burst through the scratch buffer, then PAD:
	// 300 of a 512-byte block, sd.len = 300
	$display("partial block: scratch tail + transfer pad");
	fill_ram(RDBUF, 512, 8'h00);
	cdb_clear();
	dv_cdb[0] = 8'h08; dv_cdb[3] = 8'd42; dv_cdb[4] = 8'd1;
	dv_len = 32'd300; dv_addr = RDBUF; dv_dir = 8'd1;
	sd_command(ok);
	check(ok, "READ(6) of 300 bytes completed");
	check(dv_resid == 0, $sformatf("partial read residual %0d", dv_resid));
	bad = buf_mismatches(RDBUF, 42, 300);
	check(bad == 0, $sformatf("partial read: %0d of 300 bytes differ", bad));
	check(mem_rb(RDBUF + 300) == 8'h00, "partial read: nothing beyond 300 bytes");
	check(sc_next_save == sc_scratch + 32'h20, "partial read: Next at stop = scratch + 32");

	// MODE SENSE all pages, allocation 255 (>= 128 path, short answer)
	$display("MODE SENSE page 3F");
	cdb_clear();
	dv_cdb[0] = 8'h1A; dv_cdb[2] = 8'h3F; dv_cdb[4] = 8'hFF;
	dv_len = 32'd255; dv_addr = RDBUF; dv_dir = 8'd1;
	sd_command(ok);
	check(ok, "MODE SENSE completed");
	check(dv_resid == 255 - 64, $sformatf("MODE SENSE residual %0d, want 191", dv_resid));
	for (int i = 0; i < 512; i++) win_buf[i] = 8'h00;
	n = resp_mode_sense(DISK_UNIT, 0, 8'h3F);
	check(n == 64, "Main's MODE SENSE length");
	for (int i = 0; i < 64; i++) exp_ms[i] = win_buf[i];
	bad = 0;
	for (int i = 0; i < 64; i++) if (mem_rb(RDBUF + i) != exp_ms[i]) bad++;
	check(bad == 0, $sformatf("MODE SENSE data: %0d of 64 bytes differ", bad));

	// WRITE(6): memory to device through the M2DEV chain (not used by the
	// ROM, but the same helpers with dir = 0)
	$display("WRITE(6) 2 blocks");
	for (int i = 0; i < 1024; i++) mem_wb(WRBUF + i, 8'(i * 7 + 3));
	cdb_clear();
	dv_cdb[0] = 8'h0A; dv_cdb[3] = 8'd100; dv_cdb[4] = 8'd2;
	dv_len = 32'd1024; dv_addr = WRBUF; dv_dir = 8'd0;
	sd_command(ok);
	check(ok, "WRITE(6) completed");
	bad = 0;
	for (int i = 0; i < 1024; i++) if (disk[100 * 512 + i] != 8'(i * 7 + 3)) bad++;
	check(bad == 0, $sformatf("WRITE(6): %0d of 1024 bytes differ on the disk", bad));
	check(sc_csr_save == 32'h0900_0000, $sformatf("WRITE: CSR at dma_stop %08x, want ENABLE|COMPLETE", sc_csr_save));
	check(sc_next_save == sc_scratch, $sformatf("WRITE: Next at stop %08x, want the scratch start", sc_next_save));
	read_and_check(100, 2);

	//------------------------------------------------------------
	// the full INQUIRY scan over targets 0..6 (n = 1: only one disk)
	//------------------------------------------------------------
	$display("INQUIRY scan of targets 0..6");
	timeouts = 0;
	sd_find_target(1, 0, target);
	check(target == -1, $sformatf("scan for a second disk found %0d", target));
	check(timeouts == 18, $sformatf("%0d selection timeouts, want 6 absent targets x 3", timeouts));
	check(aborts == 0, $sformatf("%0d scsi_abort calls", aborts));

	//------------------------------------------------------------
	// a DMA bus error (m_err) during a transfer -> BUSEXC
	//------------------------------------------------------------
	$display("DMA bus error");
	dv_target = 8'(DISK_UNIT);
	cdb_clear();
	dv_cdb[0] = 8'h08; dv_cdb[3] = 8'd9; dv_cdb[4] = 8'd1;
	dv_len = 32'd512; dv_addr = RDBUF; dv_dir = 8'd1;
	sc_bounce = 32'h0010_0000;                 // not RAM
	scsi_start();
	delay_us(POLL_US);
	check(int_scsi, "selection interrupt");
	win_any = 1'b0;                            // the faulting access is expected
	scsi_intr();                               // -> DATA IN, dma_start at the bad buffer
	check(sc_state == 4, "the data phase started");
	delay_us(2000);
	tdma_r(T_CSR, v);
	// dma.c:445-449: ENABLE off, COMPLETE|BUSEXC; SUPDATE of the 2-descriptor chain stays
	check(v == 32'h1A00_0000, $sformatf("bus error: CSR %08x, want BUSEXC|COMPLETE|SUPDATE", v));
	check(int_scsi_dma, "bus error raises INT_SCSI_DMA");
	check(dma_errs == 1, $sformatf("%0d faulting accesses, want 1", dma_errs));
	tdma_r(T_NEXT, v);
	check(v == 32'h0010_0000, $sformatf("bus error: Next %08x did not advance", v));
	check(!int_scsi, "no ESP completion while the channel is stopped");
	tdma_w(T_CSR, 32'h0008_0000);              // CLRCOMPLETE: stopped -> kept
	tdma_r(T_CSR, v);
	check(v[27], "CLRCOMPLETE keeps COMPLETE on a stopped channel");
	// recover like scsi_abort (state 4: DMA control $20, dma_stop, scsi_init)
	aborts--;                                  // this abort is part of the test
	scsi_abort("bus error test");
	sc_bounce = BOUNCE;
	check(!int_scsi_dma, "RESET released INT_SCSI_DMA");
	tdma_r(T_CSR, v);
	check(v == 32'h1000_0000, $sformatf("after RESET the CSR keeps BUSEXC only: %08x", v));
	csr_sticky = 32'h1000_0000;
	read_and_check(9, 1);                      // BUSEXC stays (sticky) but data moves

	//------------------------------------------------------------
	// the sound-out channel ($02000040 / $02004040..C): frames for the
	// sound box, two chained buffers (dma.c dma_sndout_read_memory /
	// dma_interrupt)
	//------------------------------------------------------------
	$display("sound out channel");
	begin : sndout
		localparam logic [31:0] SBUF = 32'h0430_0000;
		localparam logic [16:0] O_CSR = 17'h00040, O_NEXT = 17'h04040, O_LIMIT = 17'h04044,
		                        O_START = 17'h04048, O_STOP = 17'h0404C, O_INIT = 17'h04240;
		int k, n;
		bit ok;
		win_any = 1'b0;
		for (k = 0; k < 12; k++) dram[(SBUF - DRAM_BASE) / 4 + k] = 32'h5000_0000 + k;
		so_got.delete();
		n = so_words;
		tdma_w(O_CSR, 32'h0010_0000);              // RESET
		tdma_w(O_NEXT, SBUF);
		tdma_w(O_LIMIT, SBUF + 16);
		tdma_w(O_START, SBUF + 16);
		tdma_w(O_STOP, SBUF + 32);
		check(!so_avail, "sound: a stopped channel has no data");
		tdma_w(O_CSR, 32'h0003_0000);              // SETENABLE | SETSUPDATE
		check(so_avail, "sound: enabled channel with Next < Limit has data");
		so_req = 1'b1;
		wait (so_words == n + 4);
		so_req = 1'b0;
		@(posedge clk);
		tdma_r(O_CSR, v);
		check(v == 32'h0900_0000, $sformatf("sound: first buffer done, chained: CSR %08x", v));
		check(int_snd_out_dma, "sound: INT_SND_OUT_DMA with COMPLETE");
		tdma_r(O_NEXT, v);
		check(v == SBUF + 16, $sformatf("sound: Next %08x = Start after the chain", v));
		tdma_w(O_CSR, 32'h0008_0000);              // CLRCOMPLETE (running channel)
		check(!int_snd_out_dma, "sound: CLRCOMPLETE releases the interrupt");
		so_req = 1'b1;
		wait (so_words == n + 8);
		repeat (20) @(posedge clk);
		so_req = 1'b0;
		check(so_words == n + 8, "sound: no word past the second buffer");
		ok = (so_got.size() == 8);
		for (k = 0; k < 8 && ok; k++) ok = (so_got[k] == 32'h5000_0000 + k);
		check(ok, "sound: 8 frames in memory order across the chain");
		tdma_r(O_CSR, v);
		check(v == 32'h0800_0000, $sformatf("sound: all done: CSR %08x (COMPLETE, ENABLE off)", v));
		check(!so_avail, "sound: no data after the last buffer");

		// a request withdrawn while its word is in flight: dropped, Next stays
		tdma_w(O_CSR, 32'h0010_0000);
		tdma_w(O_INIT, SBUF + 32);                 // init = Next
		tdma_w(O_LIMIT, SBUF + 48);
		tdma_w(O_CSR, 32'h0001_0000);
		n = so_words;
		@(negedge clk); so_req = 1'b1;
		wait (m_req);
		@(negedge clk); so_req = 1'b0;
		repeat (30) @(posedge clk);
		check(so_words == n, "sound: withdrawn request delivers nothing");
		tdma_r(O_NEXT, v);
		check(v == SBUF + 32, $sformatf("sound: withdrawn request leaves Next at %08x", v));
		// RESET while a word is in flight: dropped too
		@(negedge clk); so_req = 1'b1;
		wait (m_req);
		tdma_w(O_CSR, 32'h0010_0000);
		repeat (30) @(posedge clk);
		so_req = 1'b0;
		check(so_words == n, "sound: RESET drops the word in flight");
		tdma_r(O_NEXT, v);
		check(v == SBUF + 32, $sformatf("sound: RESET leaves Next at %08x", v));
		// a bus error: COMPLETE | BUSEXC, ENABLE off
		tdma_w(O_NEXT, 32'h0010_0000);             // not RAM
		tdma_w(O_LIMIT, 32'h0010_0010);
		tdma_w(O_CSR, 32'h0001_0000);
		so_req = 1'b1;
		repeat (40) @(posedge clk);
		so_req = 1'b0;
		tdma_r(O_CSR, v);
		check(v == 32'h1800_0000, $sformatf("sound: bus error CSR %08x", v));
		check(so_words == n, "sound: nothing delivered on a bus error");
		tdma_w(O_CSR, 32'h0010_0000);
		dma_errs = 0;
	end

	//------------------------------------------------------------
	// the DSP channel ($020000D0 / $020040D0..C): single bytes on big-
	// endian lanes, a chain of two blocks, a block end per block
	// (dma.c dma_dsp_read_memory / dma_dsp_write_memory / dma_interrupt)
	//------------------------------------------------------------
	$display("DSP channel");
	begin : dspch
		localparam logic [31:0] DBUF = 32'h0431_0001;   // odd: byte lanes
		localparam logic [16:0] P_CSR = 17'h000D0, P_NEXT = 17'h040D0, P_LIMIT = 17'h040D4,
		                        P_START = 17'h040D8, P_STOP = 17'h040DC;
		int k;
		bit ok;
		for (k = 0; k < 4; k++) dram[(DBUF - 1 - DRAM_BASE) / 4 + k] = 32'h00112233 + 32'h44444444 * k;
		// memory -> DSP: 5 bytes then 3 bytes (chained)
		dd_got.delete(); dd_blkends = 0;
		tdma_w(P_CSR, 32'h0010_0000);
		tdma_w(P_NEXT, DBUF);
		tdma_w(P_LIMIT, DBUF + 5);
		tdma_w(P_START, DBUF + 5);
		tdma_w(P_STOP, DBUF + 8);
		tdma_w(P_CSR, 32'h0003_0000);              // SETENABLE | SETSUPDATE
		check(dd_avail, "dsp: channel has data");
		dd_we = 1'b0; dd_req = 1'b1;
		wait (dd_got.size() == 5);
		dd_req = 1'b0;
		@(posedge clk);
		tdma_r(P_CSR, v);
		check(v == 32'h0900_0000, $sformatf("dsp: first block done, chained: CSR %08x", v));
		check(int_dsp_dma && dd_blkends == 1, "dsp: INT_DSP_DMA and a block end");
		tdma_w(P_CSR, 32'h0008_0000);              // CLRCOMPLETE
		dd_req = 1'b1;
		wait (dd_got.size() == 8);
		repeat (20) @(posedge clk);
		dd_req = 1'b0;
		ok = (dd_got.size() == 8);
		// bytes from DBUF = $..01: 11 22 33 44 55 66 77 88 (lane order)
		for (k = 0; k < 8 && ok; k++) ok = (dd_got[k] == 8'(8'h11 * (k + 1)));
		check(ok, $sformatf("dsp: 8 bytes in memory order: %02x %02x %02x .. %02x",
		      dd_got[0], dd_got[1], dd_got[2], dd_got[7]));
		check(dd_blkends == 2 && !dd_avail, "dsp: second block end, channel done");
		tdma_r(P_CSR, v);
		check(v == 32'h0800_0000, $sformatf("dsp: all done: CSR %08x", v));
		// DSP -> memory: 3 bytes from an odd address
		dram[(DBUF + 32'h10 - 1 - DRAM_BASE) / 4] = 32'h5A5A5A5A;
		tdma_w(P_CSR, 32'h0010_0000);
		tdma_w(P_NEXT, DBUF + 32'h10);
		tdma_w(P_LIMIT, DBUF + 32'h13);
		tdma_w(P_CSR, 32'h0005_0000);              // SETENABLE | DEV2M
		dd_we = 1'b1;
		for (k = 0; k < 3; k++) begin
			dd_wdata = 8'hA0 + 8'(k);
			dd_req = 1'b1;
			wait (dd_ack);
			@(negedge clk);
			dd_req = 1'b0;
			@(negedge clk);
		end
		check(dram[(DBUF + 32'h10 - 1 - DRAM_BASE) / 4] == 32'h5AA0A1A2,
		      $sformatf("dsp: bytes written on their lanes: %08x", dram[(DBUF + 32'h10 - 1 - DRAM_BASE) / 4]));
		tdma_w(P_CSR, 32'h0010_0000);
	end

	//------------------------------------------------------------
	$display("DMA: %0d longwords written, %0d read; HPS: %0d sector reads, %0d writes, %0d window reads",
	         dma_wr_words, dma_rd_words, sd_reads, sd_writes, win_reads);
	check(aborts == 0, $sformatf("%0d unexpected scsi_abort calls", aborts));
	if (errors == 0)
		$display("PASS: tb_tc_scsi (%0d checks, %0d ESP interrupts serviced)", checks, interrupts);
	else
		$display("FAIL: tb_tc_scsi (%0d of %0d checks failed)", errors, checks);
	if (errors != 0) $fatal(1, "tb_tc_scsi failed");
	$finish;
end

// watchdog
initial begin
	#(64'd6_000_000_000);                     // 200M clocks
	$display("FAIL: tb_tc_scsi watchdog (%0d errors so far)", errors);
	$fatal(1, "timeout");
end

endmodule
