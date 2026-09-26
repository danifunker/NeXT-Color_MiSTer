//============================================================================
//  tc_rom -- the 128 KB boot ROM (Rev 3.3 v74) in M10K.
//
//  32K x 32 big-endian longwords (byte 0 of the image = bits 31:24 of word
//  0).  The whole 128 KB is needed: the ROM's CRC-32 covers $0100001E ..
//  $0101FFFF (hardware-summary section 15), so the mono core's 96 KB store
//  (NeXT_MiSTer rtl/next/next_rom.sv) is not enough.  About 103 of the
//  553 M10K blocks.
//
//  One port: the loader writes 16-bit halves while the machine is held in
//  reset (boot.rom over hps_io, or the simulator), the machine reads 32-bit
//  words afterwards.  Explicit altsyncram, as the mono core learned
//  (NeXT_MiSTer docs/RESUME-20260925.md: "use an explicit altsyncram for the
//  ROM"); Verilator gets the behavioral equivalent.  Read latency: one clock
//  (address registered, output unregistered).
//============================================================================

module tc_rom
(
	input         clk,

	// loader: big-endian halfword at byte address {waddr, 1'b0}
	input         we,
	input  [16:1] waddr,
	input  [15:0] wdata,

	// machine read: longword address
	input  [16:2] raddr,
	output [31:0] rdata
);

wire [14:0] addr = we ? waddr[16:2] : raddr;
wire  [3:0] be   = waddr[1] ? 4'b0011 : 4'b1100;

`ifdef VERILATOR

reg [31:0] mem [0:32767];
reg [31:0] q;
always @(posedge clk) begin
	if (we) begin
		if (be[3]) mem[addr][31:24] <= wdata[15:8];
		if (be[2]) mem[addr][23:16] <= wdata[7:0];
		if (be[1]) mem[addr][15:8]  <= wdata[15:8];
		if (be[0]) mem[addr][7:0]   <= wdata[7:0];
	end
	q <= mem[addr];
end
assign rdata = q;

`else

altsyncram rom
(
	.clock0    (clk),
	.address_a (addr),
	.data_a    ({wdata, wdata}),
	.wren_a    (we),
	.byteena_a (be),
	.q_a       (rdata),

	.aclr0(1'b0),
	.aclr1(1'b0),
	.address_b(1'b1),
	.addressstall_a(1'b0),
	.addressstall_b(1'b0),
	.byteena_b(1'b1),
	.clock1(1'b1),
	.clocken0(1'b1),
	.clocken1(1'b1),
	.clocken2(1'b1),
	.clocken3(1'b1),
	.data_b(1'b1),
	.eccstatus(),
	.q_b(),
	.rden_a(1'b1),
	.rden_b(1'b1),
	.wren_b(1'b0)
);
defparam
	rom.byte_size = 8,
	rom.clock_enable_input_a = "BYPASS",
	rom.clock_enable_output_a = "BYPASS",
	rom.intended_device_family = "Cyclone V",
	rom.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
	rom.lpm_type = "altsyncram",
	rom.numwords_a = 32768,
	rom.operation_mode = "SINGLE_PORT",
	rom.outdata_aclr_a = "NONE",
	rom.outdata_reg_a = "UNREGISTERED",
	rom.power_up_uninitialized = "FALSE",
	rom.ram_block_type = "M10K",
	rom.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
	rom.widthad_a = 15,
	rom.width_a = 32,
	rom.width_byteena_a = 4;

`endif

endmodule
