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
//  Machine: rtl/tc_machine.sv; memories + scan-out: rtl/tc_memsys.sv.
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

assign LED_POWER = 0;
assign BUTTONS = 0;

//////////////////////////////////////////////////////////////////

`include "build_id.v"
localparam CONF_STR = {
	"NeXT-Color;;",
	"-;",
	// SC slots: Main remembers the mounted image in config/NeXT-Color.s<n>
	// and re-mounts it at core start, so the ROM can boot from the disk.
	// Slot n = SCSI target n; slot 3 is the CD-ROM (Main's NEXT_CDROM_SLOT,
	// which also carries the target-response windows, rtl/tc_scsi.sv).
	"SC0,HDAVHDIMG,SCSI disk 0;",
	"SC1,HDAVHDIMG,SCSI disk 1;",
	"S3,ISOCUEBINCHD,CD-ROM;",
	"-;",
	"O[4:3],Memory,64 MB,128 MB,16 MB,32 MB;",
	"O[5],Power-on self test,On,Off;",
	"O[8:6],Boot device,Prompt (NeXT>),SCSI disk,Network,Floppy;",
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
wire  [7:0] ioctl_dout;

// SD slots (NeXT_MiSTer NeXT.sv): WIDE=0 because tc_scsi keeps next_scsi's
// 8-bit sd_buff port; VDNUM 4 = slots 0..3 (slot 2 has no OSD entry, so
// target 2 always times out, as in the mono core).  tc_scsi talks to one
// target at a time: its request goes to slot sd_unit and only that slot's
// acknowledge comes back.
wire  [3:0] img_mounted_v, sd_ack_v;
wire        img_readonly;
wire [63:0] img_size;
wire  [2:0] sd_unit;
wire [31:0] sd_lba;
wire        sd_rd, sd_wr, sd_busy;
wire [13:0] sd_buff_addr;
wire  [7:0] sd_buff_dout, sd_buff_din;
wire        sd_buff_wr;
wire  [3:0] scsi_onehot = 4'd1 << sd_unit[1:0];
wire        sd_ack      = (sd_unit < 3'd4) ? sd_ack_v[sd_unit[1:0]] : 1'b0;

hps_io #(.CONF_STR(CONF_STR), .WIDE(0), .VDNUM(4)) hps_io
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
	.ioctl_wait(1'b0),

	.img_mounted(img_mounted_v),
	.img_readonly(img_readonly),
	.img_size(img_size),
	.sd_lba('{sd_lba, sd_lba, sd_lba, sd_lba}),
	.sd_rd({4{sd_rd}} & scsi_onehot),
	.sd_wr({4{sd_wr}} & scsi_onehot),
	.sd_ack(sd_ack_v),
	.sd_blk_cnt('{6'd0, 6'd0, 6'd0, 6'd0}),
	.sd_buff_addr(sd_buff_addr),
	.sd_buff_dout(sd_buff_dout),
	.sd_buff_din('{sd_buff_din, sd_buff_din, sd_buff_din, sd_buff_din}),
	.sd_buff_wr(sd_buff_wr)
);

assign LED_DISK = {1'b0, sd_busy};

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
reg  [7:0] rom_even = 0;      // the even byte of the halfword being loaded
always @(posedge clk_sys) begin
	rom_dl_d <= ioctl_download && rom_index;
	if (rom_dl_d && !(ioctl_download && rom_index)) rom_loaded <= 1;
	if (ioctl_wr && !ioctl_addr[0]) rom_even <= ioctl_dout;
end


///////////////////////   RESET   ////////////////////////////////

// The KMS magic reset ($C6 $1000A825, hardware-summary 6.2) resets the
// machine but not the NVRAM image; the OSD/power-up reset rebuilds it.
wire        reset_req;
reg   [7:0] kms_reset_cnt = 0;
always @(posedge clk_sys) begin
	if (reset_req) kms_reset_cnt <= 8'hFF;
	else if (kms_reset_cnt != 0) kms_reset_cnt <= kms_reset_cnt - 1'd1;
end

// Registered, as the mono core learned (NeXT_MiSTer RESUME-20260925: the
// reset nets fan out to thousands of flops; a register lets Quartus put
// them on a global).
reg config_reset = 1, reset = 1;
always @(posedge clk_sys) begin
	config_reset <= RESET | status[0] | buttons[1] | (ioctl_download && rom_index) |
	                ~rom_loaded | ~pll_locked;
	reset        <= config_reset | (kms_reset_cnt != 0);
end

// Machine configuration, sampled while the machine is in reset so the ROM
// never sees it change under it (the MacQuadra800 lesson).
reg  [1:0] ram_cfg  = 2'd0;
reg        pot_on   = 1'b1;
reg [95:0] boot_cmd = 96'd0;
always @(posedge clk_sys) if (config_reset) begin
	ram_cfg <= status[4:3];                 // 0 = 64 MB, 1 = 128 MB, 2 = 16 MB, 3 = 32 MB
	pot_on  <= ~status[5];
	case (status[8:6])
	3'd1:    boot_cmd <= {"sd", 80'd0};
	3'd2:    boot_cmd <= {"en", 80'd0};
	3'd3:    boot_cmd <= {"fd", 80'd0};
	default: boot_cmd <= 96'd0;             // empty: the ROM stops at NeXT>
	endcase
end

// video-domain reset: two-flop synchronizer of the PLL lock
reg vrst_meta = 1, vrst = 1;
always @(posedge clk_vid) begin
	vrst_meta <= ~pllv_locked;
	vrst      <= vrst_meta;
end

///////////////////////   MACHINE   //////////////////////////////

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

wire [31:0] tmc_hreg, tmc_vreg;
wire        video_enable;
wire   [2:0] pal_we;
wire   [3:0] pal_n;
wire   [7:0] pal_d;
wire        vbl_pulse;
wire        led;

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

	.tmc_hreg(tmc_hreg),
	.tmc_vreg(tmc_vreg),
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

	.img_mounted({2'b00, img_mounted_v}),
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

	.dbg_berr(),
	.dbg_berr_addr(),
	.debug_status(),
	.debug_status2(),
	.debug_fault(),
	.debug_halted(),
	.dbg_intstat(),
	.dbg_ipl()
);

///////////////////////   MEMORY + VIDEO   ///////////////////////

wire [7:0] vga_r, vga_g, vga_b;
wire       vga_hs, vga_vs, vga_de;

assign DDRAM_CLK = clk_ram;

tc_memsys memsys
(
	.clk_sys(clk_sys),
	.clk_ram(clk_ram),
	.clk_vid(clk_vid),
	.reset(reset),
	.reset_vid(vrst),
	.sdram_init(~pll_locked),

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

	// boot.rom is ioctl index 0 (the Main loads games/NeXT-Color/boot.rom at
	// core start), the OSD "Load boot ROM" entry is index 1.  Byte-wide
	// ioctl (WIDE=0): the even byte is held and written with the odd one,
	// big-endian (file byte 0 = bits 15:8 of the first halfword).
	.rom_we(ioctl_download && rom_index && ioctl_wr && ioctl_addr[0] && ioctl_addr[26:17] == 0),
	.rom_waddr(ioctl_addr[16:1]),
	.rom_wdata({rom_even, ioctl_dout}),

	.hreg(tmc_hreg),
	.vreg(tmc_vreg),
	.video_enable(video_enable),
	.pal_we(pal_we),
	.pal_n(pal_n),
	.pal_d(pal_d),
	.vbl_pulse(vbl_pulse),
	.vga_r(vga_r),
	.vga_g(vga_g),
	.vga_b(vga_b),
	.vga_hs(vga_hs),
	.vga_vs(vga_vs),
	.vga_de(vga_de),

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

assign CLK_VIDEO = clk_vid;
assign CE_PIXEL  = 1'b1;
assign VGA_R  = vga_r;
assign VGA_G  = vga_g;
assign VGA_B  = vga_b;
assign VGA_HS = ~vga_hs;
assign VGA_VS = ~vga_vs;

// Aspect ratio and scaling (sys/video_freak.sv).  "Original" is 1120:832 =
// 35:26, square pixels (the mono core's lesson: a 4:3 declaration squeezes
// 1120 columns into 1109).  "Normal" scale fills the output height with the
// right aspect: 1454x1080 on 1080p, 969x720 on 720p.
wire [1:0] ar = status[122:121];
video_freak video_freak
(
	.CLK_VIDEO(clk_vid),
	.CE_PIXEL(1'b1),
	.VGA_VS(~vga_vs),
	.HDMI_WIDTH(HDMI_WIDTH),
	.HDMI_HEIGHT(HDMI_HEIGHT),
	.VGA_DE(VGA_DE),
	.VIDEO_ARX(VIDEO_ARX),
	.VIDEO_ARY(VIDEO_ARY),
	.VGA_DE_IN(vga_de),
	.ARX((!ar) ? 12'd35 : (ar - 1'd1)),
	.ARY((!ar) ? 12'd26 : 12'd0),
	.CROP_SIZE(12'd0),
	.CROP_OFF(5'd0),
	.SCALE(status[125:123])
);

assign LED_USER = led;

endmodule
