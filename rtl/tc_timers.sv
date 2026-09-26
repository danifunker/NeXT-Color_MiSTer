//============================================================================
//  tc_timers -- the event counter ($0201A000) and the hardclock ($02016000).
//
//  Event counter: 20-bit free-running microsecond counter (hardware-summary
//  13.1).  Every ROM delay busy-waits on it (delay_us $01008936), so it must
//  run at 1 MHz from reset.  The ROM reads the four bytes one at a time:
//  +0 (discarded), +1 = bits 19:16, +2 = 15:8, +3 = 7:0 (timer_read_us
//  $0100889c).  Previous System_Timer_Read serves byte 0 and leaves the
//  whole long in the I/O shadow for bytes 1..3, so the count is latched by
//  the access that includes byte 0 and bytes 1..3 read the latch; a write
//  clears the counter (System_Timer_Write).  The register mirrors across
//  $0201A000-$0201BFFF (mask $0001E003).
//
//  Hardclock: from NeXT_MiSTer rtl/next/next_timer.sv (Previous sysReg.c
//  Hardclock*), on the tc_machine device port.  +0/+1 write the period
//  staging bytes and read the latched period, +4 is the CSR (bit 7
//  enable, bit 6 latch, self-clearing).  While enabled with a non-zero
//  period, INT_TIMER (status bit 29) is raised every `period` us; reading
//  the CSR releases it.  Used only by the POST timer test on the way to the
//  prompt (hardware-summary 13.2).
//
//  Device port contract: stb 1-cycle, ack 1-cycle one clock later.
//============================================================================

module tc_timers #(parameter CLK_HZ = 33000000)
(
	input             clk,
	input             reset,

	input             stb,
	input             we,
	input             sel_hc,        // 1 = hardclock, 0 = event counter
	input             a2,            // longword +4 (hardclock CSR)
	input       [3:0] be,
	input      [31:0] wdata,
	output reg [31:0] rdata,
	output reg        ack,

	output reg        int_timer      // level: status bit 29
);

localparam US_DIV = CLK_HZ / 1000000;

localparam integer PW = $clog2(US_DIV);
localparam [PW-1:0] PMAX = US_DIV - 1;
reg [PW-1:0] presc;
wire us_tick = (presc == PMAX);

reg [19:0] evc, evc_latch;

reg  [7:0] hc0, hc1, csr;
reg [15:0] period, hcount;

always @(posedge clk) begin
	ack <= 0;
	if (reset) begin
		presc <= 0;
		evc <= 0; evc_latch <= 0;
		hc0 <= 0; hc1 <= 0; csr <= 0; period <= 0; hcount <= 0;
		int_timer <= 0;
		rdata <= 0;
	end
	else begin
		presc <= us_tick ? {PW{1'b0}} : presc + 1'd1;
		if (us_tick) evc <= evc + 20'd1;

		if (us_tick && csr[7] && period != 0) begin
			if (hcount >= period - 16'd1) begin
				hcount    <= 0;
				int_timer <= 1;
			end
			else hcount <= hcount + 16'd1;
		end

		if (stb) begin
			ack <= 1;
			if (!sel_hc) begin
				if (we) evc <= 0;
				else if (be[3]) begin
					evc_latch <= evc;
					rdata     <= {12'd0, evc};
				end
				else rdata <= {12'd0, evc_latch};
			end
			else if (!a2) begin
				rdata <= {period, 16'd0};
				if (we) begin
					if (be[3]) hc0 <= wdata[31:24];
					if (be[2]) hc1 <= wdata[23:16];
				end
			end
			else begin
				rdata <= {csr, 24'd0};
				if (we && be[3]) begin
					csr <= wdata[31:24] & 8'hBF;
					if (wdata[30]) begin
						period <= {hc0, hc1};
						hcount <= 0;
					end
				end
				else if (!we) int_timer <= 0;     // HardclockReadCSR
			end
		end
	end
end

endmodule
