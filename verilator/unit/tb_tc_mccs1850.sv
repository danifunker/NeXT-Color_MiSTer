//============================================================================
//  tb_tc_mccs1850 -- self-checking unit test of rtl/tc_mccs1850.sv
//
//  The pins are driven the way the Rev 3.3 v74 ROM drives SCR2:
//    rtc_read_reg_raw $010087e8 / rtc_write_reg $010086e8 (one SCR2 long
//    write, then delay_us(1), per step; read bits sampled after the falling
//    edge and its delay), rtc_modify_reg $0100828c, nvram_read $0100861c
//    (32 single-byte reads + checksum check), the walking-one RAM test of
//    nvram_check_or_rtc_ramtest $01005cd2, post_rtc_test $010052d0 (with
//    rtc_start_clock $01008400) and rtc_power_int_handler $010082ca.
//  SCR2 bit 10 is read back the way the machine muxes it:
//    rtc_drive ? rtc_dout : CPU-written bit.
//  A second instance (dut2) checks the clock before seeding and the
//  seed clamp (>= 2038 -> 1987-07-02, Previous newrtc_check_time).
//
//  Run: verilator/unit/run_tb_tc_mccs1850.sh
//============================================================================

`timescale 1ns/1ps

module tb_tc_mccs1850;

localparam integer CLK_HZ = 10000;     // 1 "second" = 10000 clocks
localparam integer D      = 3;         // clocks per delay_us(1) (hardware: ~33-66)
localparam integer MS     = CLK_HZ / 1000;

localparam [31:0] NEXT_START_SEC = 32'd552225600;

reg clk = 1'b0;
always #5 clk = ~clk;

longint cyc = 0;
always @(posedge clk) cyc <= cyc + 1;

reg         reset = 1'b0, config_reset = 1'b0;
reg         ce = 1'b0, sclk = 1'b0, din = 1'b0;
reg  [32:0] ts = 33'd0, ts2 = 33'd0;
reg   [1:0] ram_cfg = 2'd1;
reg         pot_on = 1'b1;
reg  [95:0] boot_cmd = 96'd0;
reg         power_key = 1'b0;

wire        dout, drive, pint, dout2, drive2, pint2;
wire  [7:0] dbg, dbg2;

tc_mccs1850 #(.CLK_HZ(CLK_HZ)) dut (
	.clk(clk), .reset(reset), .config_reset(config_reset),
	.rtc_ce(ce), .rtc_clk(sclk), .rtc_din(din), .rtc_dout(dout), .rtc_drive(drive),
	.timestamp(ts), .ram_cfg(ram_cfg), .pot_on(pot_on), .boot_cmd(boot_cmd),
	.power_key(power_key), .power_int(pint), .dbg_last_reg(dbg)
);

tc_mccs1850 #(.CLK_HZ(CLK_HZ)) dut2 (
	.clk(clk), .reset(reset), .config_reset(1'b0),
	.rtc_ce(ce), .rtc_clk(sclk), .rtc_din(din), .rtc_dout(dout2), .rtc_drive(drive2),
	.timestamp(ts2), .ram_cfg(2'd0), .pot_on(1'b0), .boot_cmd(96'd0),
	.power_key(1'b0), .power_int(pint2), .dbg_last_reg(dbg2)
);

reg  which = 1'b0;                     // 0 = read back dut, 1 = dut2
wire bit10 = which ? (drive2 ? dout2 : din) : (drive ? dout : din);

integer errors = 0;
integer checks = 0;

task automatic fail(input string msg);
	begin
		errors = errors + 1;
		$display("FAIL [%0d]: %s", cyc, msg);
	end
endtask

task automatic expect8(input [7:0] got, input [7:0] exp, input string what);
	begin
		checks = checks + 1;
		if (got !== exp) fail($sformatf("%s: got %h expected %h", what, got, exp));
	end
endtask

task automatic expect32(input [31:0] got, input [31:0] exp, input string what);
	begin
		checks = checks + 1;
		if (got !== exp) fail($sformatf("%s: got %h expected %h", what, got, exp));
	end
endtask

task automatic expect1(input got, input exp, input string what);
	begin
		checks = checks + 1;
		if (got !== exp) fail($sformatf("%s: got %0d expected %0d", what, got, exp));
	end
endtask

task automatic wait_clks(input integer n);
	repeat (n) @(posedge clk);
endtask

// the chip must not drive RTDATA outside a read data phase
reg in_rd_data = 1'b0;
always @(posedge clk) if ((drive && !in_rd_data) || (drive2 && !in_rd_data)) begin
	errors = errors + 1;
	$display("FAIL [%0d]: chip drives RTDATA outside a read data phase", cyc);
end

//----------------------------------------------------------------------------
// ROM primitives
//----------------------------------------------------------------------------

// one `move.l d,(a3)` to SCR2 followed by delay_us(1)
task automatic scr2(input c, input k, input d);
	begin
		@(posedge clk);
		ce <= c; sclk <= k; din <= d;
		wait_clks(D);
	end
endtask

task automatic send_addr(input [7:0] a);
	integer i;
	reg [7:0] s;
	begin
		s = a;
		for (i = 0; i < 8; i = i + 1) begin
			scr2(1'b1, 1'b0, s[7]);     // base|$100|d   (loc_01008818)
			scr2(1'b1, 1'b1, s[7]);     // |= $200       ($01008830)
			scr2(1'b1, 1'b0, s[7]);     // &= ~$200      ($01008838)
			s = s << 1;
		end
	end
endtask

// rtc_read_reg_raw $010087e8
task automatic rtc_read(input [7:0] r, output [7:0] v);
	integer i;
	reg [7:0] b;
	begin
		b = 8'd0;
		scr2(1'b1, 1'b0, 1'b0);         // base|$100: CE high ($0100880a)
		send_addr(r);
		in_rd_data = 1'b1;
		for (i = 0; i < 8; i = i + 1) begin
			scr2(1'b1, 1'b1, 1'b0);     // base|$300: CLK high ($0100884e)
			scr2(1'b1, 1'b0, 1'b0);     // base|$100: CLK low  ($01008860), delay
			b = {b[6:0], bit10};        // move.l (a3),d0; andi.l #$400 ($01008868)
			wait_clks(D);               // delay_us(1) ($0100887c)
		end
		scr2(1'b0, 1'b0, 1'b0);         // SCR2 = base: CE low ($0100888a)
		in_rd_data = 1'b0;
		v = b;
	end
endtask

// rtc_write_reg $010086e8
task automatic rtc_write(input [7:0] r, input [7:0] v);
	begin
		scr2(1'b1, 1'b0, 1'b0);         // ($01008714)
		send_addr(r | 8'h80);           // ori.b #$80,d4 ($01008704)
		send_addr(v);                   // data bits like the address ($01008752)
		scr2(1'b0, 1'b0, 1'b0);         // ($01008784)
	end
endtask

// rtc_modify_reg $0100828c: read, clear mask, or (val & mask), write
task automatic rtc_modify(input [7:0] r, input [7:0] mask, input [7:0] val);
	reg [7:0] v;
	begin
		rtc_read(r, v);
		rtc_write(r, (v & ~mask) | (val & mask));
	end
endtask

task automatic rtc_read_time(output [31:0] t);
	reg [7:0] b0, b1, b2, b3;
	begin
		// rtc_get_time $010084d6 -> rtc_read_regs($20, buf, 4)
		rtc_read(8'h20, b0);
		rtc_read(8'h21, b1);
		rtc_read(8'h22, b2);
		rtc_read(8'h23, b3);
		t = {b0, b1, b2, b3};
	end
endtask

// rtc_power_int_handler $010082ca; returns 1 if a power-down request was seen
task automatic power_int_handler(output integer pd);
	reg [7:0] st;
	integer guard;
	begin
		pd = 0;
		guard = 0;
		while (pint && guard < 8) begin    // while (*$02007000 & INT_POWER)
			guard = guard + 1;
			rtc_read(8'h30, st);
			if (!st[7]) begin pd = 1; guard = 99; end
			else begin
				if (st[4]) rtc_modify(8'h31, 8'h04, 8'hFF);  // CLRFTU
				if (st[2]) rtc_modify(8'h31, 8'h02, 8'h00);  // LBE off
				if (st[1]) rtc_modify(8'h31, 8'h08, 8'hFF);  // CLRALARM
				if (st[0]) begin rtc_modify(8'h31, 8'h01, 8'hFF); pd = 1; end  // CLRPDOWN
			end
		end
		if (guard == 8) fail("power_int never cleared by the handler loop");
	end
endtask

// rtc_start_clock $01008400 (rtc_int_clear $010083d4 first)
task automatic rtc_start_clock;
	reg [7:0] st;
	integer pd;
	begin
		rtc_read(8'h30, st);
		if (!st[7]) rtc_write(8'h32, 8'h00);
		power_int_handler(pd);
		rtc_read(8'h30, st);
		if (st[7]) rtc_modify(8'h31, 8'h80, 8'hFF);
		else       rtc_write(8'h31, 8'hB0);
	end
endtask

//----------------------------------------------------------------------------
// NVRAM image helpers
//----------------------------------------------------------------------------

reg [7:0] got [0:31];
reg [7:0] exp_img [0:31];

// net_ip_checksum $0100743c over 32 bytes with the word at +$1E zeroed
function automatic [15:0] rom_sum(input integer dummy);
	integer i;
	reg [31:0] s;
	begin
		s = 32'd0;
		for (i = 0; i < 30; i = i + 2) begin
			s = s + {16'd0, got[i], got[i+1]};
			if (s >= 32'h10000) s = s - 32'h10000 + 32'd1;
		end
		rom_sum = s[15:0];
		if (dummy != 0) rom_sum = 16'h0000;
	end
endfunction

task automatic build_expected(input [1:0] cfg, input pot, input [95:0] bc);
	integer i;
	reg [3:0] code [0:3];
	reg [15:0] w;
	reg [31:0] s;
	begin
		for (i = 0; i < 32; i = i + 1) exp_img[i] = 8'h00;
		// ni_reset long: reset 9 (31:28), allow eject (26), brightness $3D (19:14)
		{exp_img[0], exp_img[1], exp_img[2], exp_img[3]} = (32'd9 << 28) | (32'd1 << 26) | (32'h3D << 14);
		// SIMM codes per bank (mem_bank_size_t): 1 = 32 MB pair, 2 = 8 MB pair
		case (cfg)
			2'd0: begin code[0] = 1; code[1] = 1; code[2] = 0; code[3] = 0; end
			2'd1: begin code[0] = 1; code[1] = 1; code[2] = 1; code[3] = 1; end
			2'd2: begin code[0] = 2; code[1] = 2; code[2] = 0; code[3] = 0; end
			default: begin code[0] = 1; code[1] = 0; code[2] = 0; code[3] = 0; end
		endcase
		// mon_init $0100151c: (code & 7) << 3i, (code & 8) << (9 + i)
		w = 16'd0;
		for (i = 0; i < 4; i = i + 1)
			w = w | ({13'd0, code[i][2:0]} << (3 * i)) | ({12'd0, code[i] & 4'd8} << (9 + i));
		exp_img[10] = w[15:8];
		exp_img[11] = w[7:0];
		exp_img[14] = pot ? 8'h11 : 8'h00;
		exp_img[17] = 8'hA0;
		for (i = 0; i < 12; i = i + 1) exp_img[18 + i] = bc[95 - 8 * i -: 8];
		s = 32'd0;
		for (i = 0; i < 30; i = i + 2) begin
			s = s + {16'd0, exp_img[i], exp_img[i+1]};
			if (s >= 32'h10000) s = s - 32'h10000 + 32'd1;
		end
		exp_img[30] = ~s[15:8];
		exp_img[31] = ~s[7:0];
	end
endtask

// nvram_read $0100861c: regs 0..31, then the checksum rule
task automatic nvram_read(output integer ok);
	integer i;
	reg [15:0] sum;
	reg  [7:0] b;
	begin
		for (i = 0; i < 32; i = i + 1) begin
			rtc_read(i[7:0], b);        // (a temporary: Icarus mis-copies an
			got[i] = b;                 //  output argument into got[i])
		end
		sum = ~rom_sum(0);
		ok = (sum != 16'h0000) && (sum == {got[30], got[31]});
	end
endtask

task automatic check_image(input [1:0] cfg, input pot, input [95:0] bc, input string what);
	integer i, ok;
	reg [31:0] l;
	begin
		build_expected(cfg, pot, bc);
		nvram_read(ok);
		checks = checks + 1;
		if (!ok) fail($sformatf("%s: ROM rejects the checksum %h%h", what, got[30], got[31]));
		for (i = 0; i < 32; i = i + 1)
			expect8(got[i], exp_img[i], $sformatf("%s byte %0d", what, i));
		l = {got[0], got[1], got[2], got[3]};
		expect8({4'd0, l[31:28]}, 8'h09, {what, " reset field"});
		expect8({2'd0, l[19:14]}, 8'h3D, {what, " brightness"});
		expect1(got[17][7], 1'b1, {what, " new clock chip bit"});
		$display("  image %-26s: %h %h %h %h .. simm %h%h pot %h b17 %h boot \"%s\" cksum %h%h",
		         what, got[0], got[1], got[2], got[3], got[10], got[11], got[14], got[17],
		         {got[18], got[19], got[20], got[21], got[22], got[23], got[24], got[25],
		          got[26], got[27], got[28], got[29]}, got[30], got[31]);
	end
endtask

task automatic do_config_reset;
	begin
		@(posedge clk); config_reset <= 1'b1;
		wait_clks(5);
		@(posedge clk); config_reset <= 1'b0;
		wait_clks(40);
	end
endtask

//----------------------------------------------------------------------------
// test sequence
//----------------------------------------------------------------------------

integer i, k, pd, ok, polls;
reg [7:0] v, v2, st;
reg [31:0] t0, t1, t2;
longint c0, c1;
reg [95:0] bc;

initial begin
	$display("tb_tc_mccs1850: CLK_HZ=%0d, %0d clocks per delay_us(1)", CLK_HZ, D);
	wait_clks(100);                    // FPGA-configuration build (64 clocks)

	//------------------------------------------------------------
	$display("(0) FPGA-configuration image (ram_cfg 1, pot on, empty boot) and bank 2 = 0");
	check_image(2'd1, 1'b1, 96'd0, "power-up cfg1 pot1 \"\"");
	for (i = 0; i < 32; i = i + 1) begin
		rtc_read(8'h40 + i[7:0], v);
		expect8(v, 8'h00, $sformatf("bank 2 reg %h after configuration", 8'h40 + i));
	end

	//------------------------------------------------------------
	$display("(3) status $30, control $31, $32, power_int");
	rtc_read(8'h30, v); expect8(v, 8'h80, "status $30 (NEWCHIP only)");
	expect8(dbg, 8'h30, "dbg_last_reg after reading $30");
	rtc_read(8'h31, v); expect8(v, 8'h80, "control $31 (START)");
	rtc_read(8'h32, v); expect8(v, 8'h00, "reg $32");
	rtc_write(8'h32, 8'h00);           // old-chip write, accepted harmlessly
	expect8(dbg, 8'hB2, "dbg_last_reg after writing $32");
	rtc_read(8'h33, v); expect8(v, 8'h00, "reg $33");
	rtc_read(8'h60, v); expect8(v, 8'h00, "reg $60");
	expect1(pint, 1'b0, "power_int at rest");
	expect1(pint2, 1'b0, "dut2 power_int at rest");

	//------------------------------------------------------------
	$display("(1) default images per config_reset");
	for (k = 0; k < 16; k = k + 1) begin
		ram_cfg  = k[3:2];
		pot_on   = k[1];
		boot_cmd = k[0] ? 96'd0 : {"sd", 80'd0};
		do_config_reset;
		check_image(ram_cfg, pot_on, boot_cmd,
		            $sformatf("cfg%0d pot%0d %s", ram_cfg, pot_on, k[0] ? "\"\"" : "\"sd\""));
		if (k == 0)  begin expect8(got[30], 8'hB7, "cfg0 pot0 sd cksum hi (python)"); expect8(got[31], 8'hE2, "cfg0 pot0 sd cksum lo (python)"); end
		if (k == 7)  begin expect8(got[30], 8'h18, "cfg1 pot1 \"\" cksum hi (python)"); expect8(got[31], 8'h07, "cfg1 pot1 \"\" cksum lo (python)"); end
		if (k == 10) begin expect8(got[30], 8'hA6, "cfg2 pot1 sd cksum hi (python)"); expect8(got[31], 8'hD9, "cfg2 pot1 sd cksum lo (python)"); end
		if (k == 13) begin expect8(got[30], 8'h2B, "cfg3 pot0 \"\" cksum hi (python)"); expect8(got[31], 8'h4F, "cfg3 pot0 \"\" cksum lo (python)"); end
		rtc_read(8'h31, v); expect8(v, 8'h80, "control after config_reset");
	end
	ram_cfg = 2'd0; pot_on = 1'b0; boot_cmd = {"sd(1,0,0)", 24'd0};
	do_config_reset;
	check_image(2'd0, 1'b0, boot_cmd, "cfg0 pot0 \"sd(1,0,0)\"");
	boot_cmd = "abcdefghijkl";
	do_config_reset;
	check_image(2'd0, 1'b0, boot_cmd, "cfg0 pot0 12 chars");
	// config_reset held for a long time: builds once, after release
	boot_cmd = {"sd", 80'd0};
	@(posedge clk); config_reset <= 1'b1;
	wait_clks(500);
	@(posedge clk); config_reset <= 1'b0;
	wait_clks(40);
	check_image(2'd0, 1'b0, boot_cmd, "cfg0 pot0 \"sd\" long reset");

	//------------------------------------------------------------
	$display("(2) walking ones, nvram_check_or_rtc_ramtest $01005cd2, and bank 2");
	for (i = 0; i < 32; i = i + 1)
		for (k = 1; k <= 8'hFF; k = k << 1) begin
			rtc_write(i[7:0], k[7:0]);
			rtc_read(i[7:0], v);
			expect8(v, k[7:0], $sformatf("walking one reg %h", i));
		end
	for (i = 0; i < 32; i = i + 1)
		for (k = 1; k <= 8'hFF; k = k << 1) begin
			rtc_write(8'h40 + i[7:0], ~k[7:0]);
			rtc_read(8'h40 + i[7:0], v);
			expect8(v, ~k[7:0], $sformatf("walking zero reg %h", 8'h40 + i));
		end
	// distinct contents in both banks, then read everything back
	for (i = 0; i < 32; i = i + 1) begin
		rtc_write(i[7:0], 8'h5A ^ i[7:0]);
		rtc_write(8'h40 + i[7:0], 8'hC3 + i[7:0]);
	end
	expect8(dbg, 8'hDF, "dbg_last_reg after writing $5F");
	for (i = 0; i < 32; i = i + 1) begin
		rtc_read(i[7:0], v);          expect8(v, 8'h5A ^ i[7:0], $sformatf("bank 1 reg %h", i));
		rtc_read(8'h40 + i[7:0], v);  expect8(v, 8'hC3 + i[7:0], $sformatf("bank 2 reg %h", 8'h40 + i));
	end
	// the time registers are not NVRAM: a write to $A0.. must not land in RAM
	rtc_read(8'h00, v); expect8(v, 8'h5A, "reg 00 untouched by bank 2 writes");

	//------------------------------------------------------------
	$display("(4) seconds counter");
	// dut2 before any TIMESTAMP toggle counts from 1987-07-02 12:00:00
	which = 1'b1;
	rtc_read_time(t0);
	checks = checks + 1;
	if (t0 < NEXT_START_SEC || t0 > NEXT_START_SEC + 32'(cyc / CLK_HZ) + 1)
		fail($sformatf("dut2 unseeded time %0d, expected %0d + %0d s", t0, NEXT_START_SEC, cyc / CLK_HZ));
	// seed dut2 with a value >= 2038: clamped to NEXT_START_SEC
	ts2 = {1'b1, 32'hF000_0000};
	wait_clks(4);
	rtc_read_time(t0);
	checks = checks + 1;
	if (t0 !== NEXT_START_SEC && t0 !== NEXT_START_SEC + 1)
		fail($sformatf("dut2 clamp: time %h, expected %h", t0, NEXT_START_SEC));
	which = 1'b0;
	// seed dut
	ts = {1'b1, 32'h6710_0000};
	wait_clks(4);
	rtc_read_time(t0);
	checks = checks + 1;
	if (t0 !== 32'h6710_0000 && t0 !== 32'h6710_0001) fail($sformatf("seeded time %h", t0));
	// a later TIMESTAMP update is ignored (seeded once)
	ts = {1'b0, 32'h1111_1111};
	wait_clks(4);
	rtc_read_time(t1);
	checks = checks + 1;
	if (t1 - t0 > 1) fail($sformatf("time re-seeded by a second TIMESTAMP update: %h", t1));
	// exactly 3 ticks in 3*CLK_HZ clocks (same latch offset in both reads)
	c0 = cyc;
	rtc_read_time(t0);
	while (cyc < c0 + 3 * CLK_HZ) @(posedge clk);
	rtc_read_time(t1);
	expect32(t1 - t0, 32'd3, "seconds after 3*CLK_HZ clocks");
	// under a second: at most one tick
	c0 = cyc;
	rtc_read_time(t0);
	while (cyc < c0 + CLK_HZ / 2) @(posedge clk);
	rtc_read_time(t1);
	checks = checks + 1;
	if (t1 - t0 > 1) fail($sformatf("counter ran fast: %0d ticks in 0.5 s", t1 - t0));
	// white box: consecutive ticks are exactly CLK_HZ clocks apart
	t0 = dut.tcnt;
	while (dut.tcnt == t0) @(posedge clk);
	c0 = cyc; t0 = dut.tcnt;
	while (dut.tcnt == t0) @(posedge clk);
	c1 = cyc;
	expect32(32'(c1 - c0), CLK_HZ, "clocks between two ticks");
	expect32(dut.tcnt - t0, 32'd1, "one second per tick");
	// write the counter ($A0..$A3) and read it back
	rtc_write(8'h20, 8'h12); rtc_write(8'h21, 8'h34); rtc_write(8'h22, 8'h56); rtc_write(8'h23, 8'h00);
	rtc_read_time(t0);
	checks = checks + 1;
	if (t0 !== 32'h1234_5600 && t0 !== 32'h1234_5601) fail($sformatf("written time reads %h", t0));
	expect8(dbg, 8'h23, "dbg_last_reg after reading $23");
	// alarm registers $24..$27 are plain read/write
	rtc_write(8'h24, 8'hA1); rtc_write(8'h25, 8'hB2); rtc_write(8'h26, 8'hC3); rtc_write(8'h27, 8'hD4);
	rtc_read(8'h24, v); expect8(v, 8'hA1, "alarm $24");
	rtc_read(8'h25, v); expect8(v, 8'hB2, "alarm $25");
	rtc_read(8'h26, v); expect8(v, 8'hC3, "alarm $26");
	rtc_read(8'h27, v); expect8(v, 8'hD4, "alarm $27");
	// START = 0 stops the counter
	rtc_modify(8'h31, 8'h80, 8'h00);
	rtc_read(8'h31, v); expect8(v, 8'h00, "control with START cleared");
	rtc_read_time(t0);
	wait_clks(2 * CLK_HZ);
	rtc_read_time(t1);
	expect32(t1, t0, "stopped counter");
	// post_rtc_test $010052d0: rtc_start_clock, then poll $23 every 1 ms,
	// at most 1100 times; the seconds must change within about 1.1 s
	rtc_start_clock;
	c0 = cyc;                          // the ROM's poll count starts here
	rtc_read(8'h23, v);
	polls = 0;
	rtc_read(8'h23, v2);
	while (v2 == v && polls <= 12'h44C) begin
		wait_clks(MS);                 // delay_us(1000)
		polls = polls + 1;
		rtc_read(8'h23, v2);
	end
	c1 = cyc;
	checks = checks + 1;
	if (v2 == v) fail("post_rtc_test: seconds never changed (POST error $91)");
	else if (c1 - c0 > (CLK_HZ * 11) / 10)
		fail($sformatf("post_rtc_test: change took %0d clocks (> 1.1 s)", c1 - c0));
	else $display("  post_rtc_test: seconds changed after %0d polls, %0d ms", polls, (c1 - c0) / MS);
	rtc_read(8'h31, v); expect8(v, 8'h80, "control after rtc_start_clock");

	//------------------------------------------------------------
	$display("(5) reset leaves NVRAM, time, status and control alone");
	for (i = 0; i < 32; i = i + 1) rtc_write(i[7:0], 8'hE1 - i[7:0]);
	rtc_write(8'h31, 8'hB2);           // START | AR | ALRM_EN | LBE
	rtc_read(8'h31, v); expect8(v, 8'hB2, "control readback $B2");
	rtc_read_time(t0);
	c0 = cyc;
	@(posedge clk); reset <= 1'b1;
	wait_clks(20);
	@(posedge clk); reset <= 1'b0;
	// a reset in the middle of a write transaction (the machine reset also
	// clears SCR2, so CE drops afterwards)
	scr2(1'b1, 1'b0, 1'b0);
	send_addr(8'h85);
	send_addr(8'h00);                  // the data bits of a write of 0 to reg 5 ...
	@(posedge clk); reset <= 1'b1;     // ... reset hits before CE drops
	wait_clks(5);
	@(posedge clk); reset <= 1'b0; ce <= 1'b0; sclk <= 1'b0; din <= 1'b0;
	wait_clks(D);
	for (i = 0; i < 32; i = i + 1) begin
		rtc_read(i[7:0], v);
		if (i == 5) begin
			// the full 16 edges were sent before reset: the write committed
			expect8(v, 8'h00, "reg 5 written by the completed transaction");
		end
		else expect8(v, 8'hE1 - i[7:0], $sformatf("reg %h after reset", i));
	end
	rtc_read(8'h31, v); expect8(v, 8'hB2, "control after reset");
	rtc_read(8'h30, v); expect8(v, 8'h80, "status after reset");
	rtc_read_time(t1);
	checks = checks + 1;
	if (t1 - t0 != 32'((cyc - c0) / CLK_HZ) && t1 - t0 != 32'((cyc - c0) / CLK_HZ) + 1)
		fail($sformatf("time across reset: %h -> %h", t0, t1));
	// a reset part-way through the address phase aborts the transfer
	scr2(1'b1, 1'b0, 1'b0);
	for (i = 0; i < 4; i = i + 1) begin
		scr2(1'b1, 1'b0, 1'b1); scr2(1'b1, 1'b1, 1'b1); scr2(1'b1, 1'b0, 1'b1);
	end
	@(posedge clk); reset <= 1'b1;
	wait_clks(3);
	@(posedge clk); reset <= 1'b0; ce <= 1'b0; sclk <= 1'b0;
	wait_clks(D);
	rtc_read(8'h06, v); expect8(v, 8'hE1 - 8'h06, "reg 6 after an aborted transfer");
	// a reset in the same clock as the 16th falling edge: no write
	scr2(1'b1, 1'b0, 1'b0);
	send_addr(8'h87);
	for (i = 0; i < 8; i = i + 1) begin
		scr2(1'b1, 1'b0, 1'b1); scr2(1'b1, 1'b1, 1'b1);
		if (i < 7) scr2(1'b1, 1'b0, 1'b1);
	end
	@(posedge clk); sclk <= 1'b0; reset <= 1'b1;
	@(posedge clk); reset <= 1'b0; ce <= 1'b0;
	wait_clks(D);
	rtc_read(8'h07, v); expect8(v, 8'hE1 - 8'h07, "reg 7 after a reset on the last edge");
	rtc_write(8'h31, 8'h80);

	//------------------------------------------------------------
	$display("(6) power key -> PDOWN + power_int, cleared by rtc_power_int_handler");
	@(posedge clk); power_key <= 1'b1;
	@(posedge clk); power_key <= 1'b0;
	wait_clks(3);
	expect1(pint, 1'b1, "power_int after the power key");
	expect1(pint2, 1'b0, "dut2 power_int (not pressed)");
	rtc_read(8'h30, v); expect8(v, 8'h89, "status after the power key (NEWCHIP|INT|PDOWN)");
	rtc_read(8'h30, v); expect8(v, 8'h89, "status is not cleared by reading");
	@(posedge clk); reset <= 1'b1;
	wait_clks(5);
	@(posedge clk); reset <= 1'b0;
	expect1(pint, 1'b1, "power_int survives a machine reset");
	power_int_handler(pd);
	expect1(pd[0], 1'b1, "handler saw the power-down request");
	expect1(pint, 1'b0, "power_int after the handler");
	rtc_read(8'h30, v); expect8(v, 8'h80, "status after CLRPDOWN");
	rtc_read(8'h31, v); expect8(v, 8'h80, "control keeps START after CLRPDOWN");
	// held key: edge triggered, one request per press
	@(posedge clk); power_key <= 1'b1;
	wait_clks(3);
	expect1(pint, 1'b1, "power_int on a held key");
	power_int_handler(pd);
	expect1(pint, 1'b0, "cleared while the key is still held");
	wait_clks(50);
	expect1(pint, 1'b0, "no new request while held");
	@(posedge clk); power_key <= 1'b0;
	// config_reset clears a pending request
	@(posedge clk); power_key <= 1'b1;
	@(posedge clk); power_key <= 1'b0;
	wait_clks(2);
	expect1(pint, 1'b1, "power_int before config_reset");
	rtc_write(8'h31, 8'h00);           // also stop the clock
	rtc_write(8'h45, 8'h77);           // bank 2 content must survive config_reset
	rtc_read_time(t0);
	c0 = cyc;
	ram_cfg = 2'd0; pot_on = 1'b0; boot_cmd = {"sd", 80'd0};
	do_config_reset;
	expect1(pint, 1'b0, "power_int after config_reset");
	rtc_read(8'h30, v); expect8(v, 8'h80, "status after config_reset");
	rtc_read(8'h31, v); expect8(v, 8'h80, "control after config_reset (START)");
	rtc_read(8'h45, v); expect8(v, 8'h77, "bank 2 kept by config_reset");
	check_image(2'd0, 1'b0, boot_cmd, "cfg0 pot0 \"sd\" final");
	rtc_read_time(t1);
	checks = checks + 1;
	// stopped until config_reset, then running again, never re-seeded
	if (t1 < t0 || t1 > t0 + 32'((cyc - c0) / CLK_HZ) + 1)
		fail($sformatf("time across config_reset: %h -> %h", t0, t1));

	//------------------------------------------------------------
	$display("(7) burst transfers (auto-increment, Previous newrtc_interface_io)");
	scr2(1'b1, 1'b0, 1'b0);
	send_addr(8'hC0);                  // write $40, $41, $42 in one CE cycle
	send_addr(8'h11); send_addr(8'h22); send_addr(8'h33);
	scr2(1'b0, 1'b0, 1'b0);
	rtc_read(8'h40, v); expect8(v, 8'h11, "burst write $40");
	rtc_read(8'h41, v); expect8(v, 8'h22, "burst write $41");
	rtc_read(8'h42, v); expect8(v, 8'h33, "burst write $42");
	// burst read $1E, $1F (checksum), then $20: only $7F wraps (to $00)
	scr2(1'b1, 1'b0, 1'b0);
	send_addr(8'h1E);
	in_rd_data = 1'b1;
	for (k = 0; k < 3; k = k + 1) begin
		v = 8'd0;
		for (i = 0; i < 8; i = i + 1) begin
			scr2(1'b1, 1'b1, 1'b0);
			scr2(1'b1, 1'b0, 1'b0);
			v = {v[6:0], bit10};
			wait_clks(D);
		end
		if (k == 0) expect8(v, got[30], "burst read $1E");
		if (k == 1) expect8(v, got[31], "burst read $1F");
		if (k == 2) expect8(v, t1[31:24], "burst read continues $1F -> $20 (time MSB)");
	end
	scr2(1'b0, 1'b0, 1'b0);
	in_rd_data = 1'b0;

	//------------------------------------------------------------
	if (errors == 0) begin
		$display("PASS: tb_tc_mccs1850, %0d checks, %0d clocks", checks, cyc);
		$finish;
	end
	else begin
		$display("FAIL: tb_tc_mccs1850, %0d of %0d checks failed", errors, checks);
		$fatal(1, "tb_tc_mccs1850 failed");
	end
end

endmodule
