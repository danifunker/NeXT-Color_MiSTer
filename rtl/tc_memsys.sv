//============================================================================
//  tc_memsys -- the memories behind tc_machine's platform beat port.
//
//    memsel 0  RAM   SDRAM through MacQuadra800's sdram_beat32 + sdram.sv
//                    (99 MHz, 16-byte line fills, posted write FIFO).
//                    mem_addr is already the SDRAM address (tc_machine maps
//                    the four $02000000-stride banks onto it).
//    memsel 1  ROM   rtl/tc_rom.sv (M10K), two clocks per beat.
//    memsel 2  VRAM  rtl/tc_vram.sv (DDR3), which also owns the scan-out.
//
//  Both the MiSTer top (NeXT-Color.sv) and the Verilator full-machine sim
//  (verilator/sim.v) instantiate this, so the sim covers the real memory
//  glue (MacQuadra800's sim did not; its CLAUDE.md lists that as the gap).
//============================================================================

module tc_memsys
(
	input             clk_sys,
	input             clk_ram,       // 3x clk_sys, same PLL, phase aligned
	input             clk_vid,
	input             reset,         // clk_sys (machine reset)
	input             reset_vid,     // clk_vid
	input             sdram_init,    // hold the SDRAM controller in init (PLL not locked)

	// machine beat port
	input             mem_req,
	input             mem_write,
	input      [26:2] mem_addr,
	input       [3:0] mem_be,
	input      [31:0] mem_wdata,
	input       [1:0] mem_memsel,
	output     [31:0] mem_rdata,
	output            mem_ack,
	input             mem_wp_valid,
	input      [26:2] mem_wp_addr,
	input       [3:0] mem_wp_be,
	input      [31:0] mem_wp_data,
	output            mem_wq_room,
	output            mem_line_valid,
	output     [26:4] mem_line_tag,
	output    [127:0] mem_line_data,
	output            mem_line_pending,
	output     [26:4] mem_line_pending_tag,

	// boot ROM loader (while the machine is held in reset)
	input             rom_we,
	input      [16:1] rom_waddr,
	input      [15:0] rom_wdata,

	// video
	input      [31:0] hreg,
	input      [31:0] vreg,
	input             video_enable,
	input     [127:0] lut_r,
	input     [127:0] lut_g,
	input     [127:0] lut_b,
	output            vbl_pulse,
	output      [7:0] vga_r,
	output      [7:0] vga_g,
	output      [7:0] vga_b,
	output            vga_hs,
	output            vga_vs,
	output            vga_de,

	// SDRAM pins
	inout      [15:0] SDRAM_DQ,
	output     [12:0] SDRAM_A,
	output            SDRAM_DQML,
	output            SDRAM_DQMH,
	output      [1:0] SDRAM_BA,
	output            SDRAM_nCS,
	output            SDRAM_nWE,
	output            SDRAM_nRAS,
	output            SDRAM_nCAS,
	output            SDRAM_CKE,
	output            SDRAM_CLK,

	// DDR3 (clk_ram)
	input             DDRAM_BUSY,
	output      [7:0] DDRAM_BURSTCNT,
	output     [28:0] DDRAM_ADDR,
	input      [63:0] DDRAM_DOUT,
	input             DDRAM_DOUT_READY,
	output            DDRAM_RD,
	output     [63:0] DDRAM_DIN,
	output      [7:0] DDRAM_BE,
	output            DDRAM_WE
);

wire is_ram  = (mem_memsel == 2'd0);
wire is_rom  = (mem_memsel == 2'd1);
wire is_vram = (mem_memsel == 2'd2);

//----------------------------------------------------------------------------
// RAM
//----------------------------------------------------------------------------
wire        sdr_ack;
wire [31:0] sdr_rdata;

sdram_beat32 sdr
(
	.init      (sdram_init),
	.clk_sys   (clk_sys),
	.clk_ram   (clk_ram),

	.req       (mem_req && is_ram),
	.we        (mem_write),
	.addr      (mem_addr),
	.be        (mem_be),
	.wdata     (mem_wdata),
	.ack       (sdr_ack),
	.rdata     (sdr_rdata),
	.busy      (),
	.line_valid_o(mem_line_valid),
	.line_tag_o(mem_line_tag),
	.line_data_o(mem_line_data),
	.line_pending_o(mem_line_pending),
	.line_pending_tag_o(mem_line_pending_tag),
	.wp_valid  (mem_wp_valid),
	.wp_addr   (mem_wp_addr),
	.wp_be     (mem_wp_be),
	.wp_data   (mem_wp_data),
	.wq_room   (mem_wq_room),

	.SDRAM_DQ  (SDRAM_DQ),
	.SDRAM_A   (SDRAM_A),
	.SDRAM_DQML(SDRAM_DQML),
	.SDRAM_DQMH(SDRAM_DQMH),
	.SDRAM_BA  (SDRAM_BA),
	.SDRAM_nCS (SDRAM_nCS),
	.SDRAM_nWE (SDRAM_nWE),
	.SDRAM_nRAS(SDRAM_nRAS),
	.SDRAM_nCAS(SDRAM_nCAS),
	.SDRAM_CKE (SDRAM_CKE),
	.SDRAM_CLK (SDRAM_CLK)
);

//----------------------------------------------------------------------------
// ROM: the address goes straight into the M10K; the word is there one clock
// later and is acknowledged the clock after that.
//----------------------------------------------------------------------------
wire [31:0] rom_q;
reg         rom_wait = 0;
reg         rom_ack  = 0;
reg  [31:0] rom_rdata;

tc_rom rom
(
	.clk(clk_sys),
	.we(rom_we),
	.waddr(rom_waddr),
	.wdata(rom_wdata),
	.raddr(mem_addr[16:2]),
	.rdata(rom_q)
);

always @(posedge clk_sys) begin
	rom_ack <= 0;
	if (reset) rom_wait <= 0;
	else if (rom_wait) begin
		rom_wait  <= 0;
		rom_ack   <= 1;
		rom_rdata <= rom_q;
	end
	else if (mem_req && is_rom && !rom_ack) rom_wait <= 1;
end

//----------------------------------------------------------------------------
// VRAM + scan-out
//----------------------------------------------------------------------------
wire        vram_ack;
wire [31:0] vram_rdata;

tc_vram vram
(
	.clk_sys(clk_sys),
	.clk_ram(clk_ram),
	.clk_vid(clk_vid),
	.reset(reset),
	.reset_vid(reset_vid),

	.req(mem_req && is_vram),
	.we(mem_write),
	.addr(mem_addr[20:2]),
	.be(mem_be),
	.wdata(mem_wdata),
	.ack(vram_ack),
	.rdata(vram_rdata),

	.hreg(hreg),
	.vreg(vreg),
	.video_enable(video_enable),
	.lut_r(lut_r),
	.lut_g(lut_g),
	.lut_b(lut_b),
	.vbl_pulse(vbl_pulse),

	.vga_r(vga_r),
	.vga_g(vga_g),
	.vga_b(vga_b),
	.vga_hs(vga_hs),
	.vga_vs(vga_vs),
	.vga_de(vga_de),

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

assign mem_ack   = sdr_ack | rom_ack | vram_ack;
assign mem_rdata = sdr_ack ? sdr_rdata : rom_ack ? rom_rdata : vram_rdata;

endmodule
