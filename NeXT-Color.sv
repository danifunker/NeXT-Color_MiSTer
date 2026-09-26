//============================================================================
//
//  NeXT-Color -- NeXTstation Turbo Color (33 MHz 68040, TMC + PC chip set,
//  Bt463, 2 MB VRAM at $0C000000, 1120x832 x 16 bpp) for MiSTer.
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
//  Clocks (structure from MacQuadra800_MiSTer, MacQuadra800.sv):
//    clk_sys  33.000 MHz  CPU, devices (the real Turbo bus rate)
//    clk_ram  99.000 MHz  SDRAM controller, exactly 3 x clk_sys (same PLL)
//    clk_vid 100.000 MHz  pixel clock, own PLL (rtl/pll_vid.v)
//
//  Memory (docs/DECISIONS.md):
//    main RAM   SDRAM, 4 banks at $04000000 + n*$02000000
//    boot ROM   M10K (rtl/tc_rom.sv), loaded from games/NeXT-Color/boot.rom
//    VRAM       DDR3 (2 MB)
//
//  M0 skeleton: clocks, hps_io, ROM loader, TMC-timed test pattern.
//============================================================================

module emu
(
	`include "sys/emu_ports.vh"
);

///////// Default values for ports not used yet /////////

assign ADC_BUS  = 'Z;
assign USER_OUT = '1;
assign {UART_RTS, UART_TXD, UART_DTR} = 0;
assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;
assign {SDRAM_DQ, SDRAM_A, SDRAM_BA, SDRAM_CLK, SDRAM_CKE, SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nCS} = 'Z;
assign {DDRAM_CLK, DDRAM_BURSTCNT, DDRAM_ADDR, DDRAM_DIN, DDRAM_BE, DDRAM_RD, DDRAM_WE} = '0;

assign VGA_SL = 0;
assign VGA_F1 = 0;
assign VGA_SCALER  = 0;
assign VGA_DISABLE = 0;
assign HDMI_FREEZE = 0;
assign HDMI_BLACKOUT = 0;
assign HDMI_BOB_DEINT = 0;

assign AUDIO_S = 1;
assign AUDIO_L = 0;
assign AUDIO_R = 0;
assign AUDIO_MIX = 0;

assign LED_DISK = 0;
assign LED_POWER = 0;
assign BUTTONS = 0;

//////////////////////////////////////////////////////////////////

`include "build_id.v"
localparam CONF_STR = {
	"NeXT-Color;;",
	"-;",
	"O[4:3],Memory,64 MB,128 MB,16 MB,32 MB;",
	"-;",
	"O[122:121],Aspect ratio,Original,Full Screen,[ARC1],[ARC2];",
	"O[125:123],Scale,Normal,V-Integer,Narrower HV-Integer,Wider HV-Integer;",
	"-;",
	"F1,ROMBIN,Load boot ROM;",
	"-;",
	"T[0],Reset;",
	"R[0],Reset and close OSD;",
	"v,0;",
	"V,v",`BUILD_DATE
};

wire   [1:0] buttons;
wire [127:0] status;
wire  [10:0] ps2_key;
wire  [24:0] ps2_mouse;
wire  [32:0] timestamp;

wire        ioctl_download;
wire [15:0] ioctl_index;
wire        ioctl_wr;
wire [26:0] ioctl_addr;
wire [15:0] ioctl_dout;

hps_io #(.CONF_STR(CONF_STR), .WIDE(1)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),
	.EXT_BUS(),
	.gamma_bus(),

	.buttons(buttons),
	.status(status),
	.status_menumask(16'd0),

	.ps2_key(ps2_key),
	.ps2_mouse(ps2_mouse),
	.TIMESTAMP(timestamp),

	.ioctl_download(ioctl_download),
	.ioctl_index(ioctl_index),
	.ioctl_wr(ioctl_wr),
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_dout),
	.ioctl_wait(1'b0)
);

///////////////////////   CLOCKS   ///////////////////////////////

wire clk_sys, clk_ram, pll_locked;
pll pll
(
	.refclk(CLK_50M),
	.rst(0),
	.outclk_0(clk_sys),
	.outclk_1(clk_ram),
	.locked(pll_locked)
);

wire clk_vid, pllv_locked;
pll_vid pllv
(
	.refclk(CLK_50M),
	.rst(0),
	.outclk_0(clk_vid),
	.locked(pllv_locked)
);

///////////////////////   BOOT ROM   /////////////////////////////

// boot.rom is ioctl index 0 (loaded by the Main at core start from
// games/NeXT-Color/boot.rom); the OSD "Load boot ROM" entry is index 1.
wire rom_index = (ioctl_index[5:0] <= 6'd1);
reg  rom_loaded = 0;
reg  rom_dl_d   = 0;
always @(posedge clk_sys) begin
	rom_dl_d <= ioctl_download && rom_index;
	if (rom_dl_d && !(ioctl_download && rom_index)) rom_loaded <= 1;
end

wire [31:0] rom_q;
tc_rom rom
(
	.clk(clk_sys),
	// the ioctl halfword carries file byte 0 in [7:0]: swap to big-endian
	.we(ioctl_download && rom_index && ioctl_wr && ioctl_addr[26:17] == 0),
	.waddr(ioctl_addr[16:1]),
	.wdata({ioctl_dout[7:0], ioctl_dout[15:8]}),
	.raddr(15'd0),
	.rdata(rom_q)
);

///////////////////////   RESET   ////////////////////////////////

wire reset = RESET | status[0] | buttons[1] | (ioctl_download && rom_index) |
             ~rom_loaded | ~pll_locked;

// video-domain reset: two-flop synchronizer of the PLL lock
reg vrst_meta = 1, vrst = 1;
always @(posedge clk_vid) begin
	vrst_meta <= ~pllv_locked;
	vrst      <= vrst_meta;
end

///////////////////////   VIDEO   ////////////////////////////////

wire        hs, vs, hbl, vbl;
wire [11:0] vx, vy;
tc_vtiming vtiming
(
	.clk_vid(clk_vid),
	.reset(vrst),
	.hreg(32'h31048118),
	.vreg(32'h10430340),
	.hs(hs),
	.vs(vs),
	.hblank(hbl),
	.vblank(vbl),
	.x(vx),
	.y(vy),
	.line_pre(),
	.frame_start(),
	.vbl_start(),
	.h_active(),
	.v_active()
);

// M0 test pattern: 16 vertical colour bars of the 12-bit palette ramp and a
// one-pixel white frame, so the scaler's placement can be judged.
reg  [7:0] r, g, b;
reg        hs_o, vs_o, de_o;
wire       border = (vx == 0) || (vx == 12'd1119) || (vy == 0) || (vy == 12'd831);
wire [3:0] bar    = vx[10:7];
always @(posedge clk_vid) begin
	hs_o <= hs;
	vs_o <= vs;
	de_o <= ~(hbl | vbl);
	if (border) {r, g, b} <= 24'hFFFFFF;
	else begin
		r <= bar[0] ? {vy[9:6], vy[9:6]} : 8'd0;
		g <= bar[1] ? {vy[9:6], vy[9:6]} : 8'd0;
		b <= bar[2] ? {vy[9:6], vy[9:6]} : 8'd0;
	end
end

assign CLK_VIDEO = clk_vid;
assign CE_PIXEL  = 1'b1;
assign VGA_R  = r;
assign VGA_G  = g;
assign VGA_B  = b;
assign VGA_HS = ~hs_o;
assign VGA_VS = ~vs_o;

// Aspect ratio and scaling (sys/video_freak.sv).  "Original" is 1120:832 =
// 35:26, square pixels (the mono core's lesson: a 4:3 declaration squeezes
// 1120 columns into 1109).  "Normal" scale fills the output height with the
// right aspect: 1454x1080 on 1080p, 969x720 on 720p.
wire [1:0] ar = status[122:121];
video_freak video_freak
(
	.CLK_VIDEO(clk_vid),
	.CE_PIXEL(1'b1),
	.VGA_VS(~vs_o),
	.HDMI_WIDTH(HDMI_WIDTH),
	.HDMI_HEIGHT(HDMI_HEIGHT),
	.VGA_DE(VGA_DE),
	.VIDEO_ARX(VIDEO_ARX),
	.VIDEO_ARY(VIDEO_ARY),
	.VGA_DE_IN(de_o),
	.ARX((!ar) ? 12'd35 : (ar - 1'd1)),
	.ARY((!ar) ? 12'd26 : 12'd0),
	.CROP_SIZE(12'd0),
	.CROP_OFF(5'd0),
	.SCALE(status[125:123])
);

assign LED_USER = ~rom_loaded | reset;

endmodule
