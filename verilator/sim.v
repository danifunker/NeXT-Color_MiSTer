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
	.lut_r(lut_r),
	.lut_g(lut_g),
	.lut_b(lut_b),
	.vbl_pulse(vbl_pulse),

	.ps2_key(ps2_key),
	.ps2_mouse(ps2_mouse),
	.timestamp(timestamp),
	.pot_on(pot_on),
	.boot_cmd(boot_cmd),

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
	.lut_r(lut_r),
	.lut_g(lut_g),
	.lut_b(lut_b),
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
	.peek_data(vram_peek_data)
);

// ---------------------------------------------------------------- ROM
reg [8*256-1:0] romfile;
initial begin
	if (!$value$plusargs("rom=%s", romfile)) romfile = "rom.hex";
	$readmemh(romfile, memsys.rom.mem);
	$display("[SIM] ROM %0s loaded", romfile);
end

endmodule
