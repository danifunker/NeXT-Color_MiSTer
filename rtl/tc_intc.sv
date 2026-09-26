//============================================================================
//  tc_intc -- interrupt status ($02007000) and mask ($02007800) registers.
//
//  Adapted from NeXT_MiSTer rtl/next/next_intc.sv (level encoder, bit
//  names) for the Turbo and the tc_machine device port:
//  * sources are LEVELS owned by the devices (Previous set_interrupt(SET/
//    RELEASE) calls), so the status register is simply their OR;
//  * the status register is read only on a Turbo (Previous sysReg.c
//    IntRegStatWrite() is empty);
//  * mask writes OR in the Turbo always-enabled bits INT_ZEROBITS
//    $C22E7600 and mask reads hide them (sysReg.c IntRegMaskRead/Write).
//    Among them are SCSI (bit 12) and the video/ADB interrupt (bit 13),
//    which is why the ROM's level-3 boot ISR also services the SCSI chip.
//    Unverified on hardware: docs/OPEN-QUESTIONS.md.
//
//  Levels (Previous sysReg.h INT_Lx_MASK, get_interrupt_level()):
//    31:30 IPL7, 29:18 IPL6 (29 = timer, IPL7 when SCR2 TIMERIPL7),
//    17:15 IPL5, 14 IPL4, 13:2 IPL3, 1 IPL2, 0 IPL1.
//  Register addresses mirror across $02007000-$020077FF / $02007800-
//  $02007FFF (mask $0001F803, ioMemTabTurbo.c).
//============================================================================

module tc_intc
(
	input             clk,
	input             reset,

	input      [31:0] src,           // level per status bit
	input             timer_ipl7,

	input             stb,
	input             we,
	input             sel_mask,      // 0 = status $7000, 1 = mask $7800
	input       [3:0] be,
	input      [31:0] wdata,
	output reg [31:0] rdata,
	output reg        ack,

	output      [2:0] ipl,           // active high level 0..7
	output     [31:0] status
);

localparam [31:0] ZEROBITS = 32'hC22E7600;

reg [31:0] mask;
assign status = src;

always @(posedge clk) begin
	ack <= 0;
	if (reset) begin
		mask  <= ZEROBITS;
		rdata <= 0;
	end
	else if (stb) begin
		ack   <= 1;
		rdata <= sel_mask ? (mask & ~ZEROBITS) : src;
		if (we && sel_mask)
			mask <= {be[3] ? wdata[31:24] : mask[31:24], be[2] ? wdata[23:16] : mask[23:16],
			         be[1] ? wdata[15:8]  : mask[15:8],  be[0] ? wdata[7:0]   : mask[7:0]} | ZEROBITS;
	end
end

wire [31:0] pend = src & mask;

assign ipl = (|(pend & 32'hC0000000))            ? 3'd7 :
             (pend[29] & timer_ipl7)             ? 3'd7 :
             (|(pend & 32'h3FFC0000))            ? 3'd6 :
             (|(pend & 32'h00038000))            ? 3'd5 :
             (|(pend & 32'h00004000))            ? 3'd4 :
             (|(pend & 32'h00003FFC))            ? 3'd3 :
             (|(pend & 32'h00000002))            ? 3'd2 :
             (|(pend & 32'h00000001))            ? 3'd1 : 3'd0;

endmodule
