//============================================================================
//  tc_regfile -- a device-port register file that reads back what was
//  written.  Stand-in for registers whose device is not modelled yet (the
//  PC-chip DMA channel registers, the Ethernet chip's byte registers, the
//  ESP until rtl/next_scsi is ported): the ROM's writes are accepted and
//  read back, nothing else happens.  Each instance says in tc_machine.sv
//  what it stands in for.
//
//  The array has no reset, so Quartus can put it in block RAM (a reset
//  loop turned the 256-word DMA stand-in into ~3,750 LUTs); it powers up 0.
//  Device port contract (tc_machine): stb 1-cycle, ack 1-cycle later.
//============================================================================

module tc_regfile #(parameter AW = 4)
(
	input             clk,
	input             reset,

	input             stb,
	input             we,
	input    [AW-1:0] addr,          // longword index
	input       [3:0] be,
	input      [31:0] wdata,
	output reg [31:0] rdata,
	output reg        ack
);

reg [7:0] r3 [0:(1<<AW)-1];
reg [7:0] r2 [0:(1<<AW)-1];
reg [7:0] r1 [0:(1<<AW)-1];
reg [7:0] r0 [0:(1<<AW)-1];
integer i;
initial for (i = 0; i < (1<<AW); i = i + 1) begin r3[i] = 0; r2[i] = 0; r1[i] = 0; r0[i] = 0; end

always @(posedge clk) begin
	ack <= reset ? 1'b0 : stb;
	if (stb) begin
		rdata <= {r3[addr], r2[addr], r1[addr], r0[addr]};
		if (we && be[3]) r3[addr] <= wdata[31:24];
		if (we && be[2]) r2[addr] <= wdata[23:16];
		if (we && be[1]) r1[addr] <= wdata[15:8];
		if (we && be[0]) r0[addr] <= wdata[7:0];
	end
end

endmodule
