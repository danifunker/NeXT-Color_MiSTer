//============================================================================
//  tb_tc_dsp -- rtl/tc_dsp.sv against the real ARM side: Main_MiSTer
//  support/next/next_dsp.cpp and Previous's DSP56001 core (support/next/
//  dsp56k), stepped through DPI (tb_tc_dsp_dpi.cpp) and sharing the DDR3
//  mailbox with the RTL.  The bench is the 68040 (the host port registers)
//  and the PC chip's DSP DMA channel (a byte array behind dd_*).
//
//  The DSP program (hand-assembled, checked with Previous's disassembler):
//    p:0000  0aa823         bset #3,x:$ffe8           HF2 = 1
//    p:0001  0aa980 000001  jclr #0,x:$ffe9,p:$0001   wait HRDF
//    p:0003  56f000 00ffeb  move x:$ffeb,a            a = HRX
//    p:0005  240100         move #$01,x0              x0 = $010000
//    p:0006  200040         add x0,a
//    p:0007  0aa981 000007  jclr #1,x:$ffe9,p:$0007   wait HTDE
//    p:0009  567000 00ffeb  move a,x:$ffeb            HTX = a
//    p:000b  0c0001         jmp p:$0001
//  so every word the host sends comes back plus $010000.
//
//  Prints "PASS: ..." or "FAIL: ..." and exits non-zero on failure.
//  Run: bash verilator/unit/run_tb_tc_dsp.sh
//============================================================================
`timescale 1ns/1ps

module tb_tc_dsp;

localparam integer CLK_HZ = 33000000;

import "DPI-C" function longint mb_read(input int widx);
import "DPI-C" function void    mb_write(input int widx, input longint v);
import "DPI-C" function int     arm_step(input int n);
import "DPI-C" function int     arm_dsp_state();

logic clk = 1'b0;
always #15 clk = ~clk;

logic        reset = 1'b1;
logic        stb = 1'b0, we = 1'b0, addr2 = 1'b0;
logic  [3:0] be = 4'd0;
logic [31:0] wdata = 32'd0;
wire  [31:0] rdata;
wire         ack;
logic [31:0] scr2 = 32'd0;
wire         int_dsp;
wire         dd_req, dd_we;
wire   [7:0] dd_wdata;
logic        dd_ack = 1'b0;
logic  [7:0] dd_rdata = 8'd0;
wire         dd_avail;
logic        dd_blkend = 1'b0;
wire         m_req, m_we;
wire  [28:0] m_addr;
wire  [63:0] m_wdata;
logic [63:0] m_rdata = 64'd0;
logic        m_ack = 1'b0;

tc_dsp #(.CLK_HZ(CLK_HZ)) dut (.*);

int errors = 0, checks = 0;
task automatic check(input bit cond, input string msg);
	checks++;
	if (!cond) begin
		errors++;
		$display("[%0t] FAIL: %s", $time, msg);
	end
endtask

//----------------------------------------------------------------------------
// the mailbox port: a few clocks per 64-bit word, into the shared array
//----------------------------------------------------------------------------
localparam [28:0] LINK_BASE = 29'h0608_0000;
int mb_wait = 0;
int mb_ops = 0;
always @(posedge clk) begin
	m_ack <= 1'b0;
	if (m_req && !m_ack) begin
		if (mb_wait == 0) mb_wait <= 6;
		else if (mb_wait == 1) begin
			mb_wait <= 0;
			check(m_addr >= LINK_BASE && m_addr < LINK_BASE + 29'h800,
			      $sformatf("mailbox access at %07x inside the window", m_addr));
			if (m_we) mb_write(int'(m_addr - LINK_BASE), m_wdata);
			else      m_rdata <= mb_read(int'(m_addr - LINK_BASE));
			m_ack <= 1'b1;
			mb_ops++;
		end
		else mb_wait <= mb_wait - 1;
	end
end

//----------------------------------------------------------------------------
// the ARM: a slice of DSP instructions every ARM_EVERY clocks
//----------------------------------------------------------------------------
int arm_every = 64, arm_slice = 16;
int arm_t = 0;
longint dsp_instr = 0;
int arm_calls = 0;
always @(posedge clk) begin
	if (!reset) begin
		arm_t <= arm_t + 1;
		if (arm_t >= arm_every) begin
			int n;
			arm_t <= 0;
			n = arm_step(arm_slice);
			if (n > 0) dsp_instr += n;
			arm_calls++;
		end
	end
end

//----------------------------------------------------------------------------
// the DSP DMA channel: bytes at dptr .. dlimit of dmem
//----------------------------------------------------------------------------
logic [7:0] dmem [0:255];
int dptr = 0, dlimit = 0, dd_wait = 0, blkends = 0;
assign dd_avail = dd_en && (dptr < dlimit);
logic dd_en = 1'b0;
always @(posedge clk) begin
	dd_ack <= 1'b0;
	dd_blkend <= 1'b0;
	if (dd_req && !dd_ack && dd_avail) begin
		if (dd_wait == 0) dd_wait <= 3;
		else if (dd_wait == 1) begin
			dd_wait <= 0;
			if (dd_we) dmem[dptr] <= dd_wdata;
			else       dd_rdata <= dmem[dptr];
			dd_ack <= 1'b1;
			if (dptr + 1 == dlimit) begin dd_blkend <= 1'b1; blkends++; end
			dptr <= dptr + 1;
		end
		else dd_wait <= dd_wait - 1;
	end
end

//----------------------------------------------------------------------------
// the 68040
//----------------------------------------------------------------------------
localparam [2:0] ICR = 3'd0, CVR = 3'd1, ISR = 3'd2, IVR = 3'd3,
                 TRX0 = 3'd4, TRXH = 3'd5, TRXM = 3'd6, TRXL = 3'd7;

task automatic acc(input bit w, input [2:0] r, input [7:0] v, output logic [7:0] q);
	@(negedge clk);
	stb = 1'b1; we = w; addr2 = r[2]; be = 4'b1000 >> r[1:0];
	wdata = {24'd0, v} << (8 * (3 - int'(r[1:0])));
	@(negedge clk);
	stb = 1'b0; we = 1'b0; be = 4'd0; wdata = 32'd0;
	check(ack, "ack one clock after stb");
	q = 8'(rdata >> (8 * (3 - int'(r[1:0]))));
	repeat (2) @(negedge clk);                // the 68040's next access is clocks away
endtask
task automatic wr(input [2:0] r, input [7:0] v);
	logic [7:0] q;
	acc(1'b1, r, v, q);
endtask
function automatic int dummy(); return 0; endfunction
task automatic rd(input [2:0] r, output logic [7:0] v);
	acc(1'b0, r, 8'd0, v);
endtask

// wait for an ISR bit, at most n polls
task automatic wait_isr(input int bitn, input bit val, input int n, input string what, output bit ok);
	logic [7:0] v;
	ok = 1'b0;
	for (int i = 0; i < n; i++) begin
		rd(ISR, v);
		if (v[bitn] == val) begin ok = 1'b1; break; end
		repeat (20) @(negedge clk);
	end
	check(ok, $sformatf("ISR bit %0d = %0d (%s)", bitn, val, what));
endtask

task automatic send_word(input [23:0] w);
	bit ok;
	wait_isr(1, 1'b1, 20000, "TXDE before a word", ok);
	wr(TRXH, w[23:16]);
	wr(TRXM, w[15:8]);
	wr(TRXL, w[7:0]);
endtask

task automatic recv_word(output logic [23:0] w);
	bit ok;
	logic [7:0] h, m, l;
	wait_isr(0, 1'b1, 20000, "RXDF before a read", ok);
	rd(TRXH, h); rd(TRXM, m); rd(TRXL, l);
	w = {h, m, l};
endtask

localparam logic [23:0] PROG [0:11] = '{
	24'h0aa823, 24'h0aa980, 24'h000001, 24'h56f000, 24'h00ffeb, 24'h240100,
	24'h200040, 24'h0aa981, 24'h000007, 24'h567000, 24'h00ffeb, 24'h0c0001};

// SCR2: DSP_RESET (31), BLK_END (30), UNPKD (29), MODE_B/A (28/27), MEM_EN (5)
task automatic dsp_boot();
	scr2[31] = 1'b0;                           // reset
	repeat (50) @(negedge clk);
	scr2[5] = 1'b1;                            // DSP memory on
	scr2[28] = 1'b1; scr2[27] = 1'b0;          // mode 1: bootstrap from the host
	repeat (5) @(negedge clk);
	scr2[31] = 1'b1;                           // start
	for (int i = 0; i < 12; i++) send_word(PROG[i]);
	wr(ICR, 8'h08);                            // HF0: the bootstrap ends, the program runs
endtask

//----------------------------------------------------------------------------
// test
//----------------------------------------------------------------------------
initial begin : watchdog
	#400ms;
	$display("FAIL: tb_tc_dsp timed out");
	$fatal(1, "timeout");
end

initial begin : test
	logic [7:0] v;
	logic [23:0] w;
	bit ok;
	int k, sent, got;

	if ($value$plusargs("arm_every=%d", arm_every)) ;
	if ($value$plusargs("arm_slice=%d", arm_slice)) ;
	$display("ARM: %0d DSP instructions every %0d clocks", arm_slice, arm_every);

	repeat (10) @(negedge clk);
	reset = 1'b0;

	// reset values (dsp_core_reset)
	rd(ICR, v); check(v == 8'h00, $sformatf("ICR after reset %02x", v));
	rd(CVR, v); check(v == 8'h12, $sformatf("CVR after reset %02x", v));
	rd(ISR, v); check(v == 8'h06, $sformatf("ISR after reset %02x (TRDY|TXDE)", v));
	rd(IVR, v); check(v == 8'h0F, $sformatf("IVR after reset %02x", v));
	rd(TRX0, v); check(v == 8'h00, "TRX0 reads 0");
	wr(IVR, 8'h5A); rd(IVR, v); check(v == 8'h5A, "IVR r/w");
	wr(ICR, 8'h04); rd(ICR, v); check(v == 8'h00, "ICR bit 2 reads 0");

	// the link comes up: the FPGA word, then the ARM follows its generation
	for (k = 0; k < 200 && !dut.arm_ok; k++) repeat (1000) @(negedge clk);
	check(dut.arm_ok, "the ARM daemon linked to this FPGA generation");
	check(mb_read(0) >>> 48 == 64'hD5F1, "FPGA word magic");
	check(mb_read(1) >>> 48 == 64'hD5A1, "ARM word magic");

	// ------------------------------------------------------------------
	$display("bootstrap + echo");
	dsp_boot();
	wait_isr(3, 1'b1, 5000, "HF2 set by the program's bset #3,x:$ffe8", ok);
	for (k = 0; k < 6; k++) begin
		send_word(24'h000100 * k + 24'h000033);
		recv_word(w);
		check(w == 24'h010000 + 24'h000100 * k + 24'h000033,
		      $sformatf("echo %0d: %06x", k, w));
	end
	rd(ISR, v);
	check(v[1:0] == 2'b10 && v[2], $sformatf("idle: TXDE, TRDY, no RXDF (ISR %02x)", v));

	// stream: keep TX busy while collecting RX, order kept
	$display("stream (DSP instructions so far %0d, at %0t)", dsp_instr, $time);
	sent = 0; got = 0;
	while (got < 24) begin
		rd(ISR, v);
		if (v[1] && sent < 24) begin
			wr(TRXH, 8'h00); wr(TRXM, 8'(sent)); wr(TRXL, 8'h55);
			sent++;
		end
		else if (v[0]) begin
			logic [7:0] h, m, l;
			rd(TRXH, h); rd(TRXM, m); rd(TRXL, l);
			check({h, m, l} == {8'h01, 8'(got), 8'h55}, $sformatf("stream word %0d: %02x%02x%02x", got, h, m, l));
			got++;
		end
		else repeat (10) @(negedge clk);
	end

	// a long stream with the host's pace swept against the link: an "HRX
	// read" from the ARM landing in the clock a TX word goes on the link
	// was lost, TRDY never came back (the Music Kit waits for TRDY before
	// every host message and hung after loading its monitor)
	$display("long stream, TRDY after it");
	sent = 0; got = 0;
	void'($urandom(32'h5eed));
	while (got < 3000) begin
		rd(ISR, v);
		if (v[0]) begin
			logic [7:0] h, m, l;
			rd(TRXH, h); rd(TRXM, m); rd(TRXL, l);
			if ({h, m, l} != {8'h01, 8'(got), 8'h3C})
				check(1'b0, $sformatf("long stream word %0d: %02x%02x%02x", got, h, m, l));
			got++;
		end
		else if (v[1] && sent < 3000) begin
			repeat ($urandom_range(0, 263)) @(negedge clk);   // across the 4 us poll
			wr(TRXH, 8'h00); wr(TRXM, 8'(sent)); wr(TRXL, 8'h3C);
			sent++;
		end
		else @(negedge clk);
	end
	check(got == 3000, "long stream: 3000 words echoed in order");
	wait_isr(2, 1'b1, 20000, "TRDY after the long stream", ok);
	check(dut.tx_out == 3'd0, $sformatf("no word left counted as unread (tx_out %0d)", dut.tx_out));

	// interrupt mode: HREQ with RREQ
	$display("HREQ");
	wr(ICR, 8'h09);                            // RREQ (keep HF0)
	rd(ISR, v); check(!v[7] && !int_dsp, "HREQ low with RX empty");
	send_word(24'h123456);
	for (k = 0; k < 2000 && !int_dsp; k++) @(negedge clk);
	check(int_dsp, "RXDF + RREQ raises HREQ -> int_dsp");
	rd(ISR, v); check(v[7] && v[0], $sformatf("ISR HREQ|RXDF (%02x)", v));
	recv_word(w); check(w == 24'h133456, $sformatf("word under HREQ %06x", w));
	repeat (4) @(negedge clk);
	check(!int_dsp, "HREQ drops when RX is read");
	wr(ICR, 8'h0A);                            // TREQ: TX empty -> HREQ
	rd(ISR, v); check(v[7] && int_dsp, "TXDE + TREQ raises HREQ");
	wr(ICR, 8'h08);
	check(!int_dsp, "no request bits: no interrupt");

	// DMA: memory -> DSP, 24-bit mode (H M L per word), then DSP -> memory in
	// 16-bit mode (M L), then unpacked (pad H M L)
	$display("DMA");
	for (k = 0; k < 12; k++) dmem[k] = 8'(k * 16 + 1);
	dptr = 0; dlimit = 12; dd_en = 1'b1;
	wr(ICR, 8'h2A);                            // HM 01 (24-bit DMA), TREQ, HF0
	for (k = 0; k < 4; k++) begin
		recv_word(w);
		check(w == {8'(k * 48 + 1) + 8'h01, 8'(k * 48 + 17), 8'(k * 48 + 33)},
		      $sformatf("DMA to the DSP, word %0d came back %06x", k, w));
	end
	check(dptr == 12 && blkends == 1, $sformatf("DMA took 12 bytes (%0d), one block end", dptr));
	rd(ISR, v); check(v[6], "ISR DMA set in DMA mode");
	wr(ICR, 8'h08);
	dd_en = 1'b0;

	for (k = 0; k < 64; k++) dmem[k] = 8'hEE;
	dptr = 0; dlimit = 8; dd_en = 1'b1;
	wr(ICR, 8'hC9);                            // INIT, HM 10 (16-bit DMA), RREQ, HF0
	for (k = 0; k < 4; k++) send_word({8'h00, 8'(k), 8'(k + 8'h80)});
	for (k = 0; k < 20000 && dptr < 8; k++) @(negedge clk);
	ok = 1'b1;
	for (k = 0; k < 4; k++) ok = ok && dmem[2 * k] == 8'(k) && dmem[2 * k + 1] == 8'(k + 8'h80);
	check(dptr == 8 && ok, $sformatf("DMA from the DSP, 16-bit: %0d bytes, %02x %02x %02x %02x",
	      dptr, dmem[0], dmem[1], dmem[2], dmem[3]));
	wr(ICR, 8'h08);
	dd_en = 1'b0;

	for (k = 0; k < 64; k++) dmem[k] = 8'hEE;
	dptr = 0; dlimit = 8; dd_en = 1'b1;
	scr2[29] = 1'b1;                           // unpacked
	wr(ICR, 8'hA9);                            // INIT, HM 01, RREQ, HF0
	for (k = 0; k < 2; k++) send_word({8'h20, 8'(k), 8'h77});
	for (k = 0; k < 20000 && dptr < 8; k++) @(negedge clk);
	check(dptr == 8 && dmem[0] == 8'h00 && dmem[1] == 8'h21 && dmem[2] == 8'h00 && dmem[3] == 8'h77 &&
	      dmem[4] == 8'h00 && dmem[5] == 8'h21 && dmem[6] == 8'h01 && dmem[7] == 8'h77,
	      $sformatf("unpacked DMA: pad H M L: %02x %02x %02x %02x %02x %02x %02x %02x",
	      dmem[0], dmem[1], dmem[2], dmem[3], dmem[4], dmem[5], dmem[6], dmem[7]));
	scr2[29] = 1'b0;
	wr(ICR, 8'h08);
	dd_en = 1'b0;

	// ------------------------------------------------------------------
	// DSP reset: the host side resets too; boot again and echo
	$display("reset + boot again");
	scr2[31] = 1'b0;
	repeat (4) @(negedge clk);
	rd(ICR, v); check(v == 8'h00, "ICR after a DSP reset");
	rd(ISR, v); check(v == 8'h06, $sformatf("ISR after a DSP reset %02x", v));
	rd(CVR, v); check(v == 8'h12, "CVR after a DSP reset");
	dsp_boot();
	wait_isr(3, 1'b1, 5000, "HF2 again", ok);
	send_word(24'h000777);
	recv_word(w); check(w == 24'h010777, $sformatf("echo after the reboot %06x", w));

	// a slower ARM (the real one runs ~1 DSP instruction per 22 clocks)
	$display("slow ARM");
	arm_every = 400; arm_slice = 8;
	for (k = 0; k < 4; k++) begin
		send_word(24'h000100 * k + 24'h000009);
		recv_word(w);
		check(w == 24'h010009 + 24'h000100 * k, $sformatf("slow echo %0d: %06x", k, w));
	end

	$display("DSP instructions run: %0d in %0d ARM passes, mailbox words: %0d, simulated %0t",
	         dsp_instr, arm_calls, mb_ops, $time);
	if (errors == 0)
		$display("PASS: tb_tc_dsp (%0d checks)", checks);
	else
		$display("FAIL: tb_tc_dsp (%0d of %0d checks failed)", errors, checks);
	if (errors != 0) $fatal(1, "tb_tc_dsp failed");
	$finish;
end

endmodule
