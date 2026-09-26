//============================================================================
//  tc_kms -- KMS (keyboard / mouse / sound) interface of the NeXT monitor /
//  soundbox, CPU registers $0200E000..$0200E00F, for the NeXTstation Turbo
//  Color.  Keyboard, mouse, command channel and the power key; the sound
//  side is only a register stub for now (see "SOUND HOOK" below).
//
//  Derived from the mono core's module NeXT_MiSTer rtl/next/next_kms_snd.sv
//  (works on hardware).  Kept from it unchanged: the PS/2 set-2 -> NeXT
//  keycode table (Previous's non-ADB scancode map, Delete deliberately
//  unassigned), the modifier / Control / Caps Lock tracking, the mouse
//  packet packing (kms_mouse_move encoding) and the "a write of data byte
//  $0200E007 executes the command" rule.
//  Removed: the non-Turbo sound-out DMA channel (CSR $02000040, pointers
//  $02004030..$0200404C, init $02004240) with its m_* RAM master port, the
//  audio FIFO / 44.1 kHz tick and the next_sound_output submodule, the
//  sound-in control sharing, the volume/GPO state and the int_power output.
//  On the Turbo the sound DMA is a different engine that lives elsewhere.
//  Changed:
//  - 32-bit device port, big-endian byte enables (machine contract).
//  - Turbo KMS revision (Previous kms.c: kms.rev = bTurbo ? REV_NEW : ...):
//    the keyboard/mouse address is fixed at 0 (km_set_addr), a version read
//    reports revision 1 (km_version), $C2 VOLCTRL is a sound command.
//  - Previous semantics where the mono core had simplified them:
//    KMS_ENABLE ($0200E002 bit 1) gates every command and every KM message,
//    and a 1->0 write resets the KMS (KMS_Ctrl_TX_Write); with TX_LOOP set
//    the data write is looped back as a KMS->CPU message (kms_command_out),
//    which is how the ROM's kms_send_reset produces KMS_MAGIC_RESET; every
//    KM message goes through the magic-key compare (kms_km_receive); KMREG
//    answers with the no-response word $70000000 (km_no_response) or the
//    version word; all write-one-to-clear groups of one $0200E001 write take
//    effect; the written command ($0200E003 write) is separate from the
//    status byte 3 read, so a KM event can no longer replace the command
//    between the ROM's cmd and data writes.
//  - F10 is the NeXT power key: a pulse to the RTC chip (Previous
//    kms_keydown -> rtc_request_power_down), no interrupt of its own.
//  - A mouse packet waits while an unread keyboard event is pending, so
//    mouse traffic cannot overwrite a keystroke.
//
//  Sources: Previous r1851 kms.c / kms.h / gui-sdl/sdlkeymap.c,
//  rom-dissassembly/hardware-summary.md section 6 ("HS 6") and the ROM
//  listing (kms_console_init $010098a4, kms_send_cmd $0100a520,
//  kms_send_cmd_wait $0100a4da, kms_read_key $0100a2ba, kms_send_reset
//  $01009860, mon_clear_nmi $01009fde).
//
//  Registers (addr = longword index; byte lanes big-endian):
//   $0200E000 (addr 0)
//     byte 0 $E000 sound status/control   reads 0; writes ignored (SOUND HOOK)
//     byte 1 $E001 KM status/control       bit 7 KM_INT, 6 KM_RECEIVED,
//              5 KM_OVERRUN, 4 NMI_RECEIVED, 3 KMS_INT, 2 KMS_RECEIVED,
//              1 KMS_OVERRUN.  Write 1 to bit 5 clears 7/6/5, to bit 4
//              clears 4, to bit 1 clears 3/2/1 (KMS_Ctrl_KM_Write).  In the
//              long read these are bits 23..16 (bit 22 = KM data received,
//              bit 21 = KM overrun, as the ROM tests them).
//     byte 2 $E002 TX status/control       bit 1 KMS_ENABLE, bit 0 TX_LOOP
//              (r/w); TX_DMA / TX_CPU busy read 0.
//     byte 3 $E003 command                 write: command for the next data
//              write; read: command code of the last KMS->CPU message
//              ($C6 after a KM message, 0 after reset).
//   $0200E004 (addr 1) command data long, r/w; a write that includes byte
//              $E007 (be[0]) runs the command with the merged long.
//   $0200E008 (addr 2) KM data long, read only; a read clears KM_RECEIVED
//              and KM_INT (KMS_KM_Data_Read).
//   $0200E00C (addr 3) reads 0, writes ignored.
//
//  KM data long (kms.c; HS 6): byte 0 bit 6 no response, bit 5 user poll,
//  bit 4 master (internal keyboard event), bits 3:0 device address
//  (0 keyboard, 1 mouse); keyboard: byte 2 bit 7 valid, bits 6:0 modifiers
//  (0 Control, 1 L-shift, 2 R-shift, 3 L-cmd, 4 R-cmd, 5 L-alt, 6 R-alt),
//  byte 3 bit 7 key up, bits 6:0 NeXT keycode; mouse: bits 15:9 y,
//  bit 8 right up, bits 7:1 x, bit 0 left up.
//
//  Commands (CPU -> KMS, KMS_ENABLE set, TX_LOOP clear; kms_command_in):
//   $FF data $FFFFFFFF  KMS reset (status, poll mask, data; KMS_ENABLE too)
//   $C6 KMPOLL          poll mask: six device nibbles [31:8], speed [3:0]
//   $C5 KMREG           keyboard/mouse register access, data byte 0 = op:
//                       $EF set address (Turbo: stays 0), $0F reset (clears
//                       the poll mask), $F0|dev version read -> $20010101
//                       (kbd) / $20010102 (mouse), $10|dev user poll ->
//                       no-response with overrun, anything else (e.g. the
//                       ROM's $00 = keyboard LED write, data $30000 / 0) ->
//                       no-response $70000000.  All set KM_RECEIVED.
//   $C7 $C4 $C2 and ($xx & $C7) == $07 / $03: sound, accepted and ignored.
//  With TX_LOOP set (kms_command_out): $C6 = the data is received as a KM
//  message (magic compare included); other codes are sound, ignored.
//
//  Magic keys (kms_km_receive, compared on (message & $7000FFFF)):
//   $1000A825  L-cmd + L-alt + keypad *   -> reset_req (whole machine)
//   $10008826 / $10009026 / $10009826     -> NMI: sets NMI_RECEIVED, which
//              backquote + L-cmd / R-cmd / both cmds drives `nmi`; the
//              event itself is not delivered.
//  PC keyboard: Win keys are the Command keys, so Left Win and/or Right Win
//  + ` (or Num Lock, which the table also maps to backquote) enters the
//  monitor, with no other modifier held and Caps Lock off (Caps Lock is sent
//  as L-shift, exactly as Previous does).  One-handed alternative: F11
//  alone, which is unassigned in the keycode table and never reaches
//  NeXTSTEP; it is sent as Command-Command-` and so follows the same rules
//  (KMS enabled, keyboard in the poll mask).  The ROM's mon_clear_nmi clears
//  it with ori.b #$10,$0200E001.  L-Win + L-Alt + keypad * is
//  KMS_MAGIC_RESET and resets the machine, as in Previous.
//
//  Device port contract (tc_machine): stb is a 1-cycle strobe, ack a 1-cycle
//  pulse one clock later with rdata; be[3] = byte at longword+0.
//============================================================================

module tc_kms #(
	/* verilator lint_off UNUSEDPARAM */
	parameter CLK_HZ = 33000000       // SOUND HOOK: for the 44.1 kHz engine
	/* verilator lint_on UNUSEDPARAM */
)(
	input             clk,          // clk_sys 33 MHz
	input             reset,        // synchronous, active high
	// device port: registers at $0200E000 + {addr, 2'b00}
	input             stb,
	input             we,
	input       [3:2] addr,
	input       [3:0] be,           // big-endian: be[3] = data[31:24] = longword+0
	input      [31:0] wdata,
	output reg [31:0] rdata,
	output reg        ack,
	// from hps_io
	input      [10:0] ps2_key,      // [10] toggle, [9] pressed, [8] extended, [7:0] set-2 code
	input      [24:0] ps2_mouse,    // [24] toggle, [23:16] dy, [15:8] dx, [7:0] status
	// outputs
	output            int_keymouse, // -> interrupt status bit 3 (INT_KEYMOUSE)
	output            nmi,          // -> interrupt status bit 31 (INT_NMI)
	output            power_key,    // 1-cycle pulse on a power key press -> RTC
	output            reset_req,    // 1-cycle pulse: KMS_MAGIC_RESET -> machine reset
	output      [7:0] dbg_cmd       // last command byte written
);

// $0200E001 bits
localparam [7:0] KM_INT       = 8'h80, KM_RECEIVED  = 8'h40, KM_OVERRUN  = 8'h20,
                 NMI_RECEIVED = 8'h10, KMS_INT      = 8'h08, KMS_RECEIVED = 8'h04,
                 KMS_OVERRUN  = 8'h02;
// commands CPU -> KMS (kms_command_in) and KMS -> CPU (kms_command_out)
localparam [7:0] KMSCMD_RESET   = 8'hFF, KMSCMD_KMPOLL  = 8'hC6,
                 KMSCMD_KMREG   = 8'hC5, KMSCMD_KM_RECV = 8'hC6;
localparam [31:0] KMS_MAGIC_MASK   = 32'h7000FFFF,
                  KMS_MAGIC_RESET  = 32'h1000A825,
                  KMS_MAGIC_NMI_L  = 32'h10008826,
                  KMS_MAGIC_NMI_R  = 32'h10009026,
                  KMS_MAGIC_NMI_LR = 32'h10009826,
                  KM_NO_RESPONSE   = 32'h70000000;  // user poll | no response | invalid
localparam [7:0] KMS_REV        = 8'h01;          // REV_NEW (Turbo)
localparam [6:0] NEXTKEY_POWER  = 7'h58;
localparam [7:0] PS2_F11        = 8'h78;

//----------------------------------------------------------------------------
// PS/2 set-2 to NeXT keycode translation (Keymap_GetKeyFromScancode in
// Previous src/gui-sdl/sdlkeymap.c, non-ADB scancode map) -- the mono core's
// table, unchanged.  Deliberate exception: only F10 requests power; forward
// Delete is ignored.
//----------------------------------------------------------------------------

function automatic [6:0] next_key;
	input       ext;
	input [7:0] c;
	begin
		next_key = 7'h00;
		if (!ext) case (c)
			8'h76: next_key = 7'h49;   // escape
			8'h16: next_key = 7'h4a;   // 1
			8'h1E: next_key = 7'h4b;   // 2
			8'h26: next_key = 7'h4c;   // 3
			8'h25: next_key = 7'h4d;   // 4
			8'h2E: next_key = 7'h50;   // 5
			8'h36: next_key = 7'h4f;   // 6
			8'h3D: next_key = 7'h4e;   // 7
			8'h3E: next_key = 7'h1e;   // 8
			8'h46: next_key = 7'h1f;   // 9
			8'h45: next_key = 7'h20;   // 0
			8'h4E: next_key = 7'h1d;   // minus
			8'h55: next_key = 7'h1c;   // equals
			8'h66: next_key = 7'h1b;   // backspace
			8'h0D: next_key = 7'h41;   // tab
			8'h15: next_key = 7'h42;   // q
			8'h1D: next_key = 7'h43;   // w
			8'h24: next_key = 7'h44;   // e
			8'h2D: next_key = 7'h45;   // r
			8'h2C: next_key = 7'h48;   // t
			8'h35: next_key = 7'h47;   // y
			8'h3C: next_key = 7'h46;   // u
			8'h43: next_key = 7'h06;   // i
			8'h44: next_key = 7'h07;   // o
			8'h4D: next_key = 7'h08;   // p
			8'h54: next_key = 7'h05;   // left bracket
			8'h5B: next_key = 7'h04;   // right bracket
			8'h5D: next_key = 7'h03;   // backslash
			8'h61: next_key = 7'h03;   // ISO extra backslash
			8'h1C: next_key = 7'h39;   // a
			8'h1B: next_key = 7'h3a;   // s
			8'h23: next_key = 7'h3b;   // d
			8'h2B: next_key = 7'h3c;   // f
			8'h34: next_key = 7'h3d;   // g
			8'h33: next_key = 7'h40;   // h
			8'h3B: next_key = 7'h3f;   // j
			8'h42: next_key = 7'h3e;   // k
			8'h4B: next_key = 7'h2d;   // l
			8'h4C: next_key = 7'h2c;   // semicolon
			8'h52: next_key = 7'h2b;   // apostrophe
			8'h5A: next_key = 7'h2a;   // return
			8'h1A: next_key = 7'h31;   // z
			8'h22: next_key = 7'h32;   // x
			8'h21: next_key = 7'h33;   // c
			8'h2A: next_key = 7'h34;   // v
			8'h32: next_key = 7'h35;   // b
			8'h31: next_key = 7'h37;   // n
			8'h3A: next_key = 7'h36;   // m
			8'h41: next_key = 7'h2e;   // comma
			8'h49: next_key = 7'h2f;   // period
			8'h4A: next_key = 7'h30;   // slash
			8'h29: next_key = 7'h38;   // space
			8'h0E: next_key = 7'h26;   // backquote
			8'h77: next_key = 7'h26;   // num lock -> backquote
			8'h0F: next_key = 7'h27;   // keypad equals
			8'h6C: next_key = 7'h21;   // kp 7
			8'h75: next_key = 7'h22;   // kp 8
			8'h7D: next_key = 7'h23;   // kp 9
			8'h7B: next_key = 7'h24;   // kp minus
			8'h6B: next_key = 7'h12;   // kp 4
			8'h73: next_key = 7'h18;   // kp 5
			8'h74: next_key = 7'h13;   // kp 6
			8'h79: next_key = 7'h15;   // kp plus
			8'h69: next_key = 7'h11;   // kp 1
			8'h72: next_key = 7'h17;   // kp 2
			8'h7A: next_key = 7'h14;   // kp 3
			8'h70: next_key = 7'h0b;   // kp 0
			8'h71: next_key = 7'h0c;   // kp period
			8'h7C: next_key = 7'h25;   // kp asterisk
			8'h05: next_key = 7'h01;   // F1 -> brightness down
			8'h06: next_key = 7'h19;   // F2 -> brightness up
			8'h03: next_key = 7'h02;   // F5 -> sound down
			8'h0B: next_key = 7'h1a;   // F6 -> sound up
			8'h09: next_key = 7'h58;   // F10 -> power key (to the RTC)
			default: ;
		endcase
		else case (c)
			8'h4A: next_key = 7'h28;   // kp slash
			8'h5A: next_key = 7'h0d;   // kp enter
			8'h6B: next_key = 7'h09;   // left
			8'h74: next_key = 7'h10;   // right
			8'h75: next_key = 7'h16;   // up
			8'h72: next_key = 7'h0f;   // down
			8'h69: next_key = 7'h02;   // end -> sound down
			8'h6C: next_key = 7'h1a;   // home -> sound up
			8'h7A: next_key = 7'h01;   // page down -> brightness down
			8'h7D: next_key = 7'h19;   // page up -> brightness up
			default: ;
		endcase
	end
endfunction

// modifier bit affected by this scancode, 0 if none
// (bit0 control, 1 lshift, 2 rshift, 3 lcmd, 4 rcmd, 5 lalt, 6 ralt;
// PC: windows keys = command, alt = alt, as in keymap.c unswapped)
function automatic [6:0] mod_bit;
	input       ext;
	input [7:0] c;
	begin
		mod_bit = 7'd0;
		if (c == 8'h14) mod_bit = 7'h01;              // control (both)
		else if (!ext && c == 8'h12) mod_bit = 7'h02; // left shift
		else if (!ext && c == 8'h59) mod_bit = 7'h04; // right shift
		else if (ext && c == 8'h1F) mod_bit = 7'h08;  // left win -> lcmd
		else if (ext && c == 8'h27) mod_bit = 7'h10;  // right win -> rcmd
		else if (!ext && c == 8'h11) mod_bit = 7'h20; // left alt
		else if (ext && c == 8'h11) mod_bit = 7'h40;  // right alt
	end
endfunction

// One 7-bit NeXT mouse axis field from a signed delta, matching
// kms_mouse_move() in kms.c: magnitude is clamped to 0x3F; a negative
// delta (left / up) is the bare magnitude, a positive delta (right /
// down) is (0x40 - magnitude) | 0x40, and zero is zero.
function automatic [6:0] mouse_field;
	input signed [9:0] d;
	reg [9:0] absd;
	reg [6:0] mag;
	begin
		absd = d[9] ? (-d) : d;
		mag  = (absd > 10'd63) ? 7'h3F : absd[6:0];
		if (!d[9] && mag != 0) mouse_field = (7'h40 - mag) | 7'h40; // right/down
		else                   mouse_field = mag;                    // left/up/zero
	end
endfunction

// kms_device_enabled / km_internal_poll: one of the six device nibbles
// [31:8] of the poll mask carries the device address (poll speed [3:0] and
// [7:4] are not device slots)
function automatic mask_has;
	input [31:8] m;
	input  [3:0] dev;
	begin
		mask_has = (m[31:28] == dev) || (m[27:24] == dev) || (m[23:20] == dev) ||
		           (m[19:16] == dev) || (m[15:12] == dev) || (m[11:8]  == dev);
	end
endfunction

function automatic nmi_magic;
	input [31:0] d;
	reg   [31:0] m;
	begin
		m = d & KMS_MAGIC_MASK;
		nmi_magic = (m == KMS_MAGIC_NMI_L) || (m == KMS_MAGIC_NMI_R) ||
		            (m == KMS_MAGIC_NMI_LR);
	end
endfunction

//----------------------------------------------------------------------------
// state
//----------------------------------------------------------------------------

reg  [7:0] st_km;        // $0200E001
reg  [1:0] st_tx;        // $0200E002 {KMS_ENABLE, TX_LOOP}
reg  [7:0] st_cmd;       // $0200E003 read
reg  [7:0] cmd;          // $0200E003 write
reg [31:0] kms_data;     // $0200E004
reg [31:0] kmdata;       // $0200E008
reg [31:0] km_mask;      // KMPOLL device poll mask
reg  [6:0] mods;         // physical modifier state (keyboard side)
reg  [1:0] ctrl_down;    // each Control key independently
reg        capslock;
reg        caps_down;    // ignore typematic repeats when toggling Caps Lock
reg        key_tgl, mouse_tgl;
reg        power_pulse, reset_pulse;

assign int_keymouse = st_km[7];          // KM_INT (INT_KEYMOUSE)
assign nmi          = st_km[4];          // NMI_RECEIVED (INT_NMI)
assign power_key    = power_pulse;
assign reset_req    = reset_pulse;
assign dbg_cmd      = cmd;

wire km_enable    = st_tx[1];
wire kbd_polled   = mask_has(km_mask[31:8], 4'h0);   // Turbo: keyboard address 0
wire mouse_polled = mask_has(km_mask[31:8], 4'h1);   // mouse = address | KM_MOUSE

wire       key_ev   = ps2_key[10] != key_tgl;
wire       ps2_make = ps2_key[9];
wire       ps2_ext  = ps2_key[8];
wire [7:0] ps2_code = ps2_key[7:0];

// mouse: dx/dy are 9-bit two's complement (byte plus its sign bit from the
// status byte).  PS/2 dy is up-positive; the NeXT wants down-positive.
wire        mouse_ev = ps2_mouse[24] != mouse_tgl;
wire signed [9:0] mouse_dx =  $signed({ps2_mouse[4], ps2_mouse[4], ps2_mouse[15:8]});
wire signed [9:0] mouse_dy = -$signed({ps2_mouse[5], ps2_mouse[5], ps2_mouse[23:16]});
// NeXT mouse word: [15:9] y, [8] right up, [7:1] x, [0] left up
wire [15:0] mouse16 = {mouse_field(mouse_dy), ~ps2_mouse[1],
                       mouse_field(mouse_dx), ~ps2_mouse[0]};
/* verilator lint_off UNUSEDSIGNAL */
wire unused_mouse = &{1'b0, ps2_mouse[7:6], ps2_mouse[3:2]};  // overflow, middle, bit 3
/* verilator lint_on UNUSEDSIGNAL */

// the unread KM message is a keyboard event: a mouse packet waits for it
wire kbd_event_pending = st_km[6] && kmdata[31:24] == 8'h10;

// $0200E004 as it reads after this write (byte-lane merge)
wire [31:0] data_w = {be[3] ? wdata[31:24] : kms_data[31:24],
                      be[2] ? wdata[23:16] : kms_data[23:16],
                      be[1] ? wdata[15:8]  : kms_data[15:8],
                      be[0] ? wdata[7:0]   : kms_data[7:0]};

//----------------------------------------------------------------------------
// next state: CPU access first, then (in a cycle without an access) one
// keyboard or mouse event, then the resulting KM message
//----------------------------------------------------------------------------

reg  [7:0] st_km_n, st_cmd_n, cmd_n;
reg  [1:0] st_tx_n;
reg [31:0] kms_data_n, kmdata_n, km_mask_n, rdata_n;
reg  [6:0] mods_n;
reg  [1:0] ctrl_down_n;
reg        capslock_n, caps_down_n, key_tgl_n, mouse_tgl_n, power_n, reset_req_n;
// the KM message of this cycle (kms_command_out(KMSCMD_KM_RECV, ...))
reg        post, post_ovr;
reg [31:0] post_data;
// keyboard event temporaries
reg  [6:0] kb_mb, kb_mods, kb_kc;
reg  [1:0] kb_ctrl;
reg        kb_caps_ev, kb_caps;

always_comb begin
	st_km_n     = st_km;     st_tx_n     = st_tx;     st_cmd_n  = st_cmd;
	cmd_n       = cmd;       kms_data_n  = kms_data;  kmdata_n  = kmdata;
	km_mask_n   = km_mask;   mods_n      = mods;      ctrl_down_n = ctrl_down;
	capslock_n  = capslock;  caps_down_n = caps_down;
	key_tgl_n   = key_tgl;   mouse_tgl_n = mouse_tgl;
	power_n     = 1'b0;      reset_req_n = 1'b0;
	post        = 1'b0;      post_ovr    = 1'b0;      post_data = 32'd0;
	kb_mb = 7'd0; kb_mods = 7'd0; kb_kc = 7'd0; kb_ctrl = 2'd0;
	kb_caps_ev = 1'b0; kb_caps = 1'b0;

	case (addr)
	2'd0:    rdata_n = {8'h00, st_km, 6'd0, st_tx, st_cmd};   // SOUND HOOK: byte 0
	2'd1:    rdata_n = kms_data;
	2'd2:    rdata_n = kmdata;
	default: rdata_n = 32'd0;
	endcase

	if (stb) begin
		if (we) begin
			case (addr)
			2'd0: begin
				// be[3] $0200E000 sound control (KMS_Ctrl_Snd_Write).  SOUND HOOK:
				// SNDOUT/SNDIN_DMA_ENABLE r/w, a 1 in bit 5 / bit 1 clears the
				// underrun / overrun (and INT_SOUND_OVRUN) when that side is idle.
				if (be[2]) begin                       // KMS_Ctrl_KM_Write
					if (wdata[21]) st_km_n = st_km_n & ~(KM_RECEIVED | KM_OVERRUN | KM_INT);
					if (wdata[20]) st_km_n = st_km_n & ~NMI_RECEIVED;
					if (wdata[17]) st_km_n = st_km_n & ~(KMS_RECEIVED | KMS_OVERRUN | KMS_INT);
				end
				if (be[1]) begin                       // KMS_Ctrl_TX_Write
					if (st_tx[1] && !wdata[9]) begin   // KMS_ENABLE 1 -> 0: kms_reset()
						st_km_n = 8'd0; st_cmd_n = 8'd0; cmd_n = 8'd0;
						kms_data_n = 32'd0; kmdata_n = 32'd0; km_mask_n = 32'd0;
						// SOUND HOOK: snd_stop_output / snd_stop_input
					end
					st_tx_n = wdata[9:8];
				end
				if (be[0]) cmd_n = wdata[7:0];        // KMS_Ctrl_Cmd_Write
			end
			2'd1: begin                                // KMS_Data_Write
				kms_data_n = data_w;
				if (be[0] && km_enable) begin
					if (st_tx[0]) begin
						// TX_LOOP: kms_command_out.  SOUND HOOK: $07 SO_REQ,
						// $0F SO_UNDR, $C7 CODEC_IN are sound messages.
						if (cmd == KMSCMD_KM_RECV) begin
							post = 1'b1;
							post_data = data_w;
						end
					end
					else case (cmd)                    // kms_command_in
					KMSCMD_RESET:
						if (data_w == 32'hFFFFFFFF) begin
							st_km_n = 8'd0; st_tx_n = 2'd0; st_cmd_n = 8'd0; cmd_n = 8'd0;
							kms_data_n = 32'd0; kmdata_n = 32'd0; km_mask_n = 32'd0;
							// SOUND HOOK: snd_stop_output / snd_stop_input
						end
					KMSCMD_KMPOLL:
						km_mask_n = data_w;
					KMSCMD_KMREG: begin                // km_access
						post = 1'b1;
						post_data = KM_NO_RESPONSE;
						if (data_w[31:24] == 8'h0F)      // KM_CMD_RESET: km_reset
							km_mask_n = 32'd0;
						else if (data_w[31:24] != 8'hEF && data_w[28]) begin
							if (data_w[31:29] == 3'd7)   // km_version (no no-response)
								post_data = {8'h20, KMS_REV, 8'h01, data_w[24] ? 8'h02 : 8'h01};
							else if (data_w[31:29] == 3'd0)
								post_ovr = 1'b1;           // km_user_poll then no-response
						end
						// $EF set address: REV_NEW keeps address 0.  Writes
						// (keyboard LEDs, the ROM's $C5 $30000 / $C5 0): no-response.
					end
					// SOUND HOOK: $C7 ASNDOUT (snd_send_sample), $C4 CTRLOUT
					// (snd_gpo_access), $C2 VOLCTRL (REV_NEW: snd_vol_access),
					// (cmd & $C7) == $07 sound out / $03 sound in enable/disable.
					default: ;
					endcase
				end
			end
			default: ;                                 // $0200E008/C: no writes
			endcase
		end
		else if (addr == 2'd2)                         // KMS_KM_Data_Read
			st_km_n = st_km_n & ~(KM_RECEIVED | KM_INT);
	end
	else if (key_ev) begin
		// keyboard event (kms_keydown / kms_keyup)
		key_tgl_n = ps2_key[10];
		kb_mb   = mod_bit(ps2_ext, ps2_code);
		kb_mods = ps2_make ? (mods | kb_mb) : (mods & ~kb_mb);
		kb_ctrl = ctrl_down;
		if (ps2_code == 8'h14) begin
			kb_ctrl[ps2_ext] = ps2_make;
			kb_mods[0] = |kb_ctrl;
		end
		ctrl_down_n = kb_ctrl;
		mods_n = kb_mods;
		kb_caps_ev = !ps2_ext && ps2_code == 8'h58;
		kb_caps = capslock;
		if (kb_caps_ev) begin
			if (ps2_make && !caps_down) kb_caps = ~capslock;
			caps_down_n = ps2_make;
		end
		capslock_n = kb_caps;
		kb_kc = next_key(ps2_ext, ps2_code);
		if (kb_kc == NEXTKEY_POWER)
			power_n = ps2_make;                        // rtc_request_power_down
		else if (!ps2_ext && ps2_code == PS2_F11) begin
			// one-key NMI: sent as Command-Command-`
			if (ps2_make && km_enable && kbd_polled) begin
				post = 1'b1;
				post_data = KMS_MAGIC_NMI_LR;
			end
		end
		else if ((kb_kc != 0 || kb_mb != 0 || kb_caps_ev) && km_enable && kbd_polled) begin
			post = 1'b1;
			post_data = {8'h10, 8'h00, 1'b1, kb_mods | {5'd0, kb_caps, 1'b0},
			             !ps2_make, kb_kc};
		end
	end
	else if (mouse_ev && !kbd_event_pending) begin
		// mouse packet (kms_mouse_move / kms_mouse_button)
		mouse_tgl_n = ps2_mouse[24];
		if (km_enable && mouse_polled) begin
			post = 1'b1;
			post_data = {8'h01, 8'h00, mouse16};
		end
	end

	// kms_km_receive: magic key compare, else post the KM message
	if (post) begin
		if ((post_data & KMS_MAGIC_MASK) == KMS_MAGIC_RESET)
			reset_req_n = 1'b1;
		else if (nmi_magic(post_data))
			st_km_n = st_km_n | NMI_RECEIVED;
		else begin
			kmdata_n = post_data;
			st_cmd_n = KMSCMD_KM_RECV;
			if ((st_km_n & KM_RECEIVED) != 0 || post_ovr)
				st_km_n = st_km_n | KM_OVERRUN;
			st_km_n = st_km_n | KM_RECEIVED | KM_INT;
		end
	end
end

always_ff @(posedge clk) begin
	if (reset) begin
		st_km <= 8'd0; st_tx <= 2'd0; st_cmd <= 8'd0; cmd <= 8'd0;
		kms_data <= 32'd0; kmdata <= 32'd0; km_mask <= 32'd0;
		mods <= 7'd0; ctrl_down <= 2'd0; capslock <= 1'b0; caps_down <= 1'b0;
		// consume the current host strobes: no stale event replayed after reset
		key_tgl <= ps2_key[10];
		mouse_tgl <= ps2_mouse[24];
		power_pulse <= 1'b0; reset_pulse <= 1'b0;
		ack <= 1'b0; rdata <= 32'd0;
	end
	else begin
		st_km <= st_km_n; st_tx <= st_tx_n; st_cmd <= st_cmd_n; cmd <= cmd_n;
		kms_data <= kms_data_n; kmdata <= kmdata_n; km_mask <= km_mask_n;
		mods <= mods_n; ctrl_down <= ctrl_down_n;
		capslock <= capslock_n; caps_down <= caps_down_n;
		key_tgl <= key_tgl_n; mouse_tgl <= mouse_tgl_n;
		power_pulse <= power_n; reset_pulse <= reset_req_n;
		ack <= stb;
		if (stb) rdata <= rdata_n;
	end
end

endmodule
