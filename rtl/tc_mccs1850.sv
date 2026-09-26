//============================================================================
//  tc_mccs1850 -- Motorola MCCS1850 real-time clock / NVRAM of the
//  NeXTstation Turbo Color, bit-banged by the CPU through SCR2 byte 2
//  (bit 8 RTCE, bit 9 RTCLK, bit 10 RTDATA of the long at $0200D000).
//
//  Sources
//    [P]  Previous r1851 src/rtcnvram.c (MCCS1850 = the "newrtc" code,
//         lines 449-760; common interface 763-813; RTC_Reset 827-833;
//         nvram_init 951-1074; nvram_checksum 1076-1098), src/sysReg.c
//         436-456 (SCR2 byte 2 -> rtc_interface_*), src/tmc.c 159-160,
//         src/includes/configuration.h 330-333, src/configuration.c 889-915.
//    [R]  NeXT ROM Rev 3.3 v74, rom-dissassembly/Rev_3.3_v74.asm (routine
//         names from known_names.py); hardware-summary.md sections 0.3,
//         0.4, 3.3, 12 and 16.1 item 11.
//    [M]  NeXT_MiSTer rtl/next/next_scr.sv (the mono core's MC68HC68T1,
//         same SCR2 bit-bang and MiSTer plumbing).  Borrowed from it: the
//         phase counter advanced on each falling RTCLK edge with RTCE high
//         (its lines ~427-473, after [P] *_interface_io), the one-time seed
//         of the clock from hps_io TIMESTAMP on its first toggle (~290-297),
//         the one-add-per-clock one's-complement checksum over the freshly
//         built image (~237-270), the OSD-driven boot command bytes 18-29
//         (~181-235) and the rule that neither a CPU RESET nor the machine
//         reset touches NVRAM or time (~276-282).
//
//  Serial protocol (rtc_read_reg_raw $010087e8, rtc_write_reg $010086e8;
//  every SCR2 write is followed by delay_us(1) = sub_0100822c):
//    SCR2 = base|$100                          CE high           ($0100880a)
//    8x   base|$100|d, |$200, &~$200           address, MSB first ($01008818)
//                                              writes use reg|$80 ($01008704)
//    read  8x: base|$300 (CLK high); base|$100 (CLK low); sample
//              SCR2 & $400                     ($0100884c..$0100886a)
//    write 8x: like the address bits           ($01008752..$01008782)
//    SCR2 = base                               CE low            ($0100888a)
//  The chip therefore acts on the FALLING edge of RTCLK while RTCE is high,
//  exactly as [P] sysReg.c:441 calls rtc_interface_write(): falling edges
//  1-8 shift in the address, falling edge 9 loads the register and puts its
//  bit 7 on RTDATA, edges 10-16 put out bits 6..0 ([P] rtcnvram.c:724,
//  rtdatabit = val bit (16 - phase)).  The ROM samples each bit after the
//  falling edge, so it reads bit 7 first.  After edge 16 the address
//  auto-increments within its low 7 bits and the phase drops back to 8
//  ([P] 742-747: $7F -> $00, $FF -> $80); the ROM never uses bursts (it
//  toggles RTCE around every byte, rtc_read_regs $01008790), but they cost
//  nothing.  RTCE low resets the serial state ([P] rtc_interface_reset
//  784-795, which on a Turbo also returns RTDATA = 0).
//
//  rtc_drive is 1 from the ninth falling edge of a READ until RTCE drops;
//  the machine should return rtc_dout in SCR2 bit 10 while it is set and
//  the CPU-written bit otherwise.  (Previous always returns its last serial
//  bit, which outside the read data phase is the echo of what the CPU wrote,
//  or 0 after RTCE low; the ROM masks bits 8-10 of every SCR2 read it does
//  outside the data phase, andi.w #$f8ff at $01008804 / $0100870a.)
//
//  Register map ([P] newrtc_get_clock 534-576 / newrtc_put_clock 578-666 /
//  newrtc_interface_io 697-753); write address = read address | $80:
//    $00-$1F  NVRAM, 32 bytes, used by the ROM (nvram_read $0100861c,
//             nvram_write $0100866c, walking-one test in
//             nvram_check_or_rtc_ramtest $01005cd2: every bit of $00-$1F
//             must be read/write, 1,2,4..$80 written and read back)
//    $40-$5F  second NVRAM bank, 32 bytes ([P] ram2[], 515/710/734; the ROM
//             never touches it).  Cleared at FPGA configuration only.
//    $20-$23  32-bit seconds counter, big endian, binary Unix time (UTC).
//             rtc_get_time $010084d6 reads $20..$23 when $30 bit 7 is set;
//             post_rtc_test $010052d0 and rtc_wait_tick $0100823e poll $23.
//             Counts real seconds (CLK_HZ clocks) while control START is
//             set.  A read returns the counter as latched at the RTCE rising
//             edge ([P] newrtc_interface_start 756-760); a write replaces
//             one byte of the running counter ([P] 582-609).
//    $24-$27  32-bit alarm counter, read/write, stored only: Previous has
//             the alarm compare compiled out ([P] 668-678), so ALARM never
//             sets here either.
//    $30      status, read only ([P] 461-479, read at 564-566 as
//             (status & $3F) | $80):
//               7 NEWCHIP = 1 (the ROM picks the MCCS1850 code paths on it:
//                 rtc_wait_tick, rtc_get_time, rtc_power_int_handler
//                 $010082ee, rtc_int_clear $010083e4, rtc_start_clock
//                 $01008416, rtc_power_down $01008390)
//               5 TMODE 0, 4 FIRSTUP, 3 INT, 2 LBAT, 1 ALARM, 0 PDOWN.
//             FIRSTUP, LBAT and ALARM have no source (Previous never sets
//             them); PDOWN is set by a power_key pulse ([P]
//             newrtc_request_power_down 689-692, called from kms.c:392 /
//             adb.c:101); key release does nothing ([P] 694).
//             INT = (ALARM & ALRM_EN) | (LBAT & LBE) | FIRSTUP | PDOWN
//             ([P] newrtc_check_interrupt 521-531) and drives power_int.
//    $31      control ([P] 482-506, read back as control & ~$4D at 567-569):
//               7 START (1 at power-up, [P] RTC_Reset 829), 6 POWERDOWN,
//               5 AR, 4 ALRM_EN, 3 CLRALARM, 2 CLRFTU, 1 LBE, 0 CLRPDOWN.
//             Bits 7,5,4,1 are stored and read back; 3,2,0 are write
//             strobes that clear their status bit, LBE = 0 clears LBAT
//             ([P] 649-660).  POWERDOWN ($40, written by rtc_power_down
//             $01008380 after an 850 ms delay; the ROM then spins in
//             bra.b * at $010083ce) is accepted and ignored: Previous quits
//             the emulator there, this module has no power switch.
//             The ROM's writes: rtc_start_clock $01008400 |= $80;
//             rtc_power_int_handler $010082ca, per status bit, via
//             rtc_modify_reg $0100828c (read $31, and ~mask, or val&mask,
//             write): FIRSTUP -> |= 4, LBAT -> &= ~2, ALARM -> |= 8,
//             PDOWN -> |= 1, looping while interrupt status bit 2 is set.
//    $32      old-chip interrupt control: reads 0, writes ignored.  The ROM
//             only writes it when $30 bit 7 is clear (rtc_int_clear $010083e4).
//    others   read 0, writes ignored ([P] default cases).
//
//  Reset behaviour
//    reset         (machine reset and the CPU RESET instruction) only resets
//                  the serial interface ([P] SCR_Reset -> rtc_interface_reset);
//                  a transfer cut short by it writes nothing.
//                  NVRAM, time, alarm, status and control are battery backed.
//    config_reset  (power-up / OSD reset) rebuilds NVRAM $00-$1F from the
//                  default image below, sets control = START and clears the
//                  status flags ([P] RTC_Reset: control = START; nvram_init).
//                  Time is NOT re-seeded (a real battery clock keeps its time
//                  over a power cycle, and the guest may have set it); bank 2
//                  ($40-$5F) is kept.  The image is written one byte per
//                  clock during the 32 clocks after config_reset falls, from
//                  the live ram_cfg / pot_on / boot_cmd.
//    FPGA configuration: the same build, plus $40-$5F cleared; the clock
//                  starts at NEXT_START_SEC and is seeded from TIMESTAMP on
//                  its first toggle, clamped to [0, NEXT_LIMIT_SEC) like
//                  [P] newrtc_check_time 680-687 / configuration.h 330-333.
//
//  Default NVRAM image (bytes; layout [P] 839-937, hardware-summary 12.3).
//  It is the image the ROM itself builds in mg_init_machine ($01000de4..
//  $01000e1e: bzero, reset field 9, brightness $3D, allow eject, POT $11,
//  boot "en") with the Previous Turbo additions ([P] nvram_init) and the
//  OSD choices, and it carries a checksum the ROM accepts, so the ROM does
//  not rebuild its own "en" default:
//    0-3   $94 $0F $40 $00  long $940F4000: reset 9 (bits 31:28, checked
//          == 9 by bfextu (a4){0:4} at $01000dda), allow eject (bit 26),
//          brightness $3D (bits 19:14; vid_enable_display rewrites it only
//          when < $14), volumes 0 (= loudest), no password (bits 13:10 = 0)
//    4-9   0 (password / Ethernet address fallback; the ROM header MAC
//          00:00:0f:12:34:56 is used because its bytes 3-5 are not FF FF FF)
//    10-11 ni_simm, big endian; see below
//    12-13 0
//    14    POT: pot_on ? $11 (POT_ON | TEST_DRAM, the ROM's own default) : $00
//    15-16 0 (POST error history)
//    17    $A0: NEW_CLOCK_CHIP ($80, [P] 1057) | USE_CONSOLE_SLOT ($20, slot 0,
//          [P] 1063).  The ROM does not read bit 7 (it asks $30 instead) and
//          on a station ignores the console slot (vid_console_init reads it
//          at $0100acc8 but the station path $0100ad26 -> $0100adee drops it)
//    18-29 boot command, boot_cmd[95:88] first, NUL padded ("sd" = boot the
//          first SCSI disk; empty = stop at the NeXT> prompt; 11 characters
//          or fewer keeps it NUL terminated after nvram_write rewrites the
//          checksum word into the monitor's copy)
//    30-31 checksum word
//
//  Checksum (nvram_read $0100861c / nvram_write $0100866c, net_ip_checksum
//  $0100743c): the 32 bytes are summed as 16 big-endian words with the
//  checksum word taken as 0, each add folded end-around (sum >= $10000 ->
//  sum - $10000 + 1, $0100745a..$01007464); stored word = ~sum.  nvram_read
//  also rejects a computed ~sum of 0 (not.w d0 / beq at $01008654).  This
//  is [P] nvram_checksum (bytes 0-29).  Here it is accumulated per byte
//  (high byte << 8, low byte), which gives the same folded sum.
//
//  SIMM word (bytes 10-11).  mon_init compares it with the sizing result at
//  $01001548..$01001576 and, on a mismatch, prints "Memory sockets %d and %d
//  (%s) configured for %s SIMMs but have %s SIMMs installed" and rewrites
//  NVRAM ($0100162c, $0100163c..$0100167a, write-back after $010016c6).
//  Per bank i (0..3) with sizing code c = mg_simm[i]:
//      bits 3i+2..3i = c & 7                 (and #7, shift 3i:  $0100155a)
//      bit  12+i     = c bit 3 (parity)      (asr (9+i), and #8: $0100155e..$0100156a)
//  (hardware-summary 3.1's "parity bit at 9+i" is the shift count; the bit
//  itself is 12+i, which is also [P] 901-907 "bit 12-15 parity").
//  Codes from mem_bank_size_t $01003598 (called for base and base+4 by
//  mem_config_test_t $0100361a; tbl_simm_size_turbo $01014aa4 = [0, 32M,
//  8M, 2M]): 1 = 32 MB pair (no alias), 2 = 8 MB pair (alias at +8 MB),
//  3 = 2 MB pair (alias at +2 MB), 0 = empty.  Bit 3 (parity) is set at
//  $01003820 only if TMC control bit 10 still reads 1 after
//  mem_parity_probe_t ($01003ee8 / $01003f04); Previous masks that bit
//  (tmc.c:160 "no parity memory") and so does the image here: parity 0.
//  [P] nvram_init 1000-1010/1034 builds the same word (SIMM_32MB_T = 1,
//  SIMM_8MB_T = 2, SIMM_2MB_T = 3, Turbo parity nibble 0; its Turbo
//  default 4 x 32 MB gives $0249).
//      ram_cfg 0: 64 MB  = banks 0,1 x 32 MB -> codes 1,1,0,0 -> $0009
//      ram_cfg 1: 128 MB = 4 x 32 MB         -> codes 1,1,1,1 -> $0249
//      ram_cfg 2: 16 MB  = banks 0,1 x 8 MB  -> codes 2,2,0,0 -> $0012
//      ram_cfg 3: 32 MB  = bank 0 x 32 MB    -> codes 1,0,0,0 -> $0001
//
//  Size: 64 x 8 RAM (inferred; MLAB or M10K), two 32-bit counters, a 32-bit
//  read latch, the prescaler and a small sequencer.
//============================================================================

module tc_mccs1850 #(
	parameter CLK_HZ = 33000000          // clk_sys; used for the 1-second tick
)(
	input             clk,                // clk_sys 33 MHz
	input             reset,              // machine reset (CPU RESET etc.): must NOT clear NVRAM or time
	input             config_reset,       // power-up / user reset from the OSD: rebuild the default NVRAM image
	// SCR2 pins as the CPU drives them (already registered in clk domain):
	input             rtc_ce,             // SCR2 bit 8  (RTCE, chip enable, active high as the ROM uses it)
	input             rtc_clk,            // SCR2 bit 9  (RTCLK)
	input             rtc_din,            // SCR2 bit 10 as written by the CPU (RTDATA out)
	output            rtc_dout,           // what the CPU reads back in SCR2 bit 10 while the chip drives it
	output            rtc_drive,          // 1 while the chip is driving the data line (read data phase)
	// HPS time: hps_io TIMESTAMP, Unix seconds UTC in [31:0], bit 32 toggles on each update
	input      [32:0] timestamp,
	// default image inputs (sampled at config_reset):
	input       [1:0] ram_cfg,            // 0 = 64 MB (banks 0,1 = 32 MB each), 1 = 128 MB (4 x 32 MB), 2 = 16 MB (banks 0,1 = 8 MB each), 3 = 32 MB (bank 0 = 32 MB)
	input             pot_on,             // 1 = power-on self test on (POT byte = $11 like the ROM's default), 0 = POT byte $00
	input      [95:0] boot_cmd,           // up to 12 ASCII chars, first char in [95:88], NUL padded (e.g. "sd" or all zero = empty)
	// power button (from the keyboard layer): a pulse requests power-down/on events like the real button
	input             power_key,
	output            power_int,          // level: the chip's interrupt output -> interrupt status bit 2 (INT_POWER). Must be 0 normally.
	// debug
	output      [7:0] dbg_last_reg        // last register address accessed
);

// [P] configuration.h 330-333
localparam [31:0] NEXT_START_SEC = 32'd552225600;    // Thu Jul  2 12:00:00 1987 UTC
localparam [31:0] NEXT_LIMIT_SEC = 32'd2145916800;   // Fri Jan  1 00:00:00 2038 UTC

//----------------------------------------------------------------------------
// NVRAM: $00-$1F at RAM 0-31, $40-$5F at RAM 32-63
//----------------------------------------------------------------------------

(* ramstyle = "no_rw_check" *) reg [7:0] nvram [0:63];
reg  [7:0] ram_q;
wire       ram_we;
wire [5:0] ram_wa;
wire [7:0] ram_wd;
wire [5:0] ram_ra;

always @(posedge clk) begin
	if (ram_we) nvram[ram_wa] <= ram_wd;
	ram_q <= nvram[ram_ra];
end

//----------------------------------------------------------------------------
// default image builder
//----------------------------------------------------------------------------

reg        bld_run = 1'b1;        // FPGA configuration builds the image ...
reg        bld_all = 1'b1;        // ... and clears bank 2 as well
reg  [5:0] bld_k   = 6'd0;
reg [15:0] bld_sum = 16'd0;

function automatic [15:0] simm_word(input [1:0] cfg);
	case (cfg)
		2'd0:    simm_word = 16'h0009;   // 32 MB + 32 MB
		2'd1:    simm_word = 16'h0249;   // 4 x 32 MB
		2'd2:    simm_word = 16'h0012;   // 8 MB + 8 MB
		default: simm_word = 16'h0001;   // 32 MB in bank 0
	endcase
endfunction

function automatic [7:0] img_byte(input [4:0] k, input [1:0] cfg, input pot, input [95:0] bc);
	reg  [3:0] ci;                      // boot_cmd character index, 0 = byte 29
	reg [15:0] sw;
	begin
		ci = 4'd13 - k[3:0];                // = 29 - k for k = 18..29
		sw = simm_word(cfg);
		case (k)
			5'd0:  img_byte = 8'h94;
			5'd1:  img_byte = 8'h0F;
			5'd2:  img_byte = 8'h40;
			5'd10: img_byte = sw[15:8];
			5'd11: img_byte = sw[7:0];
			5'd14: img_byte = pot ? 8'h11 : 8'h00;
			5'd17: img_byte = 8'hA0;
			5'd18, 5'd19, 5'd20, 5'd21, 5'd22, 5'd23,
			5'd24, 5'd25, 5'd26, 5'd27, 5'd28, 5'd29:
			       img_byte = bc[{ci, 3'b000} +: 8];
			default: img_byte = 8'h00;
		endcase
	end
endfunction

wire  [7:0] bld_img = img_byte(bld_k[4:0], ram_cfg, pot_on, boot_cmd);
wire  [7:0] bld_d   = bld_k[5]              ? 8'h00 :
                      (bld_k[4:0] == 5'd30) ? ~bld_sum[15:8] :
                      (bld_k[4:0] == 5'd31) ? ~bld_sum[7:0] : bld_img;
wire [15:0] bld_add = bld_k[0] ? {8'h00, bld_img} : {bld_img, 8'h00};
wire [16:0] bld_s   = {1'b0, bld_sum} + {1'b0, bld_add};
wire [15:0] bld_f   = bld_s[15:0] + {15'd0, bld_s[16]};   // end-around carry

always @(posedge clk) begin
	if (config_reset) begin
		// restart while held; the build runs after it is released
		bld_run <= 1'b1;
		bld_k   <= 6'd0;
		bld_sum <= 16'd0;
	end
	else if (bld_run) begin
		if (bld_k < 6'd30) bld_sum <= bld_f;
		if (bld_k == (bld_all ? 6'd63 : 6'd31)) begin
			bld_run <= 1'b0;
			bld_all <= 1'b0;
		end
		bld_k <= bld_k + 6'd1;
	end
end

//----------------------------------------------------------------------------
// serial interface
//----------------------------------------------------------------------------

reg        ce_q = 1'b0, clk_q = 1'b0, pk_q = 1'b0;
reg  [4:0] phase = 5'd0;          // [P] 'phase': falling edges seen, 0..16
reg  [7:0] addr = 8'd0;           // [P] 'rtc_addr' (bit 7 = write)
reg  [7:0] sh = 8'd0;             // read shift / write accumulator ([P] 'rtc_val')
reg        dout = 1'b0;
reg        drive = 1'b0;
reg  [7:0] last_reg = 8'd0;

wire       step    = rtc_ce & clk_q & ~rtc_clk;    // [P] sysReg.c:441
wire       ce_rise = rtc_ce & ~ce_q;               // [P] sysReg.c:438
wire [4:0] nph     = phase + 5'd1;
wire       a_wr    = addr[7];
wire       a_clk   = addr[5];                      // [P] RTC_ADDR_CLOCK
wire [7:0] wr_byte = {sh[6:0], rtc_din};
wire       commit  = step && (nph == 5'd16) && a_wr && !reset && !config_reset;

assign ram_ra = {addr[6], addr[4:0]};
assign ram_we = bld_run ? 1'b1 : (commit && !a_clk);
assign ram_wa = bld_run ? bld_k : {addr[6], addr[4:0]};
assign ram_wd = bld_run ? bld_d : wr_byte;

//----------------------------------------------------------------------------
// clock, alarm, status, control
//----------------------------------------------------------------------------

localparam integer PW   = (CLK_HZ > 1) ? $clog2(CLK_HZ) : 1;
localparam integer PMAX = CLK_HZ - 1;

reg [PW-1:0] presc  = {PW{1'b0}};
reg   [31:0] tcnt   = NEXT_START_SEC;   // the running seconds counter
reg   [31:0] tlatch = NEXT_START_SEC;   // read latch, loaded at RTCE rising
reg   [31:0] alarm  = 32'd0;
reg          ts_q   = 1'b0;
reg          seeded = 1'b0;

reg ctl_start = 1'b1, ctl_ar = 1'b0, ctl_alen = 1'b0, ctl_lbe = 1'b0;
reg st_firstup = 1'b0, st_lbat = 1'b0, st_alarm = 1'b0, st_pdown = 1'b0;

wire st_int  = (st_alarm & ctl_alen) | (st_lbat & ctl_lbe) | st_firstup | st_pdown;
wire sec_end = (presc == PMAX[PW-1:0]);

wire [7:0] reg_status  = {1'b1, 1'b0, 1'b0, st_firstup, st_int, st_lbat, st_alarm, st_pdown};
wire [7:0] reg_control = {ctl_start, 1'b0, ctl_ar, ctl_alen, 2'b00, ctl_lbe, 1'b0};

reg [7:0] rd_val;
always @(*) begin
	if (!a_clk) rd_val = ram_q;
	else case (addr[6:0])
		7'h20: rd_val = tlatch[31:24];
		7'h21: rd_val = tlatch[23:16];
		7'h22: rd_val = tlatch[15:8];
		7'h23: rd_val = tlatch[7:0];
		7'h24: rd_val = alarm[31:24];
		7'h25: rd_val = alarm[23:16];
		7'h26: rd_val = alarm[15:8];
		7'h27: rd_val = alarm[7:0];
		7'h30: rd_val = reg_status;
		7'h31: rd_val = reg_control;
		default: rd_val = 8'h00;
	endcase
end

always @(posedge clk) begin
	ce_q  <= rtc_ce;
	clk_q <= rtc_clk;
	pk_q  <= power_key;
	ts_q  <= timestamp[32];

	//------------------------------------------------------------
	// seconds counter: seed once from the host, then count; a
	// machine reset does not touch it (the ROM's clock test,
	// post_rtc_test $010052d0, needs a change within 1.1 s)
	//------------------------------------------------------------
	// the 1 Hz divider runs on while START is clear, like Previous's host
	// clock ([P] 635-641 restarts from the frozen count on the host's
	// second grid), so a restart ticks within a second
	presc <= sec_end ? {PW{1'b0}} : presc + 1'd1;

	if (!seeded && (timestamp[32] != ts_q)) begin
		seeded <= 1'b1;
		tcnt   <= (timestamp[31:0] < NEXT_LIMIT_SEC) ? timestamp[31:0] : NEXT_START_SEC;
	end
	else if (commit && a_clk && (addr[6:2] == 5'b01000)) begin      // $A0-$A3
		case (addr[1:0])
			2'd0: tcnt[31:24] <= wr_byte;
			2'd1: tcnt[23:16] <= wr_byte;
			2'd2: tcnt[15:8]  <= wr_byte;
			2'd3: tcnt[7:0]   <= wr_byte;
		endcase
	end
	else if (ctl_start && sec_end)
		tcnt <= tcnt + 32'd1;

	if (ce_rise) tlatch <= tcnt;

	if (commit && a_clk && (addr[6:2] == 5'b01001)) begin           // $A4-$A7
		case (addr[1:0])
			2'd0: alarm[31:24] <= wr_byte;
			2'd1: alarm[23:16] <= wr_byte;
			2'd2: alarm[15:8]  <= wr_byte;
			2'd3: alarm[7:0]   <= wr_byte;
		endcase
	end

	//------------------------------------------------------------
	// control ($B1) and status
	//------------------------------------------------------------
	if (commit && a_clk && (addr[6:0] == 7'h31)) begin
		ctl_start <= wr_byte[7];
		ctl_ar    <= wr_byte[5];
		ctl_alen  <= wr_byte[4];
		ctl_lbe   <= wr_byte[1];
		if (wr_byte[3])  st_alarm   <= 1'b0;   // CLRALARM
		if (wr_byte[2])  st_firstup <= 1'b0;   // CLRFTU
		if (!wr_byte[1]) st_lbat    <= 1'b0;   // LBE off
		if (wr_byte[0])  st_pdown   <= 1'b0;   // CLRPDOWN
	end
	if (power_key && !pk_q) st_pdown <= 1'b1;  // a new press wins over a clear

	if (config_reset) begin
		ctl_start  <= 1'b1;
		ctl_ar     <= 1'b0;
		ctl_alen   <= 1'b0;
		ctl_lbe    <= 1'b0;
		st_firstup <= 1'b0;
		st_lbat    <= 1'b0;
		st_alarm   <= 1'b0;
		st_pdown   <= 1'b0;
	end

	//------------------------------------------------------------
	// serial state machine ([P] newrtc_interface_io 697-753)
	//------------------------------------------------------------
	if (reset || config_reset || !rtc_ce) begin
		phase <= 5'd0;
		addr  <= 8'd0;
		dout  <= 1'b0;
		drive <= 1'b0;
	end
	else if (step) begin
		if (nph <= 5'd8) begin
			addr  <= {addr[6:0], rtc_din};
			phase <= nph;
			if (nph == 5'd8) last_reg <= {addr[6:0], rtc_din};
		end
		else begin
			if (a_wr)
				sh <= wr_byte;
			else if (nph == 5'd9) begin
				sh    <= {rd_val[6:0], 1'b0};
				dout  <= rd_val[7];
				drive <= 1'b1;
			end
			else begin
				sh   <= {sh[6:0], 1'b0};
				dout <= sh[7];
			end
			if (nph == 5'd16) begin
				addr[6:0] <= addr[6:0] + 7'd1;
				phase     <= 5'd8;
			end
			else
				phase <= nph;
		end
	end
end

assign rtc_dout     = dout;
assign rtc_drive    = drive;
assign power_int    = st_int;
assign dbg_last_reg = last_reg;

endmodule
