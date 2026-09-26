// ddr3_model -- the MiSTer DDRAM port as the core sees it (Avalon-MM
// master side: RD/WE held until !BUSY, reads return BURSTCNT beats on
// DOUT_READY after a latency).  Backs only the 2 MB VRAM window at DDR byte
// $30000000 (DDRAM_ADDR $06000000).  BUSY is raised pseudo-randomly so
// the core's hold-until-accepted logic is exercised.  A combinational peek
// port lets the C++ harness dump VRAM (verilator/sim_main.cpp --vram-png).
// Written for NeXT-Color; the protocol is the one NeXT_MiSTer's
// rtl/next/next_ddram.sv and sys/ddr_svc.sv use.

module ddr3_model #(
	parameter integer LAT = 14,                 // clocks from accept to first beat
	parameter [28:0]  BASE = 29'h0600_0000,
	parameter integer AW = 18                   // 2^18 x 8 bytes = 2 MB
)
(
	input             clk,
	output reg        busy = 0,
	input       [7:0] burstcnt,
	input      [28:0] addr,
	output reg [63:0] dout = 0,
	output reg        dout_ready = 0,
	input             rd,
	input      [63:0] din,
	input       [7:0] be,
	input             we,

	input    [AW-1:0] peek_addr,
	output     [63:0] peek_data,
	// sim-only backdoor write (sim_main.cpp --color-bars)
	input             poke_en,
	input    [AW-1:0] poke_addr,
	input      [63:0] poke_data
);

reg [63:0] mem [0:(1<<AW)-1];
integer i;
initial for (i = 0; i < (1<<AW); i = i + 1) mem[i] = 64'd0;

assign peek_data = mem[peek_addr];

// one outstanding read at a time (the core never pipelines two)
reg          rd_pend = 0;
reg   [7:0]  rd_left = 0;
reg [AW-1:0] rd_addr = 0;
integer      rd_wait = 0;
reg  [15:0]  lfsr = 16'hACE1;

wire [AW-1:0] a = addr[AW-1:0];
wire          in_win = (addr[28:AW] == BASE[28:AW]);

always @(posedge clk) begin
	lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
	dout_ready <= 0;

	if (!busy) begin
		if (we) begin
			if (!in_win) $display("[DDR3] write outside the VRAM window: %07X", addr);
			else for (i = 0; i < 8; i = i + 1)
				if (be[i]) mem[a][8*i +: 8] <= din[8*i +: 8];
		end
		if (rd) begin
			if (!in_win) $display("[DDR3] read outside the VRAM window: %07X", addr);
			if (rd_pend) $display("[DDR3] second read issued while one is outstanding");
			rd_pend <= 1;
			rd_left <= burstcnt;
			rd_addr <= a;
			rd_wait <= LAT;
		end
	end

	if (rd_pend) begin
		if (rd_wait > 0) rd_wait <= rd_wait - 1;
		else begin
			dout       <= mem[rd_addr];
			dout_ready <= 1;
			rd_addr    <= rd_addr + 1'b1;
			rd_left    <= rd_left - 8'd1;
			if (rd_left == 8'd1) rd_pend <= 0;
		end
	end

	if (poke_en) mem[poke_addr] <= poke_data;

	// BUSY about one clock in eight, never while a read is streaming out
	busy <= (lfsr[2:0] == 3'd0);
end

endmodule
