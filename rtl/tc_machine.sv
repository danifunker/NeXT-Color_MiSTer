//============================================================================
//  tc_machine -- the NeXTstation Turbo Color: AP68040 on the TMC's 32-bit bus.
//
//  Structure from MacQuadra800_MiSTer rtl/quadra800.sv (the CPU bundle,
//  wombat_bus32, the service FSM, the platform beat port and its retained-
//  line fast paths); the address map and every device are the Turbo
//  Color's.  "HS n" = rom-dissassembly/hardware-summary.md section n.
//
//  Physical map (HS 0.2, 3.1, 14, 15; Previous cpu/memory.c memory_init()
//  for a Turbo Color):
//    $00000000-$01FFFFFF  boot ROM, 128 KB mirrored (Previous maps the ROM at
//                         $00000000 and at $01000000, 16 MB each, mask
//                         $1FFFF).  The ROM runs at $01000000; the reset
//                         vectors are read at $00000000.  Writes: bus error
//                         (Previous ROM_bank lput/wput -> M68000_BusError).
//    $02000000-$0201FFFF  device page (below), and its $021xxxxx alias
//    $02100000-$0211FFFF  (Previous maps IO_bank at both; the ROM uses the
//                         alias for most chips, HS 0.2).
//    $02200000-$0220FFFF  TMC (rtl/tc_tmc.sv), ADB at $02208000.
//    $04000000-$0BFFFFFF  DRAM: 4 banks x 32 MB (tc_machine translates to
//                         SDRAM, see ram_* below).  An absent bank reads 0
//                         and drops writes, never a bus error (HS 16.1
//                         item 6).
//    $0C000000-$0CFFFFFF  VRAM, 2 MB mirrored (Previous VRAM_color_bank,
//                         mask $1FFFFF), in DDR3 behind the platform port.
//    everything else      bus error: BMAP $020C0000 and NCC $02210000 above
//                         all, the ROM's two "must fault" probes (HS 15).
//
//  Device page: the register table of Previous ioMemTabTurbo.c, each entry
//  with its address mask; an access that hits no entry bus-errors, as in
//  Previous (ioMem.c).  Offsets o below are within the 128 KB page.
//
//  Platform beat port (quadra800.sv contract): aligned longwords, be[3] =
//  byte at addr+0 = wdata[31:24]; req level-held per beat, accepted on
//  req && !ack; a single-cycle ack with rdata.  mem_addr is LOCAL to the
//  selected memory: RAM = SDRAM address (bank n at n*32 MB), ROM = byte
//  offset in the 128 KB image, VRAM = byte offset in the 2 MB.
//============================================================================

module tc_machine
#(
	parameter CLK_HZ        = 33000000,
	parameter DIRECT_WRITES = 1           // store-buffer RAM writes push straight into the bridge FIFO
)
(
	input         clk,
	input         nreset,
	input         ce,
	input         config_reset,           // power-up / OSD reset (NVRAM default image)

	// installed RAM, sampled by the top while in reset:
	//   0 = 64 MB (2 x 32)  1 = 128 MB (4 x 32)  2 = 16 MB (2 x 8)  3 = 32 MB (1 x 32)
	input   [1:0] ram_cfg,

	// platform memory beat port
	output reg        mem_req,
	output reg        mem_write,
	output reg [26:2] mem_addr,
	output reg  [3:0] mem_be,
	output reg [31:0] mem_wdata,
	output reg  [1:0] mem_memsel,         // 0 RAM, 1 ROM, 2 VRAM
	input      [31:0] mem_rdata,
	input             mem_ack,
	// posted RAM writes straight into the SDRAM bridge's write FIFO
	output reg        mem_wp_valid,
	output reg [26:2] mem_wp_addr,
	output reg  [3:0] mem_wp_be,
	output reg [31:0] mem_wp_data,
	input             mem_wq_room,
	// the SDRAM bridge's retained line (SDRAM address space)
	input             mem_line_valid,
	input      [26:4] mem_line_tag,
	input     [127:0] mem_line_data,
	input             mem_line_pending,
	input      [26:4] mem_line_pending_tag,

	// video control (to the scan-out)
	output     [31:0] tmc_hreg,
	output     [31:0] tmc_vreg,
	output            video_enable,
	output      [2:0] pal_we,           // Bt463 display-palette writes (R, G, B one-hot)
	output      [3:0] pal_n,
	output      [7:0] pal_d,
	input             vbl_pulse,          // clk domain, one pulse per frame

	// peripherals
	input      [10:0] ps2_key,
	input      [24:0] ps2_mouse,
	input      [32:0] timestamp,
	input             pot_on,             // NVRAM default: power-on test
	input      [95:0] boot_cmd,           // NVRAM default: boot command

	// SCSI targets on MiSTer SD slots (tc_scsi: hps_io 8-bit buffer, WIDE=0).
	// Slots 0, 1 = disks (targets 0, 1), 3 = CD-ROM (target 3, and the
	// slot Main answers the response-window LBAs on).  One engine: the
	// request goes to slot sd_unit, and only that slot's ack is fed back.
	input       [5:0] img_mounted,
	input             img_readonly,
	input      [63:0] img_size,
	output      [2:0] sd_unit,
	output     [31:0] sd_lba,
	output            sd_rd,
	output            sd_wr,
	input             sd_ack,
	input      [13:0] sd_buff_addr,
	input       [7:0] sd_buff_dout,
	output      [7:0] sd_buff_din,
	input             sd_buff_wr,
	output            sd_busy,

	// the floppy drive's image on its own SD slot (4, as the mono core):
	// rtl/next_floppy.sv.  img_readonly/img_size and the sd_buff_* bus are
	// shared with the SCSI slots; the floppy acts only on its own ack.
	input             fimg_mounted,
	output     [31:0] fsd_lba,
	output            fsd_rd,
	output            fsd_wr,
	input             fsd_ack,
	output      [7:0] fsd_buff_din,

	// Ethernet: the OSD "Connected" switch, and the bridge's mailbox port
	// (one 64-bit DDR3 word at a time, clk_sys; tc_enet_ddr in the top)
	input             enet_connected,
	output            enet_m_req,
	output            enet_m_we,
	output     [28:0] enet_m_addr,
	output     [63:0] enet_m_wdata,
	input      [63:0] enet_m_rdata,
	input             enet_m_ack,

	output            led,
	output            reset_req,          // KMS magic reset: the top resets the machine

	// sound out (tc_kms): signed 16-bit stereo, new value per 44.1 kHz tick
	output     [15:0] audio_l,
	output     [15:0] audio_r,

	// debug
	output            dbg_berr,
	output     [31:0] dbg_berr_addr,
	output    [255:0] debug_status,
	output    [127:0] debug_status2,
	output            debug_fault,
	output            debug_halted,
	output     [31:0] dbg_intstat,
	output      [2:0] dbg_ipl
);

localparam [1:0] MSEL_RAM  = 2'd0,
                 MSEL_ROM  = 2'd1,
                 MSEL_VRAM = 2'd2;

//----------------------------------------------------------------------------
// RAM banks.  Bank n = $04000000 + n*$02000000 (HS 3.1) lives at SDRAM
// n*32 MB; inside a bank the offset is masked to the bank's size, so an
// 8 MB bank aliases every 8 MB -- exactly what mem_bank_size_t expects
// (HS 3.3: $89ABCDEF at +$800000 reads back at +0 -> 8 MB pair).
//----------------------------------------------------------------------------
// bank size code: 0 absent, 1 = 32 MB, 2 = 8 MB
function [1:0] bank_size;
	input [1:0] cfg;
	input [1:0] bank;
	begin
		case (cfg)
		2'd0:    bank_size = (bank < 2'd2) ? 2'd1 : 2'd0;   // 64 MB
		2'd1:    bank_size = 2'd1;                          // 128 MB
		2'd2:    bank_size = (bank < 2'd2) ? 2'd2 : 2'd0;   // 16 MB
		default: bank_size = (bank == 2'd0) ? 2'd1 : 2'd0;  // 32 MB
		endcase
	end
endfunction

function [1:0] ram_bank;          // valid only when a[31:25] is a DRAM bank
	input [31:2] a;
	begin
		ram_bank = a[26:25] - 2'd2;   // $04 -> 0, $06 -> 1, $08 -> 2, $0A -> 3
	end
endfunction

function ram_window;              // $04000000-$0BFFFFFF
	input [31:2] a;
	begin
		ram_window = (a[31:28] == 4'h0) && (a[27:25] >= 3'd2) && (a[27:25] <= 3'd5);
	end
endfunction

function ram_present;
	input [31:2] a;
	begin
		ram_present = ram_window(a) && (bank_size(ram_cfg, ram_bank(a)) != 2'd0);
	end
endfunction

function [26:2] ram_sdram;        // physical -> SDRAM longword address
	input [31:2] a;
	begin
		ram_sdram = (bank_size(ram_cfg, ram_bank(a)) == 2'd2) ?
		            {ram_bank(a), 2'b00, a[22:2]} : {ram_bank(a), a[24:2]};
	end
endfunction

// SDRAM line tag -> the canonical physical address of that line
wire [31:4] line_phys_tag = {4'h0, {1'b0, mem_line_tag[26:25]} + 3'd2, mem_line_tag[24:4]};

//----------------------------------------------------------------------------
// decode of a beat address; the table walker sees the same physical map
//   0 RAM   1 ROM   2 VRAM   3 device page   4 bus error   5 TMC   6 open
//----------------------------------------------------------------------------
function [2:0] decode;
	input [31:2] a;
	begin
		if (a[31:25] == 7'd0)                          decode = 3'd1;   // $00-$01: ROM
		else if (a[31:24] == 8'h02) begin
			if (a[23:17] == 7'b0000000 || a[23:17] == 7'b0001000) decode = 3'd3;  // $0200/$0210 pages
			else if (a[23:16] == 8'h20)                decode = 3'd5;   // $0220xxxx TMC
			else                                       decode = 3'd4;   // BMAP, NCC, NBIC ...
		end
		else if (ram_window(a))                        decode = ram_present(a) ? 3'd0 : 3'd6;
		else if (a[31:24] == 8'h0C)                    decode = 3'd2;   // VRAM
		else                                           decode = 3'd4;
	end
endfunction

// Device page table (Previous ioMemTabTurbo.c, address masks in comments).
// o = offset in the 128 KB page, longword granular.
localparam [3:0] D_NONE = 4'd0, D_DMA = 4'd1, D_ENET = 4'd2, D_INTS = 4'd3,
                 D_INTM = 4'd4, D_ZERO = 4'd5, D_SCR1 = 4'd6, D_SCR2 = 4'd7,
                 D_KMS = 4'd8, D_ESP = 4'd9, D_FLP = 4'd10, D_HCLK = 4'd11,
                 D_SCC = 4'd12, D_EVC = 4'd13, D_DAC = 4'd14;

function [3:0] dev_decode;
	input [16:2] o;
	reg [16:0] a;
	reg [16:0] m1e;   // a & $1EFFF (DMA: bit 12 ignored)
	begin
		a   = {o, 2'b00};
		m1e = a & 17'h1EFFF;
		if (m1e == 17'h00010 || m1e == 17'h00040 || m1e == 17'h00080 || m1e == 17'h00090 ||
		    m1e == 17'h000D0 || m1e == 17'h00110 || m1e == 17'h00150)             dev_decode = D_DMA;   // TDMA_CSR
		else if ((m1e >= 17'h04010 && m1e <= 17'h0401C) || (m1e >= 17'h04040 && m1e <= 17'h04050) ||
		         (m1e >= 17'h04080 && m1e <= 17'h0409C) || (m1e >= 17'h040D0 && m1e <= 17'h040DC) ||
		         (m1e >= 17'h04100 && m1e <= 17'h0411C) || (m1e >= 17'h04140 && m1e <= 17'h0415C) ||
		         m1e == 17'h04210 || m1e == 17'h04240 || m1e == 17'h04280 || m1e == 17'h04290 ||
		         m1e == 17'h042D0 || m1e == 17'h04310 || m1e == 17'h04350)       dev_decode = D_DMA;   // channel regs
		else if ((a & 17'h1F000) == 17'h06000)                                    dev_decode = D_ENET;  // $1F00F
		else if ((a & 17'h1F800) == 17'h07000)                                    dev_decode = D_INTS;  // $1F803
		else if ((a & 17'h1F800) == 17'h07800)                                    dev_decode = D_INTM;
		else if ((a & 17'h1E003) == 17'h08000)                                    dev_decode = D_ZERO;  // DSP $1E007
		else if ((a & 17'h1F000) == 17'h0C000)                                    dev_decode = D_SCR1;  // $1F803 (C000, C800)
		else if ((a & 17'h1F000) == 17'h0D000)                                    dev_decode = D_SCR2;  // $1F003
		else if ((a & 17'h1F000) == 17'h0E000)                                    dev_decode = D_KMS;   // $1F00F
		else if ((a & 17'h1F000) == 17'h0F000 && (a & 17'h0000F) <= 17'h4)        dev_decode = D_ZERO;  // printer
		else if ((a & 17'h1E003) == 17'h10000)                                    dev_decode = D_ZERO;  // brightness
		else if ((a & 17'h1E000) == 17'h12000)                                    dev_decode = D_ZERO;  // GPIO: $02112004 reads 0 (HS 14)
		else if ((a & 17'h1E1F0) == 17'h14000 || (a & 17'h1E1FC) == 17'h14020)    dev_decode = D_ESP;   // $1E1FF
		else if ((a & 17'h1E1F0) == 17'h14100 && (a & 17'h0000F) <= 17'h8)        dev_decode = D_FLP;   // +0,+4,+8
		else if ((a & 17'h1E007) == 17'h16000 || (a & 17'h1E007) == 17'h16004)   dev_decode = D_HCLK;  // $1E007
		else if ((a & 17'h1E007) == 17'h18000 || (a & 17'h1E007) == 17'h18004)   dev_decode = D_SCC;   // $1E007
		else if ((a & 17'h1E003) == 17'h1A000)                                    dev_decode = D_EVC;   // $1E003
		else if ((a & 17'h1E003) == 17'h1C000)                                    dev_decode = D_DAC;   // $1E003
		else                                                                      dev_decode = D_NONE;
	end
endfunction

//----------------------------------------------------------------------------
// CPU bundle and the transaction-to-beat adapter (quadra800.sv)
//----------------------------------------------------------------------------
wire        bus_req, bus_write, bus_instr;
wire  [1:0] bus_size;
wire [31:0] bus_addr, bus_wdata;
wire  [2:0] bus_fc;
wire        bus_ack;
wire [31:0] bus_rdata;
wire        bus_ack_adapter;
wire [31:0] bus_rdata_adapter;
wire        bus_adapter_active;
wire        bus_req_adapter;
reg         bus_line_ack;
reg  [31:0] bus_line_rdata;
reg         bus_miss_ack;
reg  [31:0] bus_miss_rdata;

assign bus_ack   = bus_line_ack || bus_miss_ack || bus_ack_adapter;
assign bus_rdata = bus_line_ack ? bus_line_rdata :
                   bus_miss_ack ? bus_miss_rdata : bus_rdata_adapter;

wire        walker_req, walker_we;
wire [31:0] walker_addr, walker_wdat;
reg         walker_ack;
reg  [31:0] walker_data;
reg         walker_berr;

reg         cpu_berr;
wire  [2:0] ipl;
reg         snoop_stb;        // a DMA write landed (service FSM below)
reg  [31:2] snoop_line;

wombat_cpu #(.AP040_FPU_REVISION(8'h41)) cpu (
	.clk(clk),
	.nreset(nreset),
	.ce(ce),
	.stall_hold(1'b0),
	.dbg_stall_flt(),

	.ipl(~ipl),
	.ipl_autovector(1'b1),
	.berr(cpu_berr),
	.cache_line_valid(mem_line_valid),
	.cache_line_tag(line_phys_tag),
	.cache_line_data(mem_line_data),
	.store_buffer_ok(1'b1),

	.bus_req(bus_req),
	.bus_write(bus_write),
	.bus_instr(bus_instr),
	.bus_size(bus_size),
	.bus_addr(bus_addr),
	.bus_wdata(bus_wdata),
	.bus_fc(bus_fc),
	.bus_ack(bus_ack),
	.bus_rdata(bus_rdata),

	.walker_req(walker_req),
	.walker_we(walker_we),
	.walker_addr(walker_addr),
	.walker_wdat(walker_wdat),
	.walker_ack(walker_ack),
	.walker_data(walker_data),
	.walker_berr(walker_berr),

	.snoop_stb(snoop_stb),               // DMA write: drop the D-cache line
	.snoop_addr({snoop_line, 2'b00}),

	.nresetout(),
	.nmi_ack_toggle(),
	.cacr_out(),
	.vbr_out(),
	.debug_busy(),
	.debug_fault(debug_fault),
	.debug_halted(debug_halted),
	.debug_status(debug_status),
	.debug_status2(debug_status2)
);

wire        b_req, b_write;
wire [31:2] b_addr;
wire  [3:0] b_be;
wire [31:0] b_wdata;
reg         b_ack;
reg  [31:0] b_rdata;

wombat_bus32 bus32 (
	.clk(clk),
	.nreset(nreset),
	.ce(ce),

	.t_req(bus_req_adapter),
	.t_write(bus_write),
	.t_size(bus_size),
	.t_addr(bus_addr),
	.t_wdata(bus_wdata),
	.t_berr(cpu_berr),
	.t_ack(bus_ack_adapter),
	.t_rdata(bus_rdata_adapter),
	.t_active(bus_adapter_active),

	.b_req(b_req),
	.b_write(b_write),
	.b_addr(b_addr),
	.b_be(b_be),
	.b_wdata(b_wdata),
	.b_ack(b_ack),
	.b_rdata(b_rdata)
);

//----------------------------------------------------------------------------
// Devices (tc_machine device port: 1-cycle stb, 1-cycle ack later)
//----------------------------------------------------------------------------
reg         io_stb;
reg         io_we;
reg  [16:2] io_addr;          // offset in the device page / TMC window
reg   [3:0] io_be;
reg  [31:0] io_wdata;
reg   [3:0] io_dev;
reg         io_tmc;           // the access is in the TMC window

wire dev_rst = !nreset;

wire        kms_power_key;
wire        int_snd_ovrun;
wire        so_req, so_ack, so_avail;  // tc_kms <-> tc_tdma sound out channel
wire [31:0] so_rdata;

// interrupt sources (levels), Previous sysReg.h bit names (includes/sysReg.h:24-55)
wire        int_power, int_keymouse, int_timer, int_video, int_tmc_nmi, int_kms_nmi;
wire        int_scsi, int_scsi_dma, int_snd_out_dma, int_snd_in_dma, int_printer_dma,
            int_dsp_dma, int_en_tx_dma, int_en_rx_dma, int_en_tx, int_en_rx;
// the floppy (next_floppy, below) and its share of the SCSI DMA channel
wire        int_floppy, flp_select, flp_req, flp_wr, flp_bwe, flp_done;
wire [10:0] flp_len;
wire  [9:0] flp_addr;
wire  [7:0] flp_bwdata, flp_bq;
wire  [1:0] softint;
wire        timer_ipl7;
wire [31:0] int_src = {int_tmc_nmi | int_kms_nmi,  // 31 INT_NMI
                       1'b0,                       // 30 INT_PFAIL (parity: none)
                       int_timer,                  // 29 INT_TIMER
                       int_en_tx_dma,              // 28 INT_EN_TX_DMA
                       int_en_rx_dma,              // 27 INT_EN_RX_DMA
                       int_scsi_dma,               // 26 INT_SCSI_DMA
                       1'b0,                       // 25 INT_DISK_DMA (MO: none)
                       int_printer_dma,            // 24 INT_PRINTER_DMA
                       int_snd_out_dma,            // 23 INT_SND_OUT_DMA
                       int_snd_in_dma,             // 22 INT_SND_IN_DMA
                       1'b0,                       // 21 INT_SCC_DMA
                       int_dsp_dma,                // 20 INT_DSP_DMA
                       6'd0,                       // 19..14
                       int_video,                  // 13 INT_DISK = TMC video / ADB
                       int_scsi,                   // 12 INT_SCSI (tc_scsi: ENABLE_INT & STAT_INT)
                       1'b0,                       // 11 INT_PRINTER
                       int_en_tx,                  // 10 INT_EN_TX (tc_enet TX status & mask)
                       int_en_rx,                  // 9 INT_EN_RX (tc_enet RX status & mask)
                       int_snd_ovrun,              // 8 INT_SOUND_OVRUN (tc_kms sound out underrun)
                       int_floppy,                 // 7 INT_PHONE = the 82077 (next_floppy)
                       2'd0,                       // 6..5
                       1'b0,                       // 4
                       int_keymouse,               // 3 INT_KEYMOUSE
                       int_power,                  // 2 INT_POWER
                       softint};                   // 1..0 INT_SOFT2/1

// SCR1 / SCR2 / RTC
wire [31:0] scr_rdata;  wire scr_ack;
tc_scr scr (
	.clk(clk), .reset(dev_rst), .config_reset(config_reset),
	.stb(io_stb && (io_dev == D_SCR1 || io_dev == D_SCR2) && !io_tmc), .we(io_we),
	.sel_scr2(io_dev == D_SCR2), .be(io_be), .wdata(io_wdata),
	.rdata(scr_rdata), .ack(scr_ack),
	.timestamp(timestamp), .ram_cfg(ram_cfg), .pot_on(pot_on), .boot_cmd(boot_cmd),
	.power_key(kms_power_key), .int_power(int_power),
	.led(led), .timer_ipl7(timer_ipl7), .softint(softint),
	.dsp_reset_n(), .scr2_out()
);

// interrupt status / mask
wire [31:0] intc_rdata; wire intc_ack;
tc_intc intc (
	.clk(clk), .reset(dev_rst),
	.src(int_src), .timer_ipl7(timer_ipl7),
	.stb(io_stb && (io_dev == D_INTS || io_dev == D_INTM) && !io_tmc), .we(io_we),
	.sel_mask(io_dev == D_INTM), .be(io_be), .wdata(io_wdata),
	.rdata(intc_rdata), .ack(intc_ack),
	.ipl(ipl), .status(dbg_intstat)
);
assign dbg_ipl = ipl;

// event counter + hardclock
wire [31:0] tim_rdata; wire tim_ack;
tc_timers #(.CLK_HZ(CLK_HZ)) timers (
	.clk(clk), .reset(dev_rst),
	.stb(io_stb && (io_dev == D_EVC || io_dev == D_HCLK) && !io_tmc), .we(io_we),
	.sel_hc(io_dev == D_HCLK), .a2(io_addr[2]), .be(io_be), .wdata(io_wdata),
	.rdata(tim_rdata), .ack(tim_ack),
	.int_timer(int_timer)
);

// TMC
wire [31:0] tmc_rdata; wire tmc_ack, tmc_berr;
tc_tmc tmc (
	.clk(clk), .reset(dev_rst),
	.stb(io_stb && io_tmc), .we(io_we), .addr(io_addr[15:2]), .be(io_be), .wdata(io_wdata),
	.rdata(tmc_rdata), .ack(tmc_ack), .berr(tmc_berr),
	.vbl_pulse(vbl_pulse),
	.hreg(tmc_hreg), .vreg(tmc_vreg), .video_enable(video_enable),
	.int_video(int_video), .int_nmi(int_tmc_nmi), .control()
);

// Bt463
wire [31:0] dac_rdata; wire dac_ack;
tc_bt463 dac (
	.clk(clk), .reset(dev_rst),
	.stb(io_stb && io_dev == D_DAC && !io_tmc), .we(io_we), .be(io_be), .wdata(io_wdata),
	.rdata(dac_rdata), .ack(dac_ack),
	.pal_we(pal_we), .pal_n(pal_n), .pal_d(pal_d)
);

// KMS (keyboard / mouse / sound out; the sound-out DMA channel is tc_tdma's)
wire [31:0] kms_rdata; wire kms_ack;
tc_kms #(.CLK_HZ(CLK_HZ)) kms (
	.clk(clk), .reset(dev_rst),
	.stb(io_stb && io_dev == D_KMS && !io_tmc), .we(io_we), .addr(io_addr[3:2]), .be(io_be), .wdata(io_wdata),
	.rdata(kms_rdata), .ack(kms_ack),
	.ps2_key(ps2_key), .ps2_mouse(ps2_mouse),
	.int_keymouse(int_keymouse), .nmi(int_kms_nmi), .power_key(kms_power_key),
	.reset_req(reset_req), .dbg_cmd(),
	.so_req(so_req), .so_ack(so_ack), .so_rdata(so_rdata), .so_avail(so_avail),
	.int_snd_ovrun(int_snd_ovrun), .audio_l(audio_l), .audio_r(audio_r)
);

// PC-chip DMA channels (HS 7): rtl/tc_tdma.sv, every channel's registers;
// the SCSI, Ethernet TX/RX and sound out channels move data through the
// memory master below.
wire [31:0] dma_rdata, enet_rdata, esp_rdata, scc_rdata;
wire        dma_ack, enet_ack, esp_ack, scc_ack;

wire        dm_req, dm_we;            // tc_tdma memory master (one longword per request)
wire [31:2] dm_addr;
wire  [3:0] dm_be;
wire [31:0] dm_wdata;
reg         dm_ack, dm_err;
reg  [31:0] dm_rdata;

wire        ch_req, ch_we, ch_eval, ch_ack, ch_err;   // tc_scsi <-> tc_tdma SCSI channel
wire [31:0] ch_wdata, ch_rdata;
wire        ch_enable, ch_dev2m, ch_room, ch_at_limit, ch_bufreset;
wire  [3:0] ch_bufofs;

wire        et_req, et_ack, et_err, et_enable, et_room, et_done;   // tc_enet <-> Ethernet TX channel
wire [31:0] et_rdata;
wire  [2:0] et_n;
wire        er_req, er_ack, er_err, er_enable, er_room, er_eof, er_full;   // ... RX channel
wire [31:0] er_wdata;
wire  [2:0] er_n;
wire  [3:0] er_nibble;

tc_tdma dma (
	.clk(clk), .reset(dev_rst),
	.stb(io_stb && io_dev == D_DMA && !io_tmc), .we(io_we),
	.addr(io_addr[16:2]), .be(io_be), .wdata(io_wdata),
	.rdata(dma_rdata), .ack(dma_ack),
	.m_req(dm_req), .m_we(dm_we), .m_addr(dm_addr), .m_be(dm_be), .m_wdata(dm_wdata),
	.m_ack(dm_ack), .m_rdata(dm_rdata), .m_err(dm_err),
	.sc_req(ch_req), .sc_we(ch_we), .sc_wdata(ch_wdata), .sc_eval(ch_eval),
	.sc_ack(ch_ack), .sc_rdata(ch_rdata), .sc_err(ch_err),
	.sc_enable(ch_enable), .sc_dev2m(ch_dev2m), .sc_room(ch_room), .sc_at_limit(ch_at_limit),
	.sc_bufreset(ch_bufreset), .sc_bufofs(ch_bufofs),
	.et_req(et_req), .et_ack(et_ack), .et_rdata(et_rdata), .et_n(et_n), .et_err(et_err),
	.et_enable(et_enable), .et_room(et_room), .et_done(et_done),
	.er_req(er_req), .er_wdata(er_wdata), .er_n(er_n), .er_ack(er_ack), .er_err(er_err),
	.er_enable(er_enable), .er_room(er_room), .er_eof(er_eof), .er_full(er_full),
	.er_nibble(er_nibble),
	.so_req(so_req), .so_ack(so_ack), .so_rdata(so_rdata), .so_avail(so_avail),
	.int_scsi_dma(int_scsi_dma), .int_snd_out_dma(int_snd_out_dma),
	.int_snd_in_dma(int_snd_in_dma), .int_printer_dma(int_printer_dma),
	.int_dsp_dma(int_dsp_dma), .int_en_tx_dma(int_en_tx_dma), .int_en_rx_dma(int_en_rx_dma)
);

// NCR 53C90 + SCSI DMA control + targets on the SD slots (HS 9):
// rtl/tc_scsi.sv.  The floppy's share of the channel is tied off inside.
tc_scsi #(.CLK_HZ(CLK_HZ)) esp (
	.clk(clk), .reset(dev_rst),
	.stb(io_stb && io_dev == D_ESP && !io_tmc), .we(io_we),
	.addr(io_addr[5:2]), .be(io_be), .wdata(io_wdata),
	.rdata(esp_rdata), .ack(esp_ack),
	.ch_req(ch_req), .ch_we(ch_we), .ch_wdata(ch_wdata), .ch_eval(ch_eval),
	.ch_ack(ch_ack), .ch_rdata(ch_rdata), .ch_err(ch_err),
	.ch_enable(ch_enable), .ch_dev2m(ch_dev2m), .ch_room(ch_room), .ch_at_limit(ch_at_limit),
	.ch_bufreset(ch_bufreset), .ch_bufofs(ch_bufofs),
	.int_scsi(int_scsi),
	.img_mounted(img_mounted), .img_readonly(img_readonly), .img_size(img_size),
	.sd_unit(sd_unit), .sd_lba(sd_lba), .sd_rd(sd_rd), .sd_wr(sd_wr), .sd_ack_in(sd_ack),
	.sd_buff_addr(sd_buff_addr), .sd_buff_dout(sd_buff_dout), .sd_buff_din(sd_buff_din),
	.sd_buff_wr(sd_buff_wr), .sd_busy(sd_busy), .sd_hold(1'b0), .cd_fwd_stb(),
	.flp_select(flp_select), .flp_req(flp_req), .flp_wr(flp_wr), .flp_len(flp_len),
	.flp_addr(flp_addr), .flp_bwe(flp_bwe), .flp_bwdata(flp_bwdata), .flp_bq(flp_bq),
	.flp_done(flp_done)
);

// AT&T 7213 Ethernet (HS 8): rtl/tc_enet.sv, internal loopback for the
// POST, and with the OSD's "Connected" a twisted-pair link through
// NeXT_MiSTer's bridge (rtl/next_enet_bridge.sv) to Main's next_enet daemon
// (a DDR3 mailbox at $1FF00000).  Its data moves through tc_tdma's
// Ethernet TX/RX channels.
wire        btx_req, btx_rd, btx_ack, btx_done;
wire [10:0] btx_len, btx_addr;
wire  [7:0] btx_q;
wire        brx_start, brx_valid, brx_ready;
wire [10:0] brx_len;
wire  [7:0] brx_data;
wire [47:0] enet_mac;
next_enet_bridge #(.CLK_HZ(CLK_HZ)) enet_bridge (
	.clk(clk), .reset(dev_rst), .enable(enet_connected),
	.btx_req(btx_req), .btx_len(btx_len), .btx_addr(btx_addr), .btx_rd(btx_rd),
	.btx_q(btx_q), .btx_ack(btx_ack), .btx_done(btx_done),
	.brx_start(brx_start), .brx_len(brx_len), .brx_valid(brx_valid),
	.brx_data(brx_data), .brx_ready(brx_ready),
	.guest_mac(enet_mac),
	.m_req(enet_m_req), .m_we(enet_m_we), .m_addr(enet_m_addr), .m_wdata(enet_m_wdata),
	.m_rdata(enet_m_rdata), .m_ack(enet_m_ack)
);
tc_enet enet (
	.clk(clk), .reset(dev_rst),
	.stb(io_stb && io_dev == D_ENET && !io_tmc), .we(io_we),
	.addr(io_addr[3:2]), .be(io_be), .wdata(io_wdata),
	.rdata(enet_rdata), .ack(enet_ack),
	.et_req(et_req), .et_ack(et_ack), .et_rdata(et_rdata), .et_n(et_n), .et_err(et_err),
	.et_enable(et_enable), .et_room(et_room), .et_done(et_done),
	.er_req(er_req), .er_wdata(er_wdata), .er_n(er_n), .er_ack(er_ack), .er_err(er_err),
	.er_enable(er_enable), .er_room(er_room), .er_eof(er_eof), .er_full(er_full),
	.er_nibble(er_nibble),
	.int_en_tx(int_en_tx), .int_en_rx(int_en_rx),
	.connected(enet_connected),
	.btx_req(btx_req), .btx_len(btx_len), .btx_addr(btx_addr), .btx_rd(btx_rd),
	.btx_q(btx_q), .btx_ack(btx_ack), .btx_done(btx_done),
	.brx_start(brx_start), .brx_len(brx_len), .brx_valid(brx_valid),
	.brx_data(brx_data), .brx_ready(brx_ready),
	.guest_mac(enet_mac)
);
tc_scc scc (
	.clk(clk), .reset(dev_rst),
	.stb(io_stb && io_dev == D_SCC && !io_tmc), .we(io_we),
	.a2(io_addr[2]), .be(io_be), .wdata(io_wdata),
	.rdata(scc_rdata), .ack(scc_ack));

// Floppy: the Intel 82077 + the NeXT external control register at
// $02014100..$02014108 (HS 10; Previous floppy.c, ioMemTabTurbo.c:197-208):
// rtl/next_floppy.sv, the mono core's controller, with the Turbo
// NeXTstation colour ID bytes at +3/+6 (floppy.c:1307-1335).  Drive 0 is
// always fitted (a 2.88 MB drive: 720K, 1.44M and 2.88M images); its
// sector data moves through the SCSI DMA channel (tc_scsi flp_*) while
// CTRL_82077 selects it.
// The controller has next_system's 16-bit port (addr[3:1] word, be[1] the
// even byte).  This bus is 32-bit with byte +n on lane 3 - (n & 3), so an
// access is presented as its upper half (+0,+1: lanes 3,2), then its lower
// half (+2,+3: lanes 1,0), one clock each, only for halves with enabled
// lanes -- a FIFO read (+5) then pops once, as a byte access must.
wire [15:0] fc_rdata;
reg   [1:0] fc_st;                // 0 idle, 1 upper half, 2 lower half
reg         fc_we;
reg   [3:0] fc_be;
reg   [1:0] fc_a;                 // io_addr[3:2]: the longword at +0, +4, +8
reg  [31:0] fc_wd;
wire        fc_lo = (fc_st == 2'd2);

// next_floppy takes a mount only outside its reset (its medium block is the
// else-branch of `if (reset)`), and a mount can arrive while the machine is
// held there -- the sim mounts inside the reset window, as Main does at core
// start, and OSD/KMS resets hold dev_rst.  Latch the mount with its size and
// write protect (img_size/img_readonly are shared with the SCSI slots) and
// hand it over on the first clock out of reset; tc_scsi likewise keeps its
// mount state outside the reset.
reg         fm_pend;
reg  [31:0] fm_size;              // the drive takes images up to 2.88 MB
reg         fm_ro;
always @(posedge clk) begin
	if (fimg_mounted) begin
		fm_pend <= 1'b1; fm_size <= img_size[31:0]; fm_ro <= img_readonly;
	end
	else if (!dev_rst) fm_pend <= 1'b0;
end
wire        fm_go = fm_pend && !dev_rst;

next_floppy #(.CLK_HZ(CLK_HZ), .RSV3(8'h03), .RSV6(8'hC0)) floppy (
	.clk(clk), .reset(dev_rst),
	.sel(fc_st != 2'd0), .addr({fc_a, fc_lo, 1'b0}), .we(fc_we),
	.be(fc_lo ? fc_be[1:0] : fc_be[3:2]),
	.wdata(fc_lo ? fc_wd[15:0] : fc_wd[31:16]),
	.rdata(fc_rdata),
	.int_floppy(int_floppy), .flp_select(flp_select),
	.mo_gpo(1'b0),                // no optical drive on a NeXTstation
	.buf_addr(flp_addr), .buf_we(flp_bwe), .buf_wdata(flp_bwdata), .buf_q(flp_bq),
	.buf_len(flp_len), .dma_req(flp_req), .dma_wr(flp_wr), .dma_done(flp_done),
	.img_mounted({1'b0, fm_go}), .img_readonly(fm_ro), .img_size({32'd0, fm_size}),
	.sd_unit(), .sd_lba(fsd_lba), .sd_rd(fsd_rd), .sd_wr(fsd_wr), .sd_ack(fsd_ack),
	.sd_buff_addr(sd_buff_addr[8:0]), .sd_buff_dout(sd_buff_dout),
	.sd_buff_din(fsd_buff_din), .sd_buff_wr(sd_buff_wr)
);

reg        flp_ack;
reg [31:0] flp_rdata;
reg        zero_ack;
always @(posedge clk) begin
	flp_ack  <= 0;
	zero_ack <= io_stb && io_dev == D_ZERO && !io_tmc;
	case (fc_st)
	2'd0: if (io_stb && io_dev == D_FLP && !io_tmc) begin
		fc_we <= io_we; fc_be <= io_be; fc_a <= io_addr[3:2]; fc_wd <= io_wdata;
		flp_rdata <= 32'd0;
		fc_st <= (io_be[3:2] != 2'b00) ? 2'd1 : 2'd2;
	end
	2'd1: begin
		flp_rdata[31:16] <= fc_rdata;
		if (fc_be[1:0] != 2'b00) fc_st <= 2'd2;
		else begin fc_st <= 2'd0; flp_ack <= 1; end
	end
	default: begin
		flp_rdata[15:0] <= fc_rdata;
		fc_st <= 2'd0; flp_ack <= 1;
	end
	endcase
	if (dev_rst) fc_st <= 2'd0;
end

wire        io_ack   = tmc_ack | scr_ack | intc_ack | tim_ack | dac_ack | kms_ack |
                       dma_ack | enet_ack | esp_ack | scc_ack | flp_ack | zero_ack;
wire [31:0] io_rdata = tmc_ack  ? tmc_rdata  : scr_ack  ? scr_rdata  :
                       intc_ack ? intc_rdata : tim_ack  ? tim_rdata  :
                       dac_ack  ? dac_rdata  : kms_ack  ? kms_rdata  :
                       dma_ack  ? dma_rdata  : enet_ack ? enet_rdata :
                       esp_ack  ? esp_rdata  : scc_ack  ? scc_rdata  :
                       flp_ack  ? flp_rdata  : 32'd0;
wire        io_berr  = tmc_ack && tmc_berr;

//----------------------------------------------------------------------------
// Beat service: arbitrate CPU vs table walker, decode, dispatch
//----------------------------------------------------------------------------
localparam S_IDLE = 3'd0, S_MEM = 3'd1, S_IO = 3'd2, S_BERR = 3'd3, S_OPEN = 3'd4;
reg  [2:0] svc;
reg        svc_walker;
reg        svc_bus_direct;
reg        svc_dma;           // the beat in S_MEM is tc_tdma's
reg [31:2] svc_addr;

// The PC chip's DMA is the machine's other bus master (quadra800.sv's SONIC
// pattern): one longword beat per request, alternating with the CPU's so
// neither starves, through the ordinary RAM port -- so sdram_beat32 drops
// its retained line on a DMA write exactly as on a CPU write, and a DMA read
// sees every posted CPU write (the bridge drains its FIFO before a read).
// A DMA write pulses the 68040's snoop, which drops the D-cache's copy of
// the line.  Only present DRAM is a DMA target; anything else answers
// m_err, which stops the channel with BUSEXC (Previous dma.c:445-449).
reg        dma_turn;          // the CPU had the last beat

wire       walker_pend = walker_req && walker_armed;
reg        walker_armed;

// retained-line fast paths (quadra800.sv), on the SDRAM address of the beat
wire [26:2] b_sdram   = ram_sdram(b_addr);
wire [26:2] bus_sdram = ram_sdram(bus_addr[31:2]);

wire line_cpu_match = b_req && !b_write && (decode(b_addr) == 3'd0) &&
                      mem_line_valid && (b_sdram[26:4] == mem_line_tag);
wire line_cpu_wait  = b_req && !b_write && (decode(b_addr) == 3'd0) &&
                      mem_line_pending && (b_sdram[26:4] == mem_line_pending_tag);
wire [31:0] line_cpu_data = (b_addr[3:2] == 2'd0) ? mem_line_data[127:96] :
                            (b_addr[3:2] == 2'd1) ? mem_line_data[95:64]  :
                            (b_addr[3:2] == 2'd2) ? mem_line_data[63:32]  :
                                                    mem_line_data[31:0];

wire bus_ram_eligible = (svc == S_IDLE) && !walker_pend && !cpu_berr &&
                        !bus_miss_ack && !bus_line_ack && !bus_adapter_active &&
                        !bus_ack_adapter && bus_req && !bus_write &&
                        (bus_size == 2'd2) && (bus_addr[1:0] == 2'b00) &&
                        (decode(bus_addr[31:2]) == 3'd0);
wire bus_line_match = bus_ram_eligible && mem_line_valid &&
                      (bus_sdram[26:4] == mem_line_tag);
wire bus_line_wait  = bus_ram_eligible && mem_line_pending &&
                      (bus_sdram[26:4] == mem_line_pending_tag);
wire bus_first_miss = bus_ram_eligible && !bus_line_match && !bus_line_wait;
wire [31:0] bus_line_data = (bus_addr[3:2] == 2'd0) ? mem_line_data[127:96] :
                            (bus_addr[3:2] == 2'd1) ? mem_line_data[95:64]  :
                            (bus_addr[3:2] == 2'd2) ? mem_line_data[63:32]  :
                                                      mem_line_data[31:0];

// direct RAM writes into the bridge FIFO (quadra800.sv, P214 split stores)
wire  [2:0] bus_wr_bytes = (bus_size == 2'd0) ? 3'd1 : (bus_size == 2'd1) ? 3'd2 : 3'd4;
wire  [2:0] bus_wr_end   = {1'b0, bus_addr[1:0]} + bus_wr_bytes;
wire [31:0] bus_wr_left  = (bus_size == 2'd0) ? {bus_wdata[7:0], 24'd0} :
                           (bus_size == 2'd1) ? {bus_wdata[15:0], 16'd0} : bus_wdata;
reg         wr_split_pend;
reg  [26:2] wr_split_addr;
reg   [3:0] wr_split_be;
reg  [31:0] wr_split_data;
wire        bus_wr_span  = (bus_wr_end > 3'd4);
// A store spanning into the next longword stays on the direct path only
// when that longword is in the same aligned 8 MB block (the smallest bank /
// alias unit, HS 3.3): it is then present RAM too, and its SDRAM address is
// the first one's plus one in the low 21 bits (area: no second adder,
// decode and translation).  The rare store on the block's last longword
// goes through the adapter like any other access.
wire        bus_wr_nx_ok = ~&bus_addr[22:2];
wire bus_wr_direct = (DIRECT_WRITES != 0) && (svc == S_IDLE) && !walker_pend && !cpu_berr &&
                     !bus_miss_ack && !bus_line_ack && !bus_adapter_active && !wr_split_pend &&
                     !bus_ack_adapter && bus_req && bus_write &&
                     (!bus_wr_span || bus_wr_nx_ok) &&
                     (decode(bus_addr[31:2]) == 3'd0) && mem_wq_room;

assign bus_req_adapter = bus_req && !bus_line_match && !bus_line_wait && !bus_wr_direct && !wr_split_pend &&
                         !bus_first_miss && !svc_bus_direct && !bus_miss_ack && !bus_line_ack;

always @(posedge clk) begin
	if (!nreset) begin
		bus_line_ack   <= 0;
		bus_line_rdata <= 0;
	end
	else if (ce) begin
		bus_line_ack <= 0;
		if (!bus_line_ack && bus_line_match) begin
			bus_line_ack   <= 1;
			bus_line_rdata <= bus_line_data;
		end
	end
end

wire cpu_want = walker_pend || bus_first_miss || bus_wr_direct ||
                (b_req && !b_ack && !cpu_berr && !line_cpu_wait);
wire dma_take = dm_req && !dm_ack && !dm_err && !walker_pend && (dma_turn || !cpu_want);

assign dbg_berr      = (svc == S_BERR);
assign dbg_berr_addr = {svc_addr, 2'b00};

always @(posedge clk) begin
	if (!nreset) begin
		svc            <= S_IDLE;
		svc_walker     <= 0;
		svc_bus_direct <= 0;
		svc_dma        <= 0;
		svc_addr       <= 0;
		dma_turn       <= 0;
		dm_ack         <= 0;
		dm_err         <= 0;
		dm_rdata       <= 0;
		snoop_stb      <= 0;
		snoop_line     <= 0;
		walker_armed   <= 1;
		walker_ack     <= 0;
		walker_data    <= 0;
		walker_berr    <= 0;
		b_ack          <= 0;
		b_rdata        <= 0;
		bus_miss_ack   <= 0;
		bus_miss_rdata <= 0;
		wr_split_pend  <= 0;
		wr_split_addr  <= 0;
		wr_split_be    <= 0;
		wr_split_data  <= 0;
		mem_wp_valid   <= 0;
		mem_wp_addr    <= 0;
		mem_wp_be      <= 0;
		mem_wp_data    <= 0;
		cpu_berr       <= 0;
		mem_req        <= 0;
		mem_write      <= 0;
		mem_addr       <= 0;
		mem_be         <= 0;
		mem_wdata      <= 0;
		mem_memsel     <= MSEL_RAM;
		io_stb         <= 0;
		io_we          <= 0;
		io_addr        <= 0;
		io_be          <= 0;
		io_wdata       <= 0;
		io_dev         <= D_NONE;
		io_tmc         <= 0;
	end
	else if (ce) begin
		walker_ack   <= 0;
		walker_berr  <= 0;
		b_ack        <= 0;
		bus_miss_ack <= 0;
		mem_wp_valid <= 0;
		cpu_berr     <= 0;
		io_stb       <= 0;
		dm_ack       <= 0;
		dm_err       <= 0;
		snoop_stb    <= 0;
		if (wr_split_pend) begin
			wr_split_pend  <= 0;
			mem_wp_valid   <= 1;
			mem_wp_addr    <= wr_split_addr;
			mem_wp_be      <= wr_split_be;
			mem_wp_data    <= wr_split_data;
			bus_miss_ack   <= 1;
			bus_miss_rdata <= 0;
		end
		if (!walker_req) walker_armed <= 1;

		case (svc)
		S_IDLE: begin
			// walker first (it only runs mid-translation); a DMA beat takes
			// the turn after each CPU beat, or an idle bus
			if (dma_take) begin
				svc_walker     <= 0;
				svc_bus_direct <= 0;
				dma_turn       <= 0;
				svc_addr       <= dm_addr;
				snoop_line     <= dm_addr;
				if (ram_present(dm_addr)) begin
					svc_dma    <= 1;
					mem_req    <= 1;
					mem_write  <= dm_we;
					mem_addr   <= ram_sdram(dm_addr);
					mem_be     <= dm_be;
					mem_wdata  <= dm_wdata;
					mem_memsel <= MSEL_RAM;
					svc        <= S_MEM;
				end
				else dm_err <= 1;            // not DRAM: the channel takes BUSEXC
			end
			else if (cpu_want) begin
				reg [31:2] a;
				reg        wr;
				reg  [3:0] be;
				reg [31:0] wd;
				dma_turn <= 1;
				if (bus_first_miss) begin
					svc_walker     <= 0;
					svc_bus_direct <= 1;
					svc_addr       <= bus_addr[31:2];
					mem_req        <= 1;
					mem_write      <= 0;
					mem_addr       <= bus_sdram;
					mem_be         <= 4'b1111;
					mem_wdata      <= 0;
					mem_memsel     <= MSEL_RAM;
					svc            <= S_MEM;
				end
				else if (bus_wr_direct) begin
					mem_wp_valid <= 1;
					mem_wp_addr  <= bus_sdram;
					mem_wp_be    <= (4'b1111 << (3'd4 - bus_wr_bytes)) >> bus_addr[1:0];
					mem_wp_data  <= bus_wr_left >> {bus_addr[1:0], 3'd0};
					if (bus_wr_span) begin
						wr_split_pend <= 1;
						wr_split_addr <= {bus_sdram[26:23], bus_addr[22:2] + 21'd1};
						wr_split_be   <= 4'b1111 << (4'd8 - {1'b0, bus_wr_end});
						wr_split_data <= bus_wr_left << {3'd4 - {1'b0, bus_addr[1:0]}, 3'd0};
					end
					else begin
						bus_miss_ack   <= 1;
						bus_miss_rdata <= 0;
					end
				end
				else if (!walker_pend && line_cpu_match) begin
					b_ack   <= 1;
					b_rdata <= line_cpu_data;
				end
				else begin
					a  = walker_pend ? walker_addr[31:2] : b_addr;
					wr = walker_pend ? walker_we : b_write;
					be = walker_pend ? 4'b1111 : b_be;
					wd = walker_pend ? walker_wdat : b_wdata;
					svc_walker     <= walker_pend;
					svc_bus_direct <= 0;
					if (walker_pend) walker_armed <= 0;
					svc_addr <= a;
					case (decode(a))
					3'd0: begin
						mem_req    <= 1;
						mem_write  <= wr;
						mem_addr   <= ram_sdram(a);
						mem_be     <= be;
						mem_wdata  <= wd;
						mem_memsel <= MSEL_RAM;
						svc        <= S_MEM;
					end
					3'd1: begin
						if (wr) svc <= S_BERR;          // ROM writes bus-error (Previous ROM_bank)
						else begin
							mem_req    <= 1;
							mem_write  <= 0;
							mem_addr   <= {10'd0, a[16:2]};
							mem_be     <= be;
							mem_wdata  <= wd;
							mem_memsel <= MSEL_ROM;
							svc        <= S_MEM;
						end
					end
					3'd2: begin
						mem_req    <= 1;
						mem_write  <= wr;
						mem_addr   <= {6'd0, a[20:2]};
						mem_be     <= be;
						mem_wdata  <= wd;
						mem_memsel <= MSEL_VRAM;
						svc        <= S_MEM;
					end
					3'd3: begin
						if (dev_decode(a[16:2]) == D_NONE) svc <= S_BERR;
						else begin
							io_stb   <= 1;
							io_we    <= wr;
							io_addr  <= a[16:2];
							io_be    <= be;
							io_wdata <= wd;
							io_dev   <= dev_decode(a[16:2]);
							io_tmc   <= 0;
							svc      <= S_IO;
						end
					end
					3'd5: begin
						io_stb   <= 1;
						io_we    <= wr;
						io_addr  <= {1'b0, a[15:2]};
						io_be    <= be;
						io_wdata <= wd;
						io_dev   <= D_NONE;
						io_tmc   <= 1;
						svc      <= S_IO;
					end
					3'd6: svc <= S_OPEN;
					default: svc <= S_BERR;
					endcase
				end
			end
		end
		S_MEM: if (mem_ack) begin
			mem_req <= 0;
			if (svc_dma) begin
				dm_ack    <= 1;
				dm_rdata  <= mem_rdata;
				snoop_stb <= mem_write;
				svc_dma   <= 0;
			end
			else if (svc_walker) begin
				walker_ack  <= 1;
				walker_data <= mem_rdata;
			end
			else if (svc_bus_direct) begin
				bus_miss_ack   <= 1;
				bus_miss_rdata <= mem_rdata;
			end
			else begin
				b_ack   <= 1;
				b_rdata <= mem_rdata;
			end
			svc_bus_direct <= 0;
			svc <= S_IDLE;
		end
		S_IO: if (io_ack) begin
			if (io_berr) begin
				if (svc_walker) walker_berr <= 1;
				else            cpu_berr    <= 1;
			end
			else if (svc_walker) begin
				walker_ack  <= 1;
				walker_data <= io_rdata;
			end
			else begin
				b_ack   <= 1;
				b_rdata <= io_rdata;
			end
			svc <= S_IDLE;
		end
		S_BERR: begin
			if (svc_walker) walker_berr <= 1;
			else            cpu_berr    <= 1;
			svc <= S_IDLE;
		end
		S_OPEN: begin
			if (svc_walker) begin
				walker_ack  <= 1;
				walker_data <= 32'd0;
			end
			else begin
				b_ack   <= 1;
				b_rdata <= 32'd0;
			end
			svc <= S_IDLE;
		end
		default: svc <= S_IDLE;
		endcase
	end
end

endmodule
