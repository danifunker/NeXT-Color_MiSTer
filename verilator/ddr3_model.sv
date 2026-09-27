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

// The Ethernet mailbox (Main_MiSTer support/next/next_enet.cpp: ARM byte
// $1FF00000, 16 KB = word $03FE0000..$03FE07FF), written by the core's
// next_enet_bridge.  In place of Main's daemon the model plays a network
// that echoes: each frame the guest sends (TX_WPTR write) is copied into
// the next RX slot and RX_WPTR advanced, while the RX ring has room.
localparam [28:0] MBOX = 29'h03FE_0000;
reg  [63:0] mb [0:2047];
initial for (i = 0; i < 2048; i = i + 1) mb[i] = 64'd0;
wire        in_mb = (addr[28:11] == MBOX[28:11]);
wire [10:0] ma = addr[10:0];
reg         rd_mb = 0;
reg  [10:0] rd_maddr = 0;
integer     tx_frames = 0, k;
reg  [63:0] rxw, rxr;

always @(posedge clk) begin
	lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
	dout_ready <= 0;

	if (!busy) begin
		if (we && in_mb) begin
			mb[ma] <= din;
			if (ma == 11'd3) $display("[ENET] RX slot consumed by the core (RX_RPTR %0d)", din);
			if (ma == 11'd1 && din != 64'd0) begin
				// TX_WPTR: frame din-1 is in TX slot (din-1)&3
				tx_frames = tx_frames + 1;
				rxw = mb[2]; rxr = mb[3];
				$display("[ENET] TX frame %0d: %0d bytes, dst %012X src %012X type %04X%s",
				         din, mb[11'h100 + {(din[1:0] - 2'd1), 8'd0}][10:0],
				         {mb[11'h101 + {(din[1:0] - 2'd1), 8'd0}][7:0],   mb[11'h101 + {(din[1:0] - 2'd1), 8'd0}][15:8],
				          mb[11'h101 + {(din[1:0] - 2'd1), 8'd0}][23:16], mb[11'h101 + {(din[1:0] - 2'd1), 8'd0}][31:24],
				          mb[11'h101 + {(din[1:0] - 2'd1), 8'd0}][39:32], mb[11'h101 + {(din[1:0] - 2'd1), 8'd0}][47:40]},
				         {mb[11'h101 + {(din[1:0] - 2'd1), 8'd0}][55:48], mb[11'h101 + {(din[1:0] - 2'd1), 8'd0}][63:56],
				          mb[11'h102 + {(din[1:0] - 2'd1), 8'd0}][7:0],   mb[11'h102 + {(din[1:0] - 2'd1), 8'd0}][15:8],
				          mb[11'h102 + {(din[1:0] - 2'd1), 8'd0}][23:16], mb[11'h102 + {(din[1:0] - 2'd1), 8'd0}][31:24]},
				         {mb[11'h102 + {(din[1:0] - 2'd1), 8'd0}][39:32], mb[11'h102 + {(din[1:0] - 2'd1), 8'd0}][47:40]},
				         (rxw - rxr < 64'd4) ? " -> echoed" : " (RX ring full)");
				if (rxw - rxr < 64'd4) begin
					for (k = 0; k < 256; k = k + 1)
						mb[11'h500 + {rxw[1:0], 8'd0} + k] <= mb[11'h100 + {(din[1:0] - 2'd1), 8'd0} + k];
					mb[2] <= rxw + 64'd1;
				end
			end
		end
		else if (we) begin
			if (!in_win) $display("[DDR3] write outside the VRAM window: %07X", addr);
			else for (i = 0; i < 8; i = i + 1)
				if (be[i]) mem[a][8*i +: 8] <= din[8*i +: 8];
		end
		if (rd) begin
			if (!in_win && !in_mb) $display("[DDR3] read outside the VRAM window: %07X", addr);
			rd_mb    <= in_mb;
			rd_maddr <= ma;
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
			dout       <= rd_mb ? mb[rd_maddr] : mem[rd_addr];
			rd_maddr   <= rd_maddr + 1'b1;
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
