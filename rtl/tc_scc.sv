//============================================================================
//  tc_scc -- Z8530 SCC register model at $02018000 ($02118000 alias).
//
//  From NeXT_MiSTer rtl/next/next_scc.sv (itself modelled on Previous
//  scc.c: one shared register pointer, RR0/RR1/WR2/WR12/WR13/WR15, WR9
//  reset commands, a one-byte loopback buffer that the ROM's SCC self test
//  passes against), moved onto the tc_machine device port, plus the Turbo's
//  serial clock select register:
//
//    +0 control B   +1 control A   +2 data B   +3 data A   (bytes)
//    +4 clock select (long; the ROM writes $0A, scc_calc_baud_tc $01008b30,
//       hardware-summary 11.1; Previous SCC_Clock_Read/Write: read back)
//
//  Byte lanes (big-endian be): +0 = be[3] = [31:24], +1 = be[2], +2 = be[1],
//  +3 = be[0].  The ROM uses byte accesses; with several lanes the lowest
//  address wins.  No baud timing, interrupts or UART yet (hardware-summary
//  11.2: the serial console is only used when the keyboard times out and
//  NVRAM asks for it).
//
//  Device port contract (tc_machine): stb 1-cycle, ack 1-cycle later.
//============================================================================

module tc_scc
(
	input             clk,
	input             reset,

	input             stb,
	input             we,
	input             a2,            // 1 = clock select register (+4)
	input       [3:0] be,
	input      [31:0] wdata,
	output reg [31:0] rdata,
	output reg        ack
);

localparam RR0_RXAVAIL = 8'h01;
localparam RR0_TXEMPTY = 8'h04;

reg [3:0] ptr;
reg [7:0] wr12_a, wr12_b, wr13_a, wr13_b, wr15_a, wr15_b, wr2;
reg [7:0] rr0_a, rr0_b;
reg [7:0] scc_buf;
reg [31:0] clksel;

// the register this access addresses: 0 ctrl B, 1 ctrl A, 2 data B, 3 data A
wire [1:0] reg_i = be[3] ? 2'd0 : be[2] ? 2'd1 : be[1] ? 2'd2 : 2'd3;
wire [7:0] wb    = (reg_i == 2'd0) ? wdata[31:24] : (reg_i == 2'd1) ? wdata[23:16] :
                   (reg_i == 2'd2) ? wdata[15:8]  : wdata[7:0];
wire       ch_b  = !reg_i[0];
wire       is_data = reg_i[1];

wire [7:0] ctrl_a = (ptr == 4'd0)  ? rr0_a :
                    (ptr == 4'd1)  ? 8'h06 :
                    (ptr == 4'd2)  ? wr2 :
                    (ptr == 4'd12) ? wr12_a :
                    (ptr == 4'd13) ? wr13_a :
                    (ptr == 4'd15) ? wr15_a : 8'h00;
wire [7:0] ctrl_b = (ptr == 4'd0)  ? rr0_b :
                    (ptr == 4'd1)  ? 8'h06 :
                    (ptr == 4'd2)  ? wr2 :
                    (ptr == 4'd12) ? wr12_b :
                    (ptr == 4'd13) ? wr13_b :
                    (ptr == 4'd15) ? wr15_b : 8'h00;

wire [3:0] ptr_next = {(wb & 8'h38) == 8'h08, wb[2:0]};

always @(posedge clk) begin
	ack <= 0;
	if (reset) begin
		ptr <= 0;
		wr2 <= 0;
		wr12_a <= 0; wr12_b <= 0;
		wr13_a <= 0; wr13_b <= 0;
		wr15_a <= 8'hF8; wr15_b <= 8'hF8;
		rr0_a <= 8'h44; rr0_b <= 8'h44;
		scc_buf <= 0;
		clksel <= 0;
		rdata <= 0;
	end
	else if (stb) begin
		ack <= 1;
		if (a2) begin
			rdata <= clksel;
			if (we) begin
				if (be[3]) clksel[31:24] <= wdata[31:24];
				if (be[2]) clksel[23:16] <= wdata[23:16];
				if (be[1]) clksel[15:8]  <= wdata[15:8];
				if (be[0]) clksel[7:0]   <= wdata[7:0];
			end
		end
		else begin
			rdata <= {ctrl_b, ctrl_a, scc_buf, scc_buf};
			if (!is_data) begin
				if (we) begin
					if (ptr == 0) ptr <= ptr_next;
					else begin
						case (ptr)
						4'd1: if ((wb & 8'hC0) == 8'hC0) begin     // DMA request mode raises RX
							if (ch_b) rr0_b <= rr0_b | RR0_RXAVAIL;
							else      rr0_a <= rr0_a | RR0_RXAVAIL;
						end
						4'd9: case (wb[7:6])                          // master interrupt reset
							2'd1: rr0_b <= (rr0_b & ~8'hC7) | 8'h44;
							2'd2: rr0_a <= (rr0_a & ~8'hC7) | 8'h44;
							2'd3: begin
								rr0_a <= (rr0_a & ~8'hC7) | 8'h44;
								rr0_b <= (rr0_b & ~8'hC7) | 8'h44;
							end
							default: ;
						endcase
						4'd2:  wr2 <= wb;
						4'd12: if (ch_b) wr12_b <= wb; else wr12_a <= wb;
						4'd13: if (ch_b) wr13_b <= wb; else wr13_a <= wb;
						4'd15: if (ch_b) wr15_b <= wb; else wr15_a <= wb;
						default: ;
						endcase
						ptr <= 0;
					end
				end
				else ptr <= 0;                  // a control read resets the pointer
			end
			else if (we) begin
				// scc_data_write(): buffer the byte, loopback raises RX available
				scc_buf <= wb;
				if (ch_b) rr0_b <= RR0_TXEMPTY | RR0_RXAVAIL;
				else      rr0_a <= RR0_TXEMPTY | RR0_RXAVAIL;
			end
		end
	end
end

endmodule
