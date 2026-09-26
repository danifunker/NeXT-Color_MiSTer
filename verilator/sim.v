// NeXT-Color full-machine simulation top.
//
// Instantiates the machine (rtl/tc_machine.sv) and the REAL memory system
// (rtl/tc_memsys.sv: sdram_beat32 + sdram.sv against two sdram_model chip
// ranks, tc_rom, tc_vram against ddr3_model), which is the part of the
// MiSTer top the MacQuadra800 sim did not cover.  Not simulated here: the
// emu shell (NeXT-Color.sv: hps_io, PLLs, video_freak).
//
// Clocks come from sim_main.cpp: clk_ram at 99 MHz and clk_sys exactly a
// third of it, rising edges aligned, as the PLL gives the real design.
// clk_vid (100 MHz on the board, own PLL) is clk_ram here: the design treats
// it as asynchronous, so any phase is a legal one.
//
// ROM: +rom=<file> ($readmemh of 32-bit big-endian words, `xxd -p -c4`),
// default rom.hex, loaded straight into tc_rom's array.

module emu
(
	input         clk_sys,
	input         clk_ram,
	input         reset,          // machine reset (held by sim_main.cpp)
	input         config_reset,   // power-up: NVRAM default image
	input         sdram_init,

	input   [1:0] ram_cfg,
	input         pot_on,
	input  [95:0] boot_cmd,
	input  [10:0] ps2_key,
	input  [24:0] ps2_mouse,
	input  [32:0] timestamp,

	// SD slot mounts (sim_main.cpp pulses one bit per opened image)
	input   [5:0] img_mounted,
	input         img_readonly,
	input  [63:0] img_size,
	output        sd_busy,

	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_DE,

	output        led,
	output        reset_req,

	// CPU / machine observation
	output [31:0] dbg_pc,          // fetch pointer
	output [31:0] dbg_pc_i,        // instruction being executed
	output [15:0] dbg_sr,
	output [15:0] dbg_ir,
	output [31:0] dbg_a7,
	output [31:0] dbg_d0,
	output [31:0] dbg_d1,
	output [31:0] dbg_d2,
	output [31:0] dbg_a0,
	output  [7:0] dbg_state,
	output        dbg_halted,
	output        dbg_berr,
	output [31:0] dbg_berr_addr,
	output [31:0] dbg_intstat,
	output  [2:0] dbg_ipl,
	output  [7:0] dbg_exc_vec,
	output        dbg_exc_irq,
	output  [3:0] dbg_exc_fmt,
	output [31:0] dbg_exc_spc,
	output [31:0] dbg_exc_addr,
	output        dbg_video_enable,

	// VRAM peek for the PNG dump (64-bit DDR word index) and the palette
	input  [17:0] vram_peek_addr,
	output [63:0] vram_peek_data,
	input         vram_poke_en,
	input  [17:0] vram_poke_addr,
	input  [63:0] vram_poke_data,
	output [127:0] lut_r,
	output [127:0] lut_g,
	output [127:0] lut_b
);

wire clk_vid = clk_ram;

// ---------------------------------------------------------------- machine
wire        mem_req, mem_write;
wire [26:2] mem_addr;
wire  [3:0] mem_be;
wire [31:0] mem_wdata;
wire  [1:0] mem_memsel;
wire [31:0] mem_rdata;
wire        mem_ack;
wire        mem_wp_valid;
wire [26:2] mem_wp_addr;
wire  [3:0] mem_wp_be;
wire [31:0] mem_wp_data;
wire        mem_wq_room;
wire        mem_line_valid;
wire [26:4] mem_line_tag;
wire [127:0] mem_line_data;
wire        mem_line_pending;
wire [26:4] mem_line_pending_tag;

wire [31:0] hreg, vreg;
wire        video_enable;
wire        vbl_pulse;
wire [255:0] debug_status;
wire [127:0] debug_status2;

// the Bt463 display palette: the machine sends its writes to the scan-out's
// palette RAMs (tc_vram); this sim-only copy feeds the PNG dumper's lut_*
wire  [2:0] pal_we;
wire  [3:0] pal_n;
wire  [7:0] pal_d;
reg   [7:0] sh_r [0:15], sh_g [0:15], sh_b [0:15];
integer shi;
initial for (shi = 0; shi < 16; shi = shi + 1) begin
	sh_r[shi] = 8'd0; sh_g[shi] = 8'd0; sh_b[shi] = 8'd0;
end
always @(posedge clk_sys) begin
	if (pal_we[0]) sh_r[pal_n] <= pal_d;
	if (pal_we[1]) sh_g[pal_n] <= pal_d;
	if (pal_we[2]) sh_b[pal_n] <= pal_d;
end
genvar shg;
generate for (shg = 0; shg < 16; shg = shg + 1) begin : g_sh
	assign lut_r[8*shg +: 8] = sh_r[shg];
	assign lut_g[8*shg +: 8] = sh_g[shg];
	assign lut_b[8*shg +: 8] = sh_b[shg];
end endgenerate

wire  [2:0] sd_unit;
wire [31:0] sd_lba;
wire        sd_rd, sd_wr;
reg         sd_ack = 0;
reg  [13:0] sd_buff_addr = 0;
reg   [7:0] sd_buff_dout = 0;
wire  [7:0] sd_buff_din;
reg         sd_buff_wr = 0;

tc_machine machine
(
	.clk(clk_sys),
	.nreset(~reset),
	.ce(1'b1),
	.config_reset(config_reset),
	.ram_cfg(ram_cfg),

	.mem_req(mem_req),
	.mem_write(mem_write),
	.mem_addr(mem_addr),
	.mem_be(mem_be),
	.mem_wdata(mem_wdata),
	.mem_memsel(mem_memsel),
	.mem_rdata(mem_rdata),
	.mem_ack(mem_ack),
	.mem_wp_valid(mem_wp_valid),
	.mem_wp_addr(mem_wp_addr),
	.mem_wp_be(mem_wp_be),
	.mem_wp_data(mem_wp_data),
	.mem_wq_room(mem_wq_room),
	.mem_line_valid(mem_line_valid),
	.mem_line_tag(mem_line_tag),
	.mem_line_data(mem_line_data),
	.mem_line_pending(mem_line_pending),
	.mem_line_pending_tag(mem_line_pending_tag),

	.tmc_hreg(hreg),
	.tmc_vreg(vreg),
	.video_enable(video_enable),
	.pal_we(pal_we),
	.pal_n(pal_n),
	.pal_d(pal_d),
	.vbl_pulse(vbl_pulse),

	.ps2_key(ps2_key),
	.ps2_mouse(ps2_mouse),
	.timestamp(timestamp),
	.pot_on(pot_on),
	.boot_cmd(boot_cmd),

	.img_mounted(img_mounted),
	.img_readonly(img_readonly),
	.img_size(img_size),
	.sd_unit(sd_unit),
	.sd_lba(sd_lba),
	.sd_rd(sd_rd),
	.sd_wr(sd_wr),
	.sd_ack(sd_ack),
	.sd_buff_addr(sd_buff_addr),
	.sd_buff_dout(sd_buff_dout),
	.sd_buff_din(sd_buff_din),
	.sd_buff_wr(sd_buff_wr),
	.sd_busy(sd_busy),

	.led(led),
	.reset_req(reset_req),

	.dbg_berr(dbg_berr),
	.dbg_berr_addr(dbg_berr_addr),
	.debug_status(debug_status),
	.debug_status2(debug_status2),
	.debug_fault(),
	.debug_halted(dbg_halted),
	.dbg_intstat(dbg_intstat),
	.dbg_ipl(dbg_ipl)
);

assign dbg_pc    = debug_status[31:0];
assign dbg_sr    = debug_status[47:32];
assign dbg_ir    = debug_status[63:48];
assign dbg_a7    = debug_status[95:64];
assign dbg_d0    = debug_status[127:96];
assign dbg_d1    = debug_status[159:128];
assign dbg_d2    = debug_status[191:160];
assign dbg_a0    = debug_status[223:192];
assign dbg_state = debug_status[231:224];
assign dbg_video_enable = video_enable;

// the core's exception entry registers (read by sim_main.cpp's [EXC] log)
assign dbg_pc_i     = machine.cpu.core.pc_i;
assign dbg_exc_vec  = machine.cpu.core.exc_vec;
assign dbg_exc_irq  = machine.cpu.core.exc_is_irq;
assign dbg_exc_fmt  = machine.cpu.core.exc_fmt;
assign dbg_exc_spc  = machine.cpu.core.exc_spc;
assign dbg_exc_addr = machine.cpu.core.exc_addr;

// ---------------------------------------------------------------- memory
wire [15:0] SDRAM_DQ;
wire [12:0] SDRAM_A;
wire        SDRAM_DQML, SDRAM_DQMH;
wire  [1:0] SDRAM_BA;
wire        SDRAM_nCS, SDRAM_nWE, SDRAM_nRAS, SDRAM_nCAS, SDRAM_CKE, SDRAM_CLK;

wire        DDRAM_BUSY;
wire  [7:0] DDRAM_BURSTCNT;
wire [28:0] DDRAM_ADDR;
wire [63:0] DDRAM_DOUT;
wire        DDRAM_DOUT_READY;
wire        DDRAM_RD;
wire [63:0] DDRAM_DIN;
wire  [7:0] DDRAM_BE;
wire        DDRAM_WE;

tc_memsys memsys
(
	.clk_sys(clk_sys),
	.clk_ram(clk_ram),
	.clk_vid(clk_vid),
	.reset(reset),
	.reset_vid(sdram_init),
	.sdram_init(sdram_init),

	.mem_req(mem_req),
	.mem_write(mem_write),
	.mem_addr(mem_addr),
	.mem_be(mem_be),
	.mem_wdata(mem_wdata),
	.mem_memsel(mem_memsel),
	.mem_rdata(mem_rdata),
	.mem_ack(mem_ack),
	.mem_wp_valid(mem_wp_valid),
	.mem_wp_addr(mem_wp_addr),
	.mem_wp_be(mem_wp_be),
	.mem_wp_data(mem_wp_data),
	.mem_wq_room(mem_wq_room),
	.mem_line_valid(mem_line_valid),
	.mem_line_tag(mem_line_tag),
	.mem_line_data(mem_line_data),
	.mem_line_pending(mem_line_pending),
	.mem_line_pending_tag(mem_line_pending_tag),

	.rom_we(1'b0),
	.rom_waddr(16'd0),
	.rom_wdata(16'd0),

	.hreg(hreg),
	.vreg(vreg),
	.video_enable(video_enable),
	.pal_we(pal_we),
	.pal_n(pal_n),
	.pal_d(pal_d),
	.vbl_pulse(vbl_pulse),
	.vga_r(VGA_R),
	.vga_g(VGA_G),
	.vga_b(VGA_B),
	.vga_hs(VGA_HS),
	.vga_vs(VGA_VS),
	.vga_de(VGA_DE),

	.SDRAM_DQ(SDRAM_DQ),
	.SDRAM_A(SDRAM_A),
	.SDRAM_DQML(SDRAM_DQML),
	.SDRAM_DQMH(SDRAM_DQMH),
	.SDRAM_BA(SDRAM_BA),
	.SDRAM_nCS(SDRAM_nCS),
	.SDRAM_nWE(SDRAM_nWE),
	.SDRAM_nRAS(SDRAM_nRAS),
	.SDRAM_nCAS(SDRAM_nCAS),
	.SDRAM_CKE(SDRAM_CKE),
	.SDRAM_CLK(SDRAM_CLK),

	.DDRAM_BUSY(DDRAM_BUSY),
	.DDRAM_BURSTCNT(DDRAM_BURSTCNT),
	.DDRAM_ADDR(DDRAM_ADDR),
	.DDRAM_DOUT(DDRAM_DOUT),
	.DDRAM_DOUT_READY(DDRAM_DOUT_READY),
	.DDRAM_RD(DDRAM_RD),
	.DDRAM_DIN(DDRAM_DIN),
	.DDRAM_BE(DDRAM_BE),
	.DDRAM_WE(DDRAM_WE)
);

// MiSTer 128 MB modules: two 64 MB ranks, the second selected by the
// inverse of nCS (MacQuadra800 verilator/tb_sdram.sv)
sdram_model chip_lo
(
	.clk(SDRAM_CLK), .cke(SDRAM_CKE), .nCS(SDRAM_nCS),
	.nRAS(SDRAM_nRAS), .nCAS(SDRAM_nCAS), .nWE(SDRAM_nWE),
	.ba(SDRAM_BA), .a(SDRAM_A), .dqmh(SDRAM_DQMH), .dqml(SDRAM_DQML),
	.dq(SDRAM_DQ)
);
sdram_model chip_hi
(
	.clk(SDRAM_CLK), .cke(SDRAM_CKE), .nCS(~SDRAM_nCS),
	.nRAS(SDRAM_nRAS), .nCAS(SDRAM_nCAS), .nWE(SDRAM_nWE),
	.ba(SDRAM_BA), .a(SDRAM_A), .dqmh(SDRAM_DQMH), .dqml(SDRAM_DQML),
	.dq(SDRAM_DQ)
);

ddr3_model ddr
(
	.clk(clk_ram),
	.busy(DDRAM_BUSY),
	.burstcnt(DDRAM_BURSTCNT),
	.addr(DDRAM_ADDR),
	.dout(DDRAM_DOUT),
	.dout_ready(DDRAM_DOUT_READY),
	.rd(DDRAM_RD),
	.din(DDRAM_DIN),
	.be(DDRAM_BE),
	.we(DDRAM_WE),
	.peek_addr(vram_peek_addr),
	.peek_data(vram_peek_data),
	.poke_en(vram_poke_en),
	.poke_addr(vram_poke_addr),
	.poke_data(vram_poke_data)
);

// ---------------------------------------------------------------- SD slots
// The HPS side of tc_scsi's block interface (NeXT_MiSTer
// tb/tb_next_boot.sv's SD model, one byte per two clocks): disk blocks
// from the images sim_main.cpp opened (--disk0/--disk1), and the
// target-response / command windows (lba >= $7C000000, slot 3) from
// Main_MiSTer's own support/next code, both through host/host_dpi.cpp.
// The final sd_buff_wr of a read lands after sd_ack has dropped, as
// hps_io does it (tc_scsi's sd_read_owned covers that).
import "DPI-C" function int  host_fill(input int slot, input int lba, input int sz);
import "DPI-C" function int  host_byte(input int i);
import "DPI-C" function void host_put(input int i, input int b);
import "DPI-C" function void host_exec(input int slot, input int lba, input int sz);
import "DPI-C" function int  disk_read(input int slot, input int lba);
import "DPI-C" function int  disk_byte(input int i);
import "DPI-C" function void disk_put(input int i, input int b);
import "DPI-C" function void disk_write(input int slot, input int lba);

localparam [31:0] WIN_BASE = 32'h7C00_0000;

reg         sd_rd_act = 0, sd_wr_act = 0, sd_rphase = 0, sd_win = 0;
reg   [2:0] sd_slot = 0;
reg  [31:0] sd_blk = 0;
integer     sd_hr, sd_reads = 0, sd_writes = 0;
// +hostlat=<clocks>: Main answers a request only after this many clocks
// (its poll cadence on hardware is about a millisecond; default: at once)
integer     hostlat = 0, hl_cnt = 0;
initial if ($value$plusargs("hostlat=%d", hostlat)) ;
wire        sd_idle = !sd_ack && !sd_rd_act && !sd_wr_act;
wire        hl_ok   = (hl_cnt >= hostlat);
always @(posedge clk_sys) begin
	if (sd_idle && (sd_rd || sd_wr)) begin
		if (hl_cnt < hostlat) hl_cnt <= hl_cnt + 1;
	end
	else hl_cnt <= 0;
end

always @(posedge clk_sys) begin
	sd_buff_wr <= 0;
	if (sd_idle && sd_rd && hl_ok) begin
		sd_ack       <= 1;
		sd_rd_act    <= 1;
		sd_buff_addr <= 0;
		sd_win       <= (sd_lba >= WIN_BASE);
		if (sd_lba >= WIN_BASE)
			sd_hr = host_fill({29'd0, sd_unit}, sd_lba, 512);
		else begin
			sd_hr = disk_read({29'd0, sd_unit}, sd_lba);
			sd_reads = sd_reads + 1;
			if (sd_reads <= 64 || (sd_reads % 1024) == 0)
				$display("[SD] read slot %0d lba %0d (#%0d)%s", sd_unit, sd_lba, sd_reads,
				         (sd_hr != 0) ? "" : " -- no image");
		end
	end
	else if (sd_ack && sd_rd_act) begin
		if (!sd_buff_wr) begin
			sd_buff_dout <= sd_win ? host_byte({18'd0, sd_buff_addr}) : disk_byte({18'd0, sd_buff_addr});
			sd_buff_wr   <= 1;
			if (sd_buff_addr == 14'd511) begin
				sd_ack    <= 0;
				sd_rd_act <= 0;
			end
		end
		else if (sd_buff_addr != 14'd511) sd_buff_addr <= sd_buff_addr + 1'd1;
	end
	else if (sd_idle && sd_wr && hl_ok) begin
		sd_ack       <= 1;
		sd_wr_act    <= 1;
		sd_buff_addr <= 0;
		sd_rphase    <= 0;
		sd_win       <= (sd_lba >= WIN_BASE);
		sd_slot      <= sd_unit;
		sd_blk       <= sd_lba;
	end
	else if (sd_ack && sd_wr_act) begin
		if (sd_rphase) begin
			if (sd_win) host_put({18'd0, sd_buff_addr}, {24'd0, sd_buff_din});
			else        disk_put({18'd0, sd_buff_addr}, {24'd0, sd_buff_din});
			sd_rphase <= 0;
			if (sd_buff_addr == 14'd511) begin
				sd_ack    <= 0;
				sd_wr_act <= 0;
				if (sd_win) host_exec({29'd0, sd_slot}, sd_blk, 512);
				else begin
					disk_write({29'd0, sd_slot}, sd_blk);
					sd_writes = sd_writes + 1;
					if (sd_writes <= 64 || (sd_writes % 1024) == 0)
						$display("[SD] write slot %0d lba %0d (#%0d)", sd_slot, sd_blk, sd_writes);
				end
			end
			else sd_buff_addr <= sd_buff_addr + 1'd1;
		end
		else sd_rphase <= 1;
	end
end

// ---------------------------------------------------------------- ROM
reg [8*256-1:0] romfile;
initial begin
	if (!$value$plusargs("rom=%s", romfile)) romfile = "rom.hex";
	$readmemh(romfile, memsys.rom.mem);
	$display("[SIM] ROM %0s loaded", romfile);
end

endmodule
