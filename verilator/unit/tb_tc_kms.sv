//============================================================================
//  tb_tc_kms -- self-checking unit test of rtl/tc_kms.sv (Verilator --timing)
//
//  Drives the device port the way the Rev 3.3 v74 ROM does on a Turbo Color
//  (rom-dissassembly/hardware-summary.md section 6): ori.b #2,$0200E002,
//  move.b cmd,$0200E003 + move.l data,$0200E004, polling $0200E001 bit 6
//  after $C5 (kms_send_cmd_wait), $C6 $01FFFFF6 before every long read of
//  $0200E000 / $0200E008 (kms_read_key), ori.b #$20 / #$10 on $0200E001
//  (kms_poll_km_event / mon_clear_nmi), TX_LOOP + $C6 $1000A825
//  (kms_send_reset).  Expected NeXT keycodes and modifier bits are taken
//  from Previous r1851 includes/kms.h and gui-sdl/sdlkeymap.c (non-ADB
//  scancode map), not from the DUT's table.
//
//  Prints "PASS: ..." or "FAIL: ..." and exits non-zero on failure.
//  Run: bash verilator/unit/run_tb_tc_kms.sh
//============================================================================
`timescale 1ns/1ps

module tb_tc_kms;

localparam [31:0] R_SND    = 32'h0200E000;   // sound status (long: KM bits 23..16)
localparam [31:0] R_KM     = 32'h0200E001;
localparam [31:0] R_TX     = 32'h0200E002;
localparam [31:0] R_CMD    = 32'h0200E003;
localparam [31:0] R_DATA   = 32'h0200E004;
localparam [31:0] R_KMDATA = 32'h0200E008;

// Previous includes/kms.h
localparam [6:0] NK_a = 7'h39, NK_1 = 7'h4A, NK_BACKQUOTE = 7'h26,
                 NK_KP_MULTIPLY = 7'h25;
localparam [6:0] MOD_LSHIFT = 7'h02, MOD_RSHIFT = 7'h04,
                 MOD_LCMD   = 7'h08,   // NEXTKEY_MOD_LCTRL (left Command)
                 MOD_RCMD   = 7'h10,   // NEXTKEY_MOD_RCTRL (right Command)
                 MOD_LALT   = 7'h20, MOD_RALT = 7'h40;

// PS/2 set 2
localparam [7:0] PS2_A = 8'h1C, PS2_1 = 8'h16, PS2_LSHIFT = 8'h12, PS2_RSHIFT = 8'h59,
                 PS2_CAPS = 8'h58, PS2_GRAVE = 8'h0E, PS2_LWIN = 8'h1F /*E0*/,
                 PS2_RWIN = 8'h27 /*E0*/, PS2_ALT = 8'h11 /*E0 = right*/,
                 PS2_KPSTAR = 8'h7C, PS2_F10 = 8'h09, PS2_F11 = 8'h78,
                 PS2_DELETE = 8'h71 /*E0*/;

logic clk = 1'b0;
always #15 clk = ~clk;                   // ~33 MHz

logic        reset = 1'b1;
logic        stb = 1'b0, we = 1'b0;
logic  [3:2] addr = 2'd0;
logic  [3:0] be = 4'd0;
logic [31:0] wdata = 32'd0;
wire  [31:0] rdata;
wire         ack;
logic [10:0] ps2_key = 11'd0;
logic [24:0] ps2_mouse = 25'd0;
wire         int_keymouse, nmi, power_key, reset_req;
wire   [7:0] dbg_cmd;

tc_kms #(.CLK_HZ(33000000)) dut (.*);

int errors = 0, checks = 0;
int power_cycles = 0, reset_cycles = 0;
always @(posedge clk) begin
	if (power_key) power_cycles++;
	if (reset_req) reset_cycles++;
end

task automatic check(input bit cond, input string msg);
	checks++;
	if (!cond) begin
		errors++;
		$display("FAIL: %s", msg);
	end
endtask

//----------------------------------------------------------------------------
// bus
//----------------------------------------------------------------------------

task automatic bus(input bit w, input [31:0] a, input [3:0] b, input [31:0] d,
                   output logic [31:0] q);
	int n;
	@(negedge clk);
	stb = 1'b1; we = w; addr = a[3:2]; be = b; wdata = d;
	@(negedge clk);
	stb = 1'b0; we = 1'b0; be = 4'd0; wdata = 32'd0;
	n = 0;
	while (!ack && n < 8) begin
		@(negedge clk);
		n++;
	end
	check(ack, $sformatf("ack for %s at %08x", w ? "write" : "read", a));
	q = rdata;
	@(negedge clk);
	check(!ack, "ack is a 1-cycle pulse");
endtask

function automatic [3:0] lane(input [1:0] a);
	lane = 4'b1000 >> a;
endfunction

task automatic wr8(input [31:0] a, input [7:0] v);
	logic [31:0] q;
	bus(1'b1, a, lane(a[1:0]), {24'd0, v} << (8 * (3 - int'(a[1:0]))), q);
endtask

task automatic rd8(input [31:0] a, output logic [7:0] v);
	logic [31:0] q;
	bus(1'b0, a, lane(a[1:0]), 32'd0, q);
	v = 8'(q >> (8 * (3 - int'(a[1:0]))));
endtask

task automatic wr32(input [31:0] a, input [31:0] v);
	logic [31:0] q;
	bus(1'b1, a, 4'hF, v, q);
endtask

task automatic rd32(input [31:0] a, output logic [31:0] v);
	bus(1'b0, a, 4'hF, 32'd0, v);
endtask

task automatic ori8(input [31:0] a, input [7:0] m);   // ori.b #m,(a)
	logic [7:0] v;
	rd8(a, v);
	wr8(a, v | m);
endtask

//----------------------------------------------------------------------------
// ROM primitives
//----------------------------------------------------------------------------

bit kms_enabled_once = 1'b0;             // mg+$170 bit 7

task automatic rom_send_cmd(input [7:0] c, input [31:0] d);   // $0100a520
	if (!kms_enabled_once) begin
		ori8(R_TX, 8'h02);
		kms_enabled_once = 1'b1;
	end
	wr8(R_CMD, c);
	wr32(R_DATA, d);
	repeat (8) @(negedge clk);           // delay_us(100), shortened
endtask

task automatic rom_send_cmd_wait(input [7:0] c, input [31:0] d, output bit timeout);
	logic [7:0] v;
	int n;                                // $0100a4da (100000 polls in the ROM)
	rom_send_cmd(c, d);
	timeout = 1'b1;
	for (n = 0; n < 1000; n++) begin
		rd8(R_KM, v);
		if (v[6]) begin
			timeout = 1'b0;
			break;
		end
	end
endtask

task automatic rom_read_key(output bit got, output logic [31:0] ev);   // $0100a2ba
	logic [31:0] s;
	rom_send_cmd(8'hC6, 32'h01FFFFF6);
	rd32(R_SND, s);
	got = s[22];
	ev = 32'd0;
	if (got) rd32(R_KMDATA, ev);
endtask

function automatic [31:0] kev(input [6:0] m, input bit up, input [6:0] kc);
	kev = {8'h10, 8'h00, 1'b1, m, up, kc};
endfunction

task automatic expect_ev(input [31:0] exp, input string what);
	bit got;
	logic [31:0] ev;
	rom_read_key(got, ev);
	check(got && ev == exp,
	      $sformatf("%s: got=%0d event=%08x expected %08x", what, got, ev, exp));
endtask

task automatic expect_none(input string what);
	bit got;
	logic [31:0] ev;
	rom_read_key(got, ev);
	check(!got, $sformatf("%s: unexpected event %08x", what, ev));
endtask

//----------------------------------------------------------------------------
// host inputs
//----------------------------------------------------------------------------

task automatic key(input bit ext, input [7:0] code, input bit make);
	@(negedge clk);
	ps2_key = {~ps2_key[10], make, ext, code};
	repeat (4) @(negedge clk);
endtask

task automatic mouse_pkt(input [7:0] st, input [7:0] dx, input [7:0] dy);
	@(negedge clk);
	ps2_mouse = {~ps2_mouse[24], dy, dx, st};
	repeat (4) @(negedge clk);
endtask

// {ext, set-2 code, NeXT keycode from Previous kms.h / sdlkeymap.c}
logic [15:0] keymap_spot [0:15] = '{
	{1'b0, 8'h1A, 7'h31},   // z          NEXTKEY_z
	{1'b0, 8'h3A, 7'h36},   // m          NEXTKEY_m
	{1'b0, 8'h2E, 7'h50},   // 5          NEXTKEY_5
	{1'b0, 8'h5A, 7'h2A},   // Return     NEXTKEY_RETURN
	{1'b0, 8'h66, 7'h1B},   // Backspace  NEXTKEY_DELETE
	{1'b0, 8'h76, 7'h49},   // Esc        NEXTKEY_ESC
	{1'b0, 8'h29, 7'h38},   // Space      NEXTKEY_SPACE
	{1'b0, 8'h54, 7'h05},   // [          NEXTKEY_OPENBRACKET
	{1'b0, 8'h5D, 7'h03},   // backslash  NEXTKEY_BACKSLASH
	{1'b0, 8'h0E, 7'h26},   // `          NEXTKEY_BACKQUOTE
	{1'b0, 8'h7C, 7'h25},   // keypad *   NEXTKEY_KEYPAD_MULTIPLY
	{1'b0, 8'h05, 7'h01},   // F1         NEXTKEY_BRGHTNESS_DOWN
	{1'b0, 8'h0B, 7'h1A},   // F6         NEXTKEY_VOLUME_UP
	{1'b1, 8'h6B, 7'h09},   // Left       NEXTKEY_LEFT_ARROW
	{1'b1, 8'h75, 7'h16},   // Up         NEXTKEY_UP_ARROW
	{1'b1, 8'h5A, 7'h0D}    // KP Enter   NEXTKEY_KEYPAD_ENTER
};

//----------------------------------------------------------------------------
// test
//----------------------------------------------------------------------------

initial begin : watchdog
	#20ms;
	$display("FAIL: tb_tc_kms timed out");
	$fatal(1, "timeout");
end

initial begin : test
	logic [31:0] q;
	logic  [7:0] b;
	bit          to;
	int          pc, rc, i;

	repeat (4) @(negedge clk);
	reset = 1'b0;
	repeat (2) @(negedge clk);

	// --- reset state -------------------------------------------------------
	rd32(R_SND, q);    check(q == 32'd0, $sformatf("reset: $0200E000 = %08x", q));
	rd32(R_KMDATA, q); check(q == 32'd0, "reset: $0200E008 = 0");
	check(!nmi && !int_keymouse && !reset_req && !power_key, "reset: outputs idle");

	// --- KMS_ENABLE clear: commands are ignored (kms_command_in) ----------
	wr8(R_CMD, 8'hC5);
	wr32(R_DATA, 32'hEF000000);
	repeat (4) @(negedge clk);
	rd8(R_KM, b);      check(!b[6], "no KMREG answer while KMS_ENABLE is clear");
	check(dbg_cmd == 8'hC5, "dbg_cmd = last command written");

	// --- kms_console_init ($010098a4), POT path ----------------------------
	rom_send_cmd_wait(8'hC5, 32'hEF000000, to);
	check(!to, "$C5 $EF000000: kms_send_cmd_wait sees KM_RECEIVED");
	rd8(R_TX, b);      check(b == 8'h02, $sformatf("$0200E002 = %02x after ori.b #2", b));
	rom_send_cmd_wait(8'hC5, 32'h00030000, to);
	check(!to, "$C5 $30000 answered");
	rom_send_cmd_wait(8'hC5, 32'h00000000, to);
	check(!to, "$C5 0 answered");
	rom_send_cmd(8'hC6, 32'h01FFFFF6);
	// the first kms_read_key gets the last KMREG answer: no response +
	// invalid set (so no re-init), valid bit clear (so translated to $100)
	expect_ev(32'h70000000, "KMREG answer = km_no_response word");
	rd32(R_SND, q);    check(q[21] && !q[22], "overrun left by the unread KMREG answers");
	ori8(R_KM, 8'h20);                    // kms_poll_km_event
	// {sound 0, KM 0, TX = KMS_ENABLE, byte 3 = $C6 (last KMS->CPU message)}
	rd32(R_SND, q);    check(q == 32'h0000_02C6, $sformatf("after ori.b #$20: %08x", q));
	expect_none("idle keyboard");

	// --- key events ----------------------------------------------------------
	key(0, PS2_A, 1);
	check(int_keymouse, "INT_KEYMOUSE while a key event is pending");
	rd8(R_CMD, b);     check(b == 8'hC6, "status byte 3 = $C6 after a KM message");
	expect_ev(kev(0, 0, NK_a), "'a' make");
	check(!int_keymouse, "reading $0200E008 releases INT_KEYMOUSE");
	key(0, PS2_A, 0);
	expect_ev(kev(0, 1, NK_a), "'a' break");

	key(0, PS2_LSHIFT, 1); expect_ev(kev(MOD_LSHIFT, 0, 7'h00), "L-shift make");
	key(0, PS2_1, 1);      expect_ev(kev(MOD_LSHIFT, 0, NK_1), "shift-1 make");
	key(0, PS2_1, 0);      expect_ev(kev(MOD_LSHIFT, 1, NK_1), "shift-1 break");
	key(0, PS2_LSHIFT, 0); expect_ev(kev(0, 1, 7'h00), "L-shift break");
	key(0, PS2_RSHIFT, 1); expect_ev(kev(MOD_RSHIFT, 0, 7'h00), "R-shift make");
	key(0, PS2_A, 1);      expect_ev(kev(MOD_RSHIFT, 0, NK_a), "R-shift-a make");
	key(0, PS2_A, 0);      expect_ev(kev(MOD_RSHIFT, 1, NK_a), "R-shift-a break");
	key(0, PS2_RSHIFT, 0); expect_ev(kev(0, 1, 7'h00), "R-shift break");
	// Caps Lock is sent as L-shift (Previous Keymap_GetModifiers KMOD_CAPS)
	key(0, PS2_CAPS, 1);   expect_ev(kev(MOD_LSHIFT, 0, 7'h00), "caps lock on");
	key(0, PS2_CAPS, 0);   expect_ev(kev(MOD_LSHIFT, 1, 7'h00), "caps lock key up");
	key(0, PS2_A, 1);      expect_ev(kev(MOD_LSHIFT, 0, NK_a), "caps-a");
	key(0, PS2_A, 0);      expect_ev(kev(MOD_LSHIFT, 1, NK_a), "caps-a break");
	key(0, PS2_CAPS, 1);   expect_ev(kev(0, 0, 7'h00), "caps lock off");
	key(0, PS2_CAPS, 0);   expect_ev(kev(0, 1, 7'h00), "caps lock key up");

	for (i = 0; i < 16; i++) begin
		key(keymap_spot[i][15], keymap_spot[i][14:7], 1);
		expect_ev(kev(0, 0, keymap_spot[i][6:0]),
		          $sformatf("keymap %s%02x make", keymap_spot[i][15] ? "E0 " : "", keymap_spot[i][14:7]));
		key(keymap_spot[i][15], keymap_spot[i][14:7], 0);
		expect_ev(kev(0, 1, keymap_spot[i][6:0]),
		          $sformatf("keymap %s%02x break", keymap_spot[i][15] ? "E0 " : "", keymap_spot[i][14:7]));
	end

	// --- mouse (device address 1) --------------------------------------------
	// right 5, up 3, left button down: x = (0x40-5)|0x40, y = 3 (kms_mouse_move)
	mouse_pkt(8'h09, 8'd5, 8'd3);
	expect_ev(32'h010007F6, "mouse right 5 / up 3 / left down");
	// left 2, down 4, no buttons
	mouse_pkt(8'h38, 8'hFE, 8'hFC);
	expect_ev(32'h0100F905, "mouse left 2 / down 4 / buttons up");
	// a packet waits behind an unread keyboard event
	key(0, PS2_A, 1);
	mouse_pkt(8'h08, 8'd1, 8'd0);
	rd32(R_SND, q);    check(q[22] && !q[21], "mouse packet did not overrun the key event");
	rd32(R_KMDATA, q); check(q == kev(0, 0, NK_a), $sformatf("pending key kept: %08x", q));
	repeat (4) @(negedge clk);
	rd32(R_SND, q);    check(q[22], "mouse packet posted after the key was read");
	rd32(R_KMDATA, q); check(q == 32'h010001FF, $sformatf("deferred mouse event %08x", q));
	key(0, PS2_A, 0);      expect_ev(kev(0, 1, NK_a), "'a' break after mouse");

	// --- NMI: Command-Command-` (KMS_MAGIC_NMI_LR) ----------------------------
	key(1, PS2_LWIN, 1);   expect_ev(kev(MOD_LCMD, 0, 7'h00), "L-Win = L-Command");
	key(1, PS2_RWIN, 1);   expect_ev(kev(MOD_LCMD | MOD_RCMD, 0, 7'h00), "R-Win = R-Command");
	check(!nmi, "no NMI yet");
	key(0, PS2_GRAVE, 1);
	check(nmi, "Cmd-Cmd-` drives nmi");
	rd8(R_KM, b);      check(b[4], "NMI_RECEIVED set");
	expect_none("the magic key-down is not delivered");
	ori8(R_KM, 8'h10);                    // mon_clear_nmi
	check(!nmi, "ori.b #$10,$0200E001 clears nmi");
	rd8(R_KM, b);      check(!b[4], "NMI_RECEIVED cleared");
	key(0, PS2_GRAVE, 0);
	expect_ev(kev(MOD_LCMD | MOD_RCMD, 1, NK_BACKQUOTE), "` break is delivered");
	key(1, PS2_RWIN, 0);   expect_ev(kev(MOD_LCMD, 1, 7'h00), "R-Win break");
	// L-Command alone (KMS_MAGIC_NMI_L)
	key(0, PS2_GRAVE, 1);  check(nmi, "L-Cmd-` drives nmi");
	ori8(R_KM, 8'h10);     check(!nmi, "cleared");
	key(0, PS2_GRAVE, 0);  expect_ev(kev(MOD_LCMD, 1, NK_BACKQUOTE), "` break");
	key(1, PS2_LWIN, 0);   expect_ev(kev(0, 1, 7'h00), "L-Win break");
	// R-Command alone (KMS_MAGIC_NMI_R)
	key(1, PS2_RWIN, 1);   expect_ev(kev(MOD_RCMD, 0, 7'h00), "R-Win make");
	key(0, PS2_GRAVE, 1);  check(nmi, "R-Cmd-` drives nmi");
	ori8(R_KM, 8'h10);     check(!nmi, "cleared");
	key(0, PS2_GRAVE, 0);  expect_ev(kev(MOD_RCMD, 1, NK_BACKQUOTE), "` break");
	key(1, PS2_RWIN, 0);   expect_ev(kev(0, 1, 7'h00), "R-Win break");
	// another modifier held: ordinary typing, no NMI
	key(1, PS2_ALT, 1);    expect_ev(kev(MOD_RALT, 0, 7'h00), "R-Alt make");
	key(0, PS2_GRAVE, 1);  check(!nmi, "R-Alt-` is not an NMI");
	expect_ev(kev(MOD_RALT, 0, NK_BACKQUOTE), "R-Alt-` delivered");
	key(0, PS2_GRAVE, 0);  expect_ev(kev(MOD_RALT, 1, NK_BACKQUOTE), "R-Alt-` break");
	key(1, PS2_ALT, 0);    expect_ev(kev(0, 1, 7'h00), "R-Alt break");
	// F11: one-key NMI, never delivered
	key(0, PS2_F11, 1);    check(nmi, "F11 drives nmi");
	expect_none("F11 make not delivered");
	ori8(R_KM, 8'h10);     check(!nmi, "cleared");
	key(0, PS2_F11, 0);    expect_none("F11 break not delivered");
	// the ROM's read-modify-write with a KM event pending
	key(0, PS2_A, 1);
	key(0, PS2_F11, 1);
	rd8(R_KM, b);      check(b == 8'hD0, $sformatf("KM status %02x (INT|RECEIVED|NMI)", b));
	ori8(R_KM, 8'h10);
	rd8(R_KM, b);      check(b == 8'hC0 && !nmi, $sformatf("ori.b #$10 leaves %02x", b));
	expect_ev(kev(0, 0, NK_a), "key event survives the NMI clear");
	key(0, PS2_F11, 0);
	key(0, PS2_A, 0);      expect_ev(kev(0, 1, NK_a), "'a' break");

	// --- power key --------------------------------------------------------
	pc = power_cycles;
	key(0, PS2_F10, 1);
	check(power_cycles == pc + 1, "F10 make: one 1-cycle power_key pulse");
	check(!int_keymouse && !nmi, "F10 raises no interrupt");
	expect_none("F10 is not a KM event");
	key(0, PS2_F10, 0);
	check(power_cycles == pc + 1, "F10 break: no pulse");
	expect_none("F10 break is not a KM event");
	key(1, PS2_DELETE, 1); expect_none("Delete is unassigned");
	key(1, PS2_DELETE, 0); expect_none("Delete break");
	check(power_cycles == pc + 1, "Delete is not a power key");

	// --- KMREG reads: Turbo revision, user poll ------------------------------
	rom_send_cmd_wait(8'hC5, 32'hF0000000, to);
	rd32(R_KMDATA, q); check(!to && q == 32'h20010101, $sformatf("keyboard version %08x (REV_NEW)", q));
	rom_send_cmd_wait(8'hC5, 32'hF1000000, to);
	rd32(R_KMDATA, q); check(!to && q == 32'h20010102, $sformatf("mouse version %08x", q));
	rom_send_cmd_wait(8'hC5, 32'h10000000, to);
	rd32(R_SND, q);    check(!to && q[21], "user poll: answer then no-response -> overrun");
	rd32(R_KMDATA, q); check(q == 32'h70000000, $sformatf("user poll leaves %08x", q));
	ori8(R_KM, 8'h20);
	// set address on the Turbo: the keyboard stays at address 0
	rom_send_cmd_wait(8'hC5, 32'hEF060000, to);
	rd32(R_KMDATA, q); check(!to && q == 32'h70000000, "set address answered");
	key(0, PS2_A, 1);      expect_ev(kev(0, 0, NK_a), "keyboard still at address 0");
	key(0, PS2_A, 0);      expect_ev(kev(0, 1, NK_a), "'a' break");

	// --- the command runs on the write of byte $0200E007 ----------------------
	wr8(R_CMD, 8'hC5);
	bus(1'b1, R_DATA, 4'b1100, 32'hEF00_0000, q);   // $0200E004.w
	repeat (4) @(negedge clk);
	rd8(R_KM, b);      check(!b[6], "word write of $0200E004 does not execute");
	bus(1'b1, R_DATA, 4'b0011, 32'h0000_0000, q);   // $0200E006.w
	repeat (4) @(negedge clk);
	rd8(R_KM, b);      check(b[6], "word write of $0200E006 executes");
	rd32(R_DATA, q);   check(q == 32'hEF000000, $sformatf("$0200E004 reads %08x", q));
	rd32(R_KMDATA, q); check(q == 32'h70000000, "merged $C5 $EF000000 answered");

	// --- sound: status 0, commands accepted and ignored ----------------------
	wr8(R_SND, 8'h80);
	rd8(R_SND, b);     check(b == 8'h00, "sound status byte reads 0");
	rom_send_cmd(8'h07, 32'd0);          // sound out off
	rom_send_cmd(8'h0F, 32'd0);          // sound out on
	rom_send_cmd(8'h3F, 32'd0);          // on, double sample, zero fill
	rom_send_cmd(8'h0B, 32'd0);          // sound in on
	rom_send_cmd(8'h03, 32'd0);          // sound in off
	rom_send_cmd(8'hC4, 32'h0E000000);   // CTRLOUT (kms_set_volume)
	rom_send_cmd(8'hC2, 32'h40000000);   // VOLCTRL
	rom_send_cmd(8'hC7, 32'h12345678);   // analog sound out
	rd32(R_SND, q);    check(q == 32'h0000_02C6,
	                         $sformatf("sound status 0, no KM message: %08x", q));
	expect_none("after sound commands");

	// --- KMS_ENABLE 1->0 resets the KMS; disabled KMS drops events ----------
	key(0, PS2_A, 1);                    // pending event
	wr8(R_TX, 8'h00);
	rd32(R_SND, q);    check(q == 32'd0, $sformatf("KMS_ENABLE 1->0 resets: %08x", q));
	key(0, PS2_A, 0);
	expect_none("KMS disabled: key dropped, $C6 ignored");
	ori8(R_TX, 8'h02);
	key(0, PS2_A, 1);      expect_ev(kev(0, 0, NK_a), "re-enabled");
	key(0, PS2_A, 0);      expect_ev(kev(0, 1, NK_a), "'a' break");
	// $FF $FFFFFFFF: KMS reset, clears KMS_ENABLE as well
	key(0, PS2_A, 1);
	rom_send_cmd(8'hFF, 32'hFFFFFFFF);
	rd32(R_SND, q);    check(q == 32'd0, $sformatf("$FF reset: %08x", q));
	key(0, PS2_A, 0);
	ori8(R_TX, 8'h02);
	expect_none("event before the reset is gone");

	// --- keyboard magic reset: L-Cmd + L-Alt + keypad * ----------------------
	rc = reset_cycles;
	key(1, PS2_LWIN, 1);   expect_ev(kev(MOD_LCMD, 0, 7'h00), "L-Win make");
	key(0, PS2_ALT, 1);    expect_ev(kev(MOD_LCMD | MOD_LALT, 0, 7'h00), "L-Alt make");
	key(0, PS2_KPSTAR, 1);
	check(reset_cycles == rc + 1, "Cmd-Alt-keypad* pulses reset_req once");
	key(0, PS2_KPSTAR, 0); expect_ev(kev(MOD_LCMD | MOD_LALT, 1, NK_KP_MULTIPLY), "keypad * break");
	key(0, PS2_ALT, 0);    expect_ev(kev(MOD_LCMD, 1, 7'h00), "L-Alt break");
	key(1, PS2_LWIN, 0);   expect_ev(kev(0, 1, 7'h00), "L-Win break");

	// --- kms_send_reset ($01009860) ---------------------------------------------
	rom_send_cmd(8'hC6, 32'h1000A825);   // without TX_LOOP: just a poll mask
	check(reset_cycles == rc + 1, "$C6 $1000A825 without TX_LOOP does not reset");
	rd8(R_TX, b);                         // move.b / ori.b #1 / move.b
	wr8(R_TX, b | 8'h01);
	rom_send_cmd(8'hC6, 32'h1000A825);
	check(reset_cycles == rc + 2, "kms_send_reset: $C6 $1000A825 pulses reset_req once");
	rom_send_cmd(8'hC6, 32'h00000000);
	rd32(R_SND, q);    check(q[22], "looped-back $C6 0 arrives as KM data");
	rd32(R_KMDATA, q); check(q == 32'd0, "looped-back data");

	// --- machine reset --------------------------------------------------------
	@(negedge clk); reset = 1'b1;
	repeat (2) @(negedge clk); reset = 1'b0;
	rd32(R_SND, q);    check(q == 32'd0, "machine reset clears the KMS");
	check(dbg_cmd == 8'h00, "machine reset clears the command");

	if (errors == 0)
		$display("PASS: tb_tc_kms (%0d checks)", checks);
	else
		$display("FAIL: tb_tc_kms (%0d of %0d checks failed)", errors, checks);
	if (errors != 0) $fatal(1, "tb_tc_kms failed");
	$finish;
end

endmodule
