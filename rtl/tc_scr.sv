//============================================================================
//  tc_scr -- System Control Registers of the Turbo Color's CPU board.
//
//  SCR1 $0200C000 (and $0200C800), read only.  Previous ioMemTabTurbo.c maps
//  both to SCR1_Read (mask $0001F803); on a Turbo, sysReg.c SCR_Reset()
//  builds slot $F (station) | TYPE_TURBO (4) << 12 = $F0004000.  The ROM
//  reads this first and, because the type nibble is 4, re-reads the TMC
//  copy at $02200000 (tc_tmc.sv) -- hardware-summary 1.1 ("HS").
//
//  SCR2 $0200D000, 32-bit, byte and long access with the same bit
//  positions (HS 1.2; Previous sysReg.c SCR2_Read*/SCR2_Write*):
//    byte 0 ($0200D000): bit 7 DSP_RESET, 6 DSP_BLK_END, 5 DSP_UNPKD,
//                        4/3 DSP_MODE_B/A, 1 SOFTINT2, 0 SOFTINT1
//                        (soft interrupts -> interrupt status bits 1/0)
//    byte 1:             bit 7 DSP_TXD_EN (Turbo)
//    byte 2:             bit 7 TIMERIPL7, bit 4 "video mode 25 MHz" (reset
//                        1 on a Turbo: 1120x832, HS 1.2 / 4.3), bit 2
//                        RTDATA, bit 1 RTCLK, bit 0 RTCE
//    byte 3:             bit 7 ROM / local only (reset 1 on a Turbo),
//                        bit 5 DSP_MEM_EN, bit 0 LED
//  Reset values: sysReg.c SCR_Reset() Turbo branch: byte 2 = $10,
//  byte 3 = $80, bytes 0/1 = 0.
//
//  RTC (MCCS1850, rtl/tc_mccs1850.sv) is bit-banged through byte 2 bits
//  0..2.  Reading byte 2 returns the chip's data output in bit 2 while it
//  drives the line (SCR2_Read2 replaces RTDATA with rtc_interface_read()).
//
//  Device port contract (tc_machine): stb 1-cycle strobe, ack 1-cycle pulse
//  one clock later with rdata; be[3] = byte at longword+0 = data[31:24].
//  addr[11] selects SCR2 ($D000) vs SCR1 ($C000/$C800): the machine's
//  decode sends both here.
//============================================================================

module tc_scr
(
	input             clk,
	input             reset,          // machine reset
	input             config_reset,   // power-up / OSD reset: NVRAM default image

	input             stb,
	input             we,
	input             sel_scr2,       // 1 = $0200D000, 0 = $0200C000/$0200C800
	input       [3:0] be,
	input      [31:0] wdata,
	output reg [31:0] rdata,
	output reg        ack,

	// RTC plumbing
	input      [32:0] timestamp,
	input       [1:0] ram_cfg,
	input             pot_on,
	input      [95:0] boot_cmd,
	input             power_key,
	output            int_power,      // -> interrupt status bit 2

	output            led,
	output            timer_ipl7,
	output      [1:0] softint,        // -> interrupt status bits 1/0
	output            dsp_reset_n,    // SCR2 bit 31 (the ROM clears it once)
	output     [31:0] scr2_out
);

localparam [31:0] SCR1_LEGACY = 32'hF0004000;

reg [31:0] scr2;

wire rtc_dout, rtc_drive;

assign led         = scr2[0];
assign timer_ipl7  = scr2[15];
assign softint     = scr2[25:24];
assign dsp_reset_n = scr2[31];
assign scr2_out    = scr2;

wire [31:0] scr2_rd = {scr2[31:11], rtc_drive ? rtc_dout : scr2[10], scr2[9:0]};

always @(posedge clk) begin
	ack <= 0;
	if (reset) begin
		scr2  <= 32'h0000_1080;
		rdata <= 0;
	end
	else if (stb) begin
		ack   <= 1;
		rdata <= sel_scr2 ? scr2_rd : SCR1_LEGACY;
		if (we && sel_scr2) begin
			if (be[3]) scr2[31:24] <= wdata[31:24];
			if (be[2]) scr2[23:16] <= wdata[23:16];
			if (be[1]) scr2[15:8]  <= wdata[15:8];
			if (be[0]) scr2[7:0]   <= wdata[7:0];
		end
	end
end

tc_mccs1850 rtc
(
	.clk(clk),
	.reset(reset),
	.config_reset(config_reset),
	.rtc_ce(scr2[8]),
	.rtc_clk(scr2[9]),
	.rtc_din(scr2[10]),
	.rtc_dout(rtc_dout),
	.rtc_drive(rtc_drive),
	.timestamp(timestamp),
	.ram_cfg(ram_cfg),
	.pot_on(pot_on),
	.boot_cmd(boot_cmd),
	.power_key(power_key),
	.power_int(int_power),
	.dbg_last_reg()
);

endmodule
