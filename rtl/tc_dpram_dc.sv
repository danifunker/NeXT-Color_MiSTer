//============================================================================
//  tc_dpram_dc -- simple dual-port, dual-clock RAM (one write port on wclk,
//  one read port on rclk, registered read address, unregistered output:
//  q is valid one rclk after raddr).  Explicit altsyncram so Quartus puts it
//  in M10K (the NeXT_MiSTer lesson: inferred multi-clock templates fell out
//  to registers); Verilator gets the behavioral model.  Used for the video
//  line buffer (tc_vram.sv).
//============================================================================

module tc_dpram_dc #(parameter AW = 10, parameter DW = 64)
(
	input           wclk,
	input           we,
	input  [AW-1:0] waddr,
	input  [DW-1:0] wdata,

	input           rclk,
	input  [AW-1:0] raddr,
	output [DW-1:0] q
);

`ifdef VERILATOR

reg [DW-1:0] mem [0:(1<<AW)-1];
reg [AW-1:0] ra;
always @(posedge wclk) if (we) mem[waddr] <= wdata;
always @(posedge rclk) ra <= raddr;
assign q = mem[ra];

`else

altsyncram ram
(
	.clock0    (wclk),
	.address_a (waddr),
	.data_a    (wdata),
	.wren_a    (we),

	.clock1    (rclk),
	.address_b (raddr),
	.q_b       (q),

	.aclr0(1'b0),
	.aclr1(1'b0),
	.addressstall_a(1'b0),
	.addressstall_b(1'b0),
	.byteena_a(1'b1),
	.byteena_b(1'b1),
	.clocken0(1'b1),
	.clocken1(1'b1),
	.clocken2(1'b1),
	.clocken3(1'b1),
	.data_b({DW{1'b1}}),
	.eccstatus(),
	.q_a(),
	.rden_a(1'b1),
	.rden_b(1'b1),
	.wren_b(1'b0)
);
defparam
	ram.address_aclr_b = "NONE",
	ram.address_reg_b = "CLOCK1",
	ram.clock_enable_input_a = "BYPASS",
	ram.clock_enable_input_b = "BYPASS",
	ram.clock_enable_output_b = "BYPASS",
	ram.intended_device_family = "Cyclone V",
	ram.lpm_type = "altsyncram",
	ram.numwords_a = 1 << AW,
	ram.numwords_b = 1 << AW,
	ram.operation_mode = "DUAL_PORT",
	ram.outdata_aclr_b = "NONE",
	ram.outdata_reg_b = "UNREGISTERED",
	ram.power_up_uninitialized = "FALSE",
	ram.ram_block_type = "M10K",
	ram.widthad_a = AW,
	ram.widthad_b = AW,
	ram.width_a = DW,
	ram.width_b = DW,
	ram.width_byteena_a = 1;

`endif

endmodule
