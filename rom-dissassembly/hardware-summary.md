# Hardware requirements of the NeXT ROM v74 (Rev 3.3) for a Turbo Color FPGA core

Consolidated from `notes/01000000.md` .. `notes/01010000.md` (the nine range analyses of
`Rev_3.3_v74.asm`) and the register bit names of the Previous emulator sources. Every fact
cites the routine (name / address) it was taken from so it can be re-verified in the listing.

Target: **machine type 5 = NeXTstation Turbo Color** (33 MHz 68040, TMC, PC peripheral chip,
Bt463, 2 MB VRAM at `$0C000000`). Every table says whether an item applies to the Turbo Color
path ("**TC**") or only to other machines ("other").

## 0. Conventions and global facts

### 0.1 Machine-class gates used by the code

| gate | value on Turbo Color | set where | meaning |
|---|---|---|---|
| `mg+$3A8` | 5 | `reset_mg_in_dram` $01000514 (from `msp`) | machine type = SCR1 bits 15:12 |
| `mg+$194` | **0** | `mg_init_machine` sub_01000c9c: `$139` for types **0,1,2,3** (`loc_01000d32` type 0, `loc_01000d3c` types 1..3, verified from the `cmp/blt/ble` chain at $01000d20..$01000d30), 0 for types 4..$B | `$139` = original NeXT DMA/memory chip set. Every `cmpi.l #$139,$194(aN)` in the ROM selects the non-Turbo path; **Turbo Color always takes the "not $139" side**. (`notes/01000000.md` says "types 0,1,2 only"; the listing shows type 3 included. The other notes are right.) |
| `mg+$3B2` | 0 | same | BMAP pointer (`$020C0000`), types 1..3 only. Every BMAP access is skipped on TC. |
| `mg+$3B6` | 1 | type table `$01011BF0` -> sub_01000d96 | "station": no NeXTbus slot scan, no "Backplane slot" line |
| `mg+$3BA` | 1 | same | paired-SIMM memory system (Turbo tables) |
| `mg+$3BE` | 2 | same (and `adb_probe_kbd_alt_video` sub_0100c626) | video-interrupt style 2 = TMC (`$02200080`), interrupt bit 13 |
| `mg+$3CA` / `mg+$3CE` | 0 / 0 | same (only types 6,7,$A,$B set the NCC pointers) | no NCC / cache-tag tests on TC |
| `mg+$6` (mg_sid) | 0 | sub_01000d96 clears it for types 4..7 | on-board display is "slot 0" |

### 0.2 Address decoding the ROM relies on

* The ROM reaches most peripheral chips through the **`$021xxxxx` alias** (bit 20 set) of the
  `$020xxxxx` device page: ESP `$02114000`, ESP DMA control `$02114020`, floppy `$02114100/8`,
  hardclock `$02116000`, SCC `$02118000..4`, event counter `$0211A000`, brightness `$02110000`,
  Ethernet `$02106000`, MO `$02112000`. It uses the plain `$020xxxxx` addresses for the DMA
  channels (`$02000010`..`$0200415C`), interrupt registers (`$02007000/$02007800`), SCR1/SCR2
  (`$0200C000/$0200D000`), KMS (`$0200E000`), GPIO (`$02012000`, cubes only) and the Bt463
  (`$0201C000`, never the alias). On the non-Turbo boards the alias goes through the BMAP; on a
  Turbo it must simply decode as the same register (Previous `ioMemTabTurbo.c` masks bit 20 away).
  **The core must decode `$02100000..$0211FFFF` as a mirror of `$02000000..$0201FFFF`**; the TMC
  (`$02200000`) and NCC (`$02210000`) windows are separate.
* MMU: `mmu_transparent_setup` loc_01000c68 makes the whole 4 GB supervisor-accessible and
  cacheable write-through (`itt1/dtt1 = $00FFC000`) except the 16 MB at `$02000000` which is
  non-cacheable/serialized (`itt0/dtt0 = $0200C040`). `tc = $C000` (MMU on, 8 KB pages). VRAM
  (`$0C000000`) is therefore *cacheable*; the video code brackets every screen write with
  `cpusha` (`vid_unlock` sub_0100b2f4 -> sub_010040a8). Reads from ROM, DRAM and VRAM may arrive
  as 16-byte line fills; the core must support burst (line) reads on all three.
* CACR is `$8000` (I-cache only) for almost the whole ROM; the memory pattern tests briefly use
  `$80008000` (sub_010040ac). `cinva`/`cpusha` are used freely.
* ROM is linked at `$01000000` and must also appear at `$00000000` at reset (header SSP
  `$04000400`, PC `$0100001E`). Stack, mg and vectors are in DRAM bank 0 from step 9 of the reset
  sequence (see 0.3): **mg = `$04000800`, vbr = `$04000C00`** initially (`reset_mg_in_dram`
  sub_01000514), later relocated to the top of the highest populated bank (`mon_init` step 10).

### 0.3 Order of hardware events from reset to the `NeXT>` prompt (Turbo Color)

| # | routine | hardware action (in order) |
|---|---|---|
| 1 | `reset_entry` $0100001e | `move.l #0,$020C0008` (BMAP) -> **must bus-error** (vector via the 8-entry table dat_010145b0) |
| 2 | `reset_probe_ncc` $01000092 | `move.l #0,$02210000` (NCC) -> **should bus-error** (no NCC on TC) |
| 3 | `reset_machine_dispatch` $010000b0 | read SCR1 `$0200C000`; if type nibble == 4 re-read from TMC `$02200000`; type 5 -> `loc_010002a6` |
| 4 | `mmu_transparent_setup` loc_01000c68 | `cpusha`, tc/itt/dtt as in 0.2, `pflusha` |
| 5 | `tmc_reset_config` sub_010002b4 | cacr=`$8000`; **TMC ctrl `$02200010`** (section 2); `$02208008 = 0`, `$02208018 = 0` (ADB INTMASK/CONFIG); read SCR2 long; if bit 12 clear write `$02200088 = $165A10D0`, `$0220008C = $10412270` |
| 6 | loc_010003cc / loc_0100418e | `$02007800 = 0`; CRC-32 over the ROM with SCR2 bit 0 (LED) set during the check; mismatch -> `led_blink_loop` (1 or 2 blinks, halt) |
| 7 | `reset_pick_stack` $0100041e -> `mem_dram_probe` loc_01003dfc | probe banks `$04000000, $06000000, $08000000, $0A000000` (section 3.2); none -> 5 blinks, halt |
| 8 | `reset_mg_in_dram` sub_01000514 | mg = bank+`$800`, stack below it, vbr = bank+`$C00`; `sub_01003a9c(0)` = **full 2 MB VRAM test** at `$0C000000` (section 3.4) **before any exception vector exists** (a bus error here is fatal) |
| 9 | `reset_install_vectors` loc_01000556 | `nvram_check_or_rtc_ramtest` sub_01005cd2: NVRAM read through the RTC bit-bang (section 12); all 256 vectors installed |
| 10 | `vid_console_init` sub_0100ac8a | `mg_init_machine`; **`adb_probe_kbd_alt_video` sub_0100c626: ADB bus reset with a spin-wait on ADB INTSTATUS bit 3, then TALK addr 2 reg 3** (section 5); display driver probe (SCR2 byte 2 bit 4), `vid_init_color_1120x832`, **Bt463 programming** (section 4), screen cleared to dark grey, `delay_us(750000)` (event counter), `vid_enable_display`: NVRAM brightness (written back if < $14), palette, **`$02200080 = $04000000`** |
| 11 | `mon_show_test_panel` sub_01000e2e | if POT & `$11`: panel graphics into VRAM |
| 12 | `exc_dispatch` sub_010018d4 vector `$700` -> `mon_init` sub_01000ec6 | pointers to `$02007000/$02007800`; `mem_config_test_t` sub_0100361a (bank sizing + parity probe with TMC ctrl bit 10 and NMI vector, section 3.3); optional `mem_test_all_t`; banner (SCR1 cpu/mem speed fields); NVRAM write-back if SIMM word changed; mg relocation; **`adb_init` sub_0100c1b4** (section 5); POST if POT_ON (section 0.4) |
| 13 | `exc_dispatch` loc_01001958 | boot panel; `kms_power_key_check` sub_0100a1a8 reads `$02007000` bit 2 |
| 14 | `mon_reenter_704` -> `exc_dispatch` vector `$704` loc_010019d8 | `$02007800 = 0`; `scc_init` sub_01008964 (section 11); `$02114020 = $02`; ESP command `$02114003 = $03` (SCSI bus reset); `SCR2 &= $7FFFFFFF` (clear DSP_RESET); `sub_010083d4` RTC reg `$30`/`$32`; **`$02200080 = $05000000`**; `vid`/console selection `sub_0100b04e`, `sub_0100b012`; `kms_console_init` sub_010098a4 (section 6); `$02106006 = $80` (Ethernet reset); `$02106004 &= ~4`; `boot_cmd` sub_0100610c |
| 15 | `boot_cmd` sub_0100610c | mask `\|= $2000`, vector `$6C` = `boot_l3_isr_entry`, **`$02200080 = $06000000`**, `sr = $2200` while the device opens; device open/load (SCSI: section 9; Ethernet: section 8; floppy: section 10) |
| 16 | on failure | `mon_command_loop` loc_01001dd8 prints `NeXT>`; keyboard via KMS (section 6) |

### 0.4 POST (only when NVRAM POT_ON, byte 14 bit 0) — `post_run_all` sub_01005a46

Order: FPU (`$4x`), SCC loopback (`$5x`, section 11), SCSI FIFO (`$6x`, section 9.5), Ethernet
loopback (`$7x`, section 8.5), ECC/MO (`$8x`, **cubes only, skipped on TC**), RTC (`$91`), timer
(`$C2/$C3`, section 13), event counter (`$Dx`, section 13), sound out (`$Ex`, only with
TEST_MONITOR_POT, section 6.4), extended SCSI (`$64..$68`, only with EXTENDED_POT). Errors are
stored in NVRAM bytes 15/16 and shown as "System test failed. Error code %x". POST is *not*
required to reach the prompt when POT_ON is clear; the ROM default NVRAM (built when the checksum
is bad, `mg_init_machine`) sets POT = `$11` (POT_ON | TEST_DRAM), so a core with empty NVRAM will
run the DRAM test and the POST on first boot.

---

## 1. System control registers and interrupts

### 1.1 SCR1 — `$0200C000` (legacy) and the TMC copy `$02200000`

| field (bits) | TC value expected | used by |
|---|---|---|
| 31:28 slot id | `$F` (station; ROM computes `mg_sid = SCR1 >> 28` arithmetic and then clears it for types 4..7) | `reset_mg_in_dram`, sub_01000d96 |
| 15:12 machine type | **5** | `reset_machine_dispatch` $010000b0 |
| 11:8 board/cpu rev | any; stored in `mg+$3A9` from `$0200C002` or `$02200002` (byte 2) | `mg_init_machine` $01000cee/$01000d04 |
| 7:6 video mem speed | don't care | |
| 5:4 memory speed | 0..3 -> banner "memory %d nS" via table dat_01014af4 [60,70,80,100]; also selects the TMC control value (section 2.1) | `mon_init` step 6 |
| 2:0 cpu speed | **7 = 33 MHz** (table sub_01014ae8 [40,50,66,80,16,20,25,33]); selects the TMC control value | `tmc_reset_config`, `mon_init` |
| other bits | Previous sets them to 1 (`TURBOSCR_FMASK = $0FFF0F08`); the ROM does not test them | |

Rule for the two copies (`reset_machine_dispatch` $010000b0, `mg_init_machine` $01000cee,
`mon_param_sysreg` sub_0100274e): the ROM reads `$0200C000` first; **only if the type nibble
reads 4** does it re-read from `$02200000` and use that value. Previous models the Turbo this way
(`$0200C000` = `$F0004000`, TMC SCR1 = `$FFFF5FDF` for a Turbo Color with 33 MHz / 70 ns). Either
"legacy reads 5" or "legacy reads 4 and TMC reads 5" works; the Previous scheme is recommended
because the `s scr1` monitor command then edits the TMC copy. Reads are longs at +0 and bytes at +2.

### 1.2 SCR2 — `$0200D000` (32-bit, byte layout per Previous sysReg.c)

Accessed both as a long (`ori.l/andi.l` RMW, `move.l`) and as single bytes (`btst.b #4,$0200D002`).
The core must support byte and long access with identical bit positions.

| byte:bit (long bit) | name | ROM use on TC | routine |
|---|---|---|---|
| 3:0 (0) | SCR2_LED | set/cleared around CRC, DRAM probe, VRAM probe, memory tests; blink codes on fatal errors | loc_0100418e, loc_01003ca4, `led_on/off` sub_010040c4/d6, `led_blink_loop` loc_010040ec, `mon_led_blink` sub_010025d4 |
| 3:7 (7) | SCR2_ROM ("local only") | **other**: set (non-Turbo cubes) / cleared (Turbo cubes) in the NeXTbus scan of `vid_console_init` ($0100ad1x) and by `dac_init_bt463` for type 3 only. Not touched on TC. Previous resets it to 1 on Turbo. | sub_0100ac8a, sub_0100bc78 |
| 2:0 (8) | SCR2_RTCE | RTC chip enable | `rtc_read_reg` sub_010087cc/e8, `rtc_write_reg` sub_010086e8 (section 12) |
| 2:1 (9) | SCR2_RTCLK | RTC clock | same |
| 2:2 (10) | SCR2_RTDATA | RTC data (driven by ROM for address/write bits, sampled for read bits) | same |
| 2:3 (11) | (unnamed in Previous) | **other**: `ori.l #$800` in the BMAP setup sub_01000062 and the cube-030 path | not TC |
| 2:4 (12) | "video mode 25 MHz" (Previous comment; reset value 1 on Turbo) | **TC: read only.** (a) `tmc_reset_config` $0100036e: `andi.l #$1000` on the long -> if **set, the TMC video timing write is skipped**; if clear `$165A10D0/$10412270` are written. (b) `vid_probe_color_1120` sub_0100b994 / sub_0100b9a8: set -> driver 0 (**1120x832**), clear -> driver 1 (832x624). (c) `adb_probe_kbd_alt_video` sub_0100c626: set + ADB keyboard -> alternate timing. The 832x624 timing values are exactly display 208 (x4 = 832) by 624, so (a) and (b) are consistent: **present bit 4 = 1; the ROM then never programs the TMC timing (the TMC power-on default must already be 1120x832)** unless an ADB keyboard is reported. | see cited routines |
| 2:7 (15) | SCR2_TIMERIPL7 | **other**: cleared by `post_timer_test` only when `$139`. Not touched on TC. | $0100534e |
| 1:7 (23) | SCR2_DSP_TXD_EN | never written by the ROM | |
| 0:7 (31) | SCR2_DSP_RESET | **cleared** (`andi.l #$7FFFFFFF`) once at boot | `exc_dispatch` $704 path $01001a16 |
| 0:0..6 | DSP mode / soft ints | never written | |

The `s scr2` monitor command (table `$0101485C`, Turbo bit names) can write the whole long.

### 1.3 Interrupt status `$02007000` (read) and mask `$02007800` (write) — 32-bit

Bit names from Previous `sysReg.h`; mask bit set = interrupt enabled. Levels: bits 31:30 IPL7,
29:18 IPL6, 17:15 IPL5, 14 IPL4, 13:2 IPL3, 1 IPL2, 0 IPL1.

Mask register writes (complete list, from `grep $1a0(` / `02007800`):

| value | where | TC? | purpose |
|---|---|---|---|
| `= 0` | loc_010003cc (reset), `exc_dispatch` $704 $010019d8 | TC | all off |
| `\|= $00002000` (INT_DISK / C16VIDEO, bit 13) | `boot_cmd` $010064b6 (style 2) | TC | TMC frame interrupt for the boot animation (level 3) |
| `\|= $00000020` / `$00002000` (video DMA) | `boot_cmd` $0100643a | other (types 0..2) | |
| `\|= $00002000` | `boot_cmd` $01006472 | other (type 3) | |
| `\|= $08000000` (INT_EN_RX_DMA, bit 27) | `enet_init` $010090b2 | TC | Ethernet receive DMA, level 6, vector `$78` |
| `= $20000000` (INT_TIMER, bit 29), then restored | `post_timer_test` $010053d8/$010053e6/$0100542e | TC (POST) | hardclock, level 6, vector `$78` |
| `= $00800000` (INT_SND_OUT_DMA, bit 23), then restored | `post_snd_out_test` $01005820/$010059d8 | TC (POST, TEST_MONITOR_POT) | sound-out DMA, level 6, vector `$78` |

Status bits polled or read (complete list, from `grep $19c(` / `02007000`):

| bit | name | where | TC? | what the ROM does |
|---|---|---|---|---|
| 31 | INT_NMI | `exc_dispatch` $7C path $01001c72 | TC | if set (or TMC NMI reg bit 0): `mon_clear_nmi` sub_01009fde, then `mon_init(reinit=1)` -> monitor |
| 30 | INT_PFAIL (Turbo: parity) | `exc_dispatch` $01001cc6 | TC | prints "parity error: status/address/data" from TMC `$0220000C/$02200008/$02200004`, writes `$02200004 = 0` twice |
| 12 | INT_SCSI | `scsi_run_cmd` sub_0100db8e $0100dba2 (polled every 10 ms), `boot_l3_isr` $0100670a | TC | calls `scsi_intr`. Must reflect the ESP interrupt line (ESP int status not yet read). |
| 7 | INT_PHONE (floppy) | `fd_wait_intr` sub_01011b6c $01011b82 | TC | polled; 82077 IRQ line |
| 2 | INT_POWER | `kms_power_key_check` sub_0100a1a8 ($0100a1be/$0100a23a/$0100a278), `rtc_power_int_handler` sub_010082ca $01008368, `kms_console_init` $01009958 | TC | power button; then RTC reg `$30` is read to confirm. **Must read 0 normally**, otherwise the ROM asks "really power down?" |
| 13 | INT_DISK / C16VIDEO | `boot_l3_isr` $010067ea | TC | TMC frame interrupt pending -> ack/step animation (section 2.3) |

Vectored interrupts actually taken by the ROM: level 3 autovector `$6C` (boot animation, SCSI
hook), level 6 autovector `$78` (Ethernet RX DMA in `enet_init`; hardclock and sound-out only in
POST), level 7 autovector `$7C` (NMI, parity). All other 253 vectors go to `exc_common_entry`
loc_010005ae and print "Exception #%d".

---

## 2. TMC (Turbo Memory Controller) — `$02200000` window

All accesses are 32-bit longs (`move.l`, `ori.l`, `andi.l`, and `move.l (a1),(a1)` style RMW).

### 2.1 Control register `$02200010`

Written once at reset by `tmc_reset_config` sub_010002b4 (verified against the listing):

```
d0 = $04008380
if cpu_speed(SCR1 2:0) == 7:  d0 |= $08000000 | $01F40000 | 3;  d0 |= (mem_speed(SCR1 5:4) == 1) ? 8 : $C
else:                          if mem_speed == 3: d0 |= $08000000;  d0 |= $01770000
```

| SCR1 cpu / mem | value written | note |
|---|---|---|
| 7 / 0,2,3 | **`$0DF4838F`** | 33 MHz |
| 7 / 1 | **`$0DF4838B`** | 33 MHz, 70 ns (Previous default TMC SCR1 `$FFFF5FDF` has mem field 1 -> this value) |
| <7 / 3 | `$0D778380` | |
| <7 / 0..2 | `$05778380` | |
| (mono types 4,6,8,$A only) | then `ctrl = (ctrl & ~3) \| 2` | $010003ae; **not TC** |

Later writes (all RMW on the whole long):

| bit(s) | meaning | writes | routine | TC? |
|---|---|---|---|---|
| 10 (`$400`) | parity checking enable (Previous `tmc_ctrl_write2` bit 2 of byte 2) | `\|= $400` before / `&= ~$400` after each bank parity probe; NMI handler `mem_nmi_parity_vec_t` $01003fa2 clears it; `tmc_parity_init_range` sub_01004072 toggles it per long of bank 0 page 0 and finally leaves it **set** when all SIMMs are parity and NVRAM byte 17 bit 2 is set | `mem_config_test_t` sub_0100361a ($01003ee8, $01003f04..$01003f10, $01003fac..$01003fb8, $0100407c..$0100409a) | TC |
| 3 (`$8`) | "parity memory present" (interpretation; not modelled by Previous) | `&= ~8` when any present bank has non-parity SIMMs (**normal case**) | sub_0100361a $010039a4 | TC |
| 9:8 | ROM-local / local-only | `&= $FCFF` (low word) | `vid_console_init` $0100ac9e.. cube branch | **other** (cubes) |
| 1:0 | ? (2 = mono) | see above | tmc_reset_config | other |
| 24..27, 15..23, 7 | unknown timing/config; the ROM writes them as above and never reads them back except for the RMWs | | | |

Reads: `$02200010` is read back for every RMW; the value must hold what was written (the ROM
does `and`/`or` on the read value).

### 2.2 Parity error registers `$02200004` (data), `$02200008` (address), `$0220000C` (status)

Previous marks them unimplemented. ROM use (TC): read as longs in the level-7 handler
(`exc_dispatch` $01001ce0..$01001cf0) and printed; **`$02200004` written 0** (twice) to clear the
latch there and after `tmc_parity_init_range` ($01003966), and once in the parity-probe NMI vector
`mem_nmi_parity_vec_t` $01003fa2 (`move.l #0,$02200004`). Minimum: writable, reads 0, never raises
NMI/INT_PFAIL unless the core implements parity. Reads of `$02200000..$0220000C` must not bus-error.

### 2.3 NMI register `$02200020`

| access | routine | TC? |
|---|---|---|
| read, bit 0 tested | `exc_dispatch` $7C path $01001c8a ("NMI pending?") | TC |
| `clr.l` (write 0) when bit 0 set | `mon_clear_nmi` sub_01009fde $01009ffc | TC |
| `\|= 1` (RMW long) | `adb_kbd_raise_nmi` sub_0100c5a6 $0100c5c6 (Cmd+Alt+` on an ADB keyboard) | TC only with ADB keyboard |

Semantics per Previous `tmc_nmi_write3`: writing bit 0 = 1 asserts INT_NMI (status bit 31,
level 7); writing 0 releases it. Reading returns the bit.

### 2.4 Video interrupt / enable register `$02200080`

Written as a long with the value in byte 0 (bits 31:24). Bits (Previous `tmc.c`): `$01<<24`
INTERRUPT (pending; write 1 = clear), `$02<<24` INT_MASK (frame interrupt enabled -> status
bit 13), `$04<<24` ENABLE (video output on).

| value | where | TC? | meaning |
|---|---|---|---|
| `$04000000` | `vid_color_enable` sub_0100be7c $0100beaa (750 ms after screen clear); `vid2_enable` sub_0100c14e $0100c17a (mono driver, not TC) | TC | video on, interrupt off |
| `$05000000` | `exc_dispatch` $704 $01001a30; `boot_l3_isr` $010067f0 (ack); `boot_cmd` $010066b2 (disable after load when no kernel entry) | TC | video on, clear pending, mask off |
| `$06000000` | `boot_cmd` $010064be (arm); `boot_l3_isr` $010067fc (re-arm after one animation step) | TC | video on, frame interrupt enabled |

Required behaviour: while INT_MASK is set, raise status bit 13 (level 3) once per frame;
writing INTERRUPT=1 clears the pending bit; the animation re-arms only after servicing, so at most
one interrupt per frame. Reading byte 0 must return the last written value (only Previous reads
it; the ROM never reads it).

### 2.5 Video timing `$02200088` (horizontal) and `$0220008C` (vertical)

Field layout (Previous `tmc.c`): fporch [31:25], sync [24:19], bporch [18:12], display [11:0].

| register | value | fporch | sync | bporch | display | written by | when |
|---|---|---|---|---|---|---|---|
| H | `$165A10D0` | 11 | 11 | 33 | 208 | `tmc_reset_config` $01000380 | colour types, **only if SCR2 byte 2 bit 4 = 0** -> 832x624 mode (208 x 4 = 832) |
| V | `$10412270` | 8 | 8 | 18 | 624 | $0100038a | same |
| H | `$6302F118` | 49 | 32 | 47 | 280 (x4 = 1120) | $0100039a | mono types (4,6,8,$A) |
| V | `$00438340` | 0 | 8 | 56 | 832 | $010003a4 | mono types |
| H | `$29044118` | 20 | 32 | 68 | 280 | `tmc_alt_timing_color` sub_0100c68a | colour types 5,7,9 **with an ADB keyboard at address 2 and SCR2 byte 2 bit 4 = 1** |
| V | `$021A0340` | 1 | 3 | 32 | 832 | same | same |
| H | `$5B02B118` | 45 | 32 | 43 | 280 | `tmc_alt_timing_mono` sub_0100c6a4 | mono types with ADB keyboard |
| V | `$0041C340` | 0 | 8 | 28 | 832 | same | same |
| H | `$31048118` | 24 | 32 | 72 | 280 | Previous reset default (`HFPORCH\|HSYNC\|HBPORCH\|HDISCNT`, tmc.c 206-209) | what the TMC must power up with (408 units/line, same total as the mono ROM value) |
| V | `$10430340` | 8 | 8 | 48 | 832 | Previous reset default | 896 lines/frame |

Unit: 4 pixels horizontally (mono: 408 units x 4 = 1632 px/line at 100 MHz -> 61.3 kHz, 896
lines -> 68.4 Hz), lines vertically. **For a Turbo Color presenting SCR2 byte 2 bit 4 = 1 and no
ADB keyboard the ROM never writes these registers**; the core's reset default must be the
1120x832 timing. (The earlier notes flagged the 208/624 values as "unit unknown"; they are the
832x624 mode, consistent with the driver selection in section 4.3.)

---

## 3. Memory

### 3.1 Layout (Turbo)

| item | value | evidence |
|---|---|---|
| DRAM bank bases | `$04000000, $06000000, $08000000, $0A000000` (stride `$02000000` = 32 MB, computed as `$8000000 >> 2` when `mg+$194 != $139`) | 8 places, e.g. `mem_build_regions` sub_010022d6, `mem_config_test_t` sub_0100361a, `reset_pick_stack` $0100041e |
| bank end | `$0C000000` | $0100041e |
| bank size by SIMM code (`dat_01014aa4`) | code&3: 0 -> 0, 1 -> 32 MB, 2 -> 8 MB, 3 -> 2 MB (code bit 3 = parity). Names `dat_01014a24`: "32MB of page mode", "8MB of page mode", "2MB of page mode", "... parity page mode"; codes 4/8/12 "illegal" | `mon_init`, `mon_cmd_m` |
| mg_simm[4] `mg+0..3` | one code per bank; also packed into NVRAM bytes 10/11 (3 bits per bank at 3i, parity bit at 9+i) | `mon_init` step 8 |
| mg_region[4] `mg+$C8` | {base, **end address**} per populated bank | sub_010022d6 |
| VRAM | `$0C000000`, 2 MB (`$200000`) tested; framebuffer 1120x832x16 bpp = `$1C7000` bytes; ROM assumes 936 lines x 2240 bytes usable (`$1FFD00`) | `vid_vram_test` sub_01003a9c, `vid_init_color_1120x832` sub_0100b9e6 |
| initial stack / mg / vectors | first bank passing the probe: mg = bank+`$800`, vectors bank+`$C00`..`$1000`, early message buffer bank+`$1000..$1400`, allocation area from bank+`$4000` | sub_01000514, `mon_init` loc_010011b8 |
| final layout | top of highest populated bank: [alloc area `$1030`][vectors `$400`][mg `$48E`]; monitor stack grows down below the vectors; `mg_region[last].end` lowered to the page below | `mon_init` step 10 |
| DMA bounce buffer | page-aligned address 64 KB below the top of the highest populated bank | `dma_init` sub_0100e8cc |
| Ethernet buffers | RX buffer k = top - `$6000` - k*`$2000` (k = 0..31), TX = top - `$6000` - 32*`$2000` | `enet_init` sub_01008e5e |
| fixed DRAM addresses | `$04002000` sound POST buffer (8 KB); `$04100000` panel save buffer / font scratch | `post_snd_out_test`, `vid_draw_panel` sub_01009a2c |

### 3.2 Pre-stack DRAM probe — `mem_dram_probe` loc_01003dfc (TC, colour types)

Per bank base a0 (`$04000000` first): write `$55555555` at +0, +4 and `$AAAAAAAA` at +8, +$C,
read back (+8 compared twice, +$C never: ROM bug); then fill `[a0, a0+$2000)` with `$DB6DB6DB`,
verify, its complement, verify, incrementing longs, verify (`mem_dram_probe_fill` loc_01003dcc).
First passing bank becomes the stack; failure advances by the stride; none -> LED code 5.
No caches (cacr `$8000`).

### 3.3 Bank sizing — `mem_config_test_t` sub_0100361a (TC; called from `mon_init`)

Pass 1 per bank i (base `$04000000 + i*$2000000`):
1. `mem_bank_absent_t` sub_0100353e: `$55555555` at +0, `$AAAAAAAA` at +4,+8,+$C, `cpusha`,
   read back; mismatch -> bank absent (`mg_simm[i] = 0`).
2. `mem_bank_size_t` sub_01003598 on `base` and on `base+4` (the two SIMMs of the pair,
   interleaved on address bit 2): write `$12345678` at addr, `$89ABCDEF` at addr+`$800000`,
   `$ABCDEF01` at addr+`$200000`, `cpusha`, read addr: `$89ABCDEF` -> code 2 (8 MB bank, aliases
   at 8 MB); `$12345678` -> code 1 (32 MB, no alias); `$ABCDEF01` -> code 3 (2 MB, aliases at
   2 MB); other -> error. **The core's DRAM decode must alias exactly this way** (address bit 23
   ignored for an 8 MB bank, bits 21+ for a 2 MB bank, no aliasing inside 32 MB).
3. both halves must give the same code ("Bank %d has mixed size SIMMs").

Pass 2 per present bank (parity probe): vbr := `mem_vectors_t` `$01003ff2` (32 entries, entry 31
= level-7 autovector = `mem_nmi_parity_vec_t` $01003fa2: `$02200004 = 0`, `TMC ctrl &= ~$400`,
`rte`); `TMC ctrl |= $400`; write 4 longs of 0, `cpusha`, read +0/+4; 4 longs of `$01010101`,
read; 32 zero bytes then bytes at +3,+7,+$A,+$E,+$11,+$15,+$18,+$1C set to 1, read all 32; `d0 =
ctrl & $400`; `ctrl &= ~$400`. "Parity SIMMs present" iff no NMI fired. If present: bank
`bzero`ed (skipping the stack page), `mg_simm[i] |= 8`. A core without parity must **never raise
the NMI here** (result: non-parity SIMMs -> `TMC ctrl &= ~8`).
If every bank has parity and NVRAM byte 17 bit 2 (USE_PARITY_MEM): `mg+$3AE |= $80000000`,
`tmc_parity_init_range($04000000, $04002000)`, banks re-zeroed, `$02200004 = 0` x2.

Stack-page rule: any test whose bank base equals `(sp - 4) & ~$1FFF` skips the first `$2000`
bytes of that bank.

`mem_test_all_t` sub_010039bc (only with TEST_DRAM_POT, `$10`): `mem_pattern_test_t`
sub_01003456 with caches on (`$80008000`): triple pattern `$DB6DB6DB,0,0` (the "rotate" is
`and.l`, so later passes are all-zero), then a byte-lane test (bytes 1..8 at base). Failures print
"Memory error at location" and the socket number.

### 3.4 VRAM test — `vid_vram_test` sub_01003a9c (TC, at reset step 8 and by `mon_init`)

Base `$0C000000` (`$2C000000` only when `$139`). 2 MB (`$200000` bytes) of longs: fill
`$55505550`, verify; fill `$AAA0AAA0`, verify; address pattern long i = `($00100020 +
i*$00200020) & $FFF0FFF0`, verify. **All compares are masked with `$FFF0FFF0`: the low nibble
of each 16-bit word is don't-care** (VRAM may be 12 bits wide per pixel; the ROM never depends on
the low nibble). Failure: `mon_led_blink(3)` x4 and "VRAM failure at 0x%x ..." (not fatal), text
also left at DRAM bank+`$1000` for `mon_init` to report. Mono machines instead run
`vid_vram_probe` loc_01003ca4 (256 KB, `$AAAAAAAA/$55555555/incrementing`) — not TC.

### 3.5 Pixel format (TC)

One big-endian 16-bit word per pixel, `RRRR GGGG BBBB xxxx`; two pixels per long, left pixel in
the high word; rowbytes 2240 (`$460*2`); white `$FFF0`, light grey `$AAA0`, dark grey `$5550`,
black `$0000` (`vid_init_color_1120x832` sub_0100b9e6; text renderer `vid_putc` loc_0100a71a,
`vid_span_16bpp` sub_010042xx). The screen is cleared to dark grey (`vid_clear_screen`
sub_0100a5fa fills `mg+$344`).

---

## 4. Video

### 4.1 Display driver table `$0101B080` (3 entries x 7 methods)

| method | 0: colour 1120x832 (**TC**) | 1: colour 832x624 | 2: mono 1120x832 |
|---|---|---|---|
| +0 probe | sub_0100b972: types 5,7,9,$B -> 1 iff SCR2 byte 2 bit 4 set (type 3 -> 1) | sub_0100b9a8: colour Turbo types and bit 4 clear | sub_0100bf72: 1 for types 0,1,2,4,6,8,$A |
| +4 init | sub_0100b9e6 | sub_0100bb8e | sub_0100bf9e (2 bpp, `$0C000000`, 280 bytes/line on Turbo mono) |
| +8 DAC setup | `dac_init_bt463` sub_0100bc78 | same | nop |
| +$C enable | `vid_color_enable` sub_0100be7c | same | `vid2_enable` sub_0100c14e (brightness reg `$02110000`, `$02200080 = $04000000`) |
| +$10 enter | nop | nop | nop |
| +$14 exit | `cpusha` sub_010040a8 | same | nop |
| +$18 brightness | `dac_set_brightness_palette` sub_0100bebe | same | `vid2_set_brightness` sub_0100c18a (`$02110000`) |

`vid_find_driver` sub_0100b7c0 tries 0, 1, 2 in that order. **On TC only driver 0 (or 1) is ever
used; the brightness register `$02110000` is never written** (brightness = palette rescale).

Geometry stored by sub_0100b9e6 (Turbo values): `mg+$324` = 2 pixels/long, `$328` = 2240,
`$32C` = 1120, `$330` = 1120, `$334` = 832, `$368/$364` = `$0C000000`, `$36C` = `$1C7000`,
`$374/$370` = `$0C1C7000` (free VRAM start), `$378` = `$38D00`. The 832x624 driver: rowbytes
1664, size `$FD800`.

### 4.2 Bt463 RAMDAC at `$0201C000` (TC; type 3 uses `$02118100`)

Byte registers: +0 address low, +1 address high (4 bits), +2 control/window-type data
(auto-increment), +3 palette data (R, G, B bytes per entry, auto-increment) — Previous `ramdac.c`.

`dac_init_bt463` sub_0100bc78, writes in this order (each entry = addr low, addr high, then data
bytes to +2 or +3):

| step | address | data (+2) | meaning |
|---|---|---|---|
| 1 | `$201` | `$40` | CR0 |
| 2 | `$202` | `$00` | CR1 |
| 3 | `$203` | `$80` | CR2 |
| 4..7 | `$205..$208` | `$F0` each | read masks 0..3 (**only the high nibble of each 8-bit channel index is used** -> 16 palette entries per channel matter) |
| 8..11 | `$209..$20C` | `$00` each | blink masks 0..3 |
| 12 | `$300..$30F` | `$00, $01, $00` each (3 bytes to +2) | all 16 window types = `$000100` |
| 13 | `$000..$0FF` | 3 bytes to +3: v(i), v(i), v(i) | palette 0..255, grey |
| 14 | `$100..$1FF` | same values as 0..255 | second half mirrors the first |
| 15 | `$20C..$20F` | `$FF,$FF,$FF` each (to +3) | overlay/cursor colours white |

Palette formula (`dac_init_bt463`, `dac_set_brightness_palette` sub_0100bebe):
`d4 = brightness * 64 / 61` (brightness = NVRAM bits 19:14, 0..`$3D`);
`v(i) = min($FF, ((gamma[i] * d4) >> 6) + 8)`, `gamma` = the 256-byte table at `$01012000`
(`16*sqrt(i)`: 00 10 17 1C 20 24 ... FF). At maximum brightness (`$3D`): nibble `$F` -> `$FF`,
`$8` -> `$BD`, `$0` -> `$08`. A pixel nibble n selects palette entry `n<<4` of the corresponding
channel. The brightness keys (`kms_key_brightness` sub_0100a47c) rewrite entries 0..255 only.
The meaning of CR0/CR1/CR2 values is not verified against a data sheet (flagged in
`notes/0100a000.md`). The core needs: address auto-increment on +2/+3 writes, 3-byte palette
entries, and the read masks / window types can be stored and ignored (12-bit direct pixels
through a per-channel 16-entry LUT is the observable behaviour).

### 4.3 Resolution selection and video enable (TC)

1. SCR2 byte 2 bit 4 = 1 -> driver 0 (1120x832); = 0 -> driver 1 (832x624) (section 4.1).
2. `vid_console_init` sub_0100ac8a: `vid_driver_init` (bzero `mg+$324..$3A3`, init), `dac_init_bt463`,
   `vid_clear_screen` (dark grey), `delay_us(750000)`, `vid_enable_display` sub_0100b802: if NVRAM
   brightness < `$14` set it to `$14` and **write NVRAM**; `vid_color_enable` sub_0100be7c:
   palette from NVRAM brightness, **`$02200080 = $04000000`** (video on).
3. Stations skip the NeXTbus display scan (`mg+$3B6 = 1`).

### 4.4 Brightness

TC: palette only (4.2). NVRAM field bits 19:14, clamped 0..`$3D`, +-1 per key (`kms_key_brightness`
sub_0100a47c, keycodes 1 and `$19` through the KMS/ADB key tables). The mono driver writes
`brightness_lfsr_tab[level] | $40` (64-byte table at `$0101B0D4`, a 6-bit LFSR sequence) to
`$02110000` — **other** (mono machines).

### 4.5 Boot panel / animation (TC)

`boot_cmd` draws the panel image at (340,308) into VRAM and animates through the level-3 frame
interrupt (`boot_l3_isr` $0100670a, section 2.4). The text console uses the 8x12 font at
`$0101AC00`, cells at `mg+$150/$152` origin (11 rows / 20 cells), and copies pixels to/from the
DRAM save buffer `$04100000` for pop-up panels (`vid_draw_panel` sub_01009a2c).

---

## 5. ADB (TMC ADB window `$02208000`) — Turbo only, all accesses 32-bit `move.l`

Register offsets (Previous `adb.c`): INTSTATUS +00, INTMASK +08, SETINT +10, CONFIG +18, CTRL +20,
STATUS +28, CMD +30, COUNT +38, DATA0 +80, DATA1 +88. Only the low byte carries the bits:
INTSTATUS: REJECT 1, POLLSTOP 2, ACCESS 4, RESET 8; CTRL: EN_POLL 1, DIS_POLL 2, XMIT_CMD 4,
RESET_ADB 8, RESET_WD `$10`; STATUS: CONFLICT 1, REQUEST 2, TIMEOUT 4, DATAPEND 8, RESET `$10`,
ACCESS `$20`, POLL_EN `$40`, POLL_OV `$80`; CMD byte = `addr<<4 | cmd<<2 | reg` (cmd 0 reset,
1 flush, 2 listen, 3 talk); COUNT = bit count (bytes*8, read back `>> 3`); DATA0 = bytes 0..3
big-endian, DATA1 = bytes 4..7.

Protocol conventions (from `adb_reset_bus` sub_0100c458, `adb_send_cmd` sub_0100c482,
`adb_talk` sub_0100c4fa, `adb_listen` sub_0100c572, `adb_kbd_poll` sub_0100c398):

* Interrupt acknowledge = `move.l (INTSTATUS),(INTSTATUS)` (write back what was read) or writing
  the single bit (8 after reset, 4 after a command): **write-1-to-clear**.
* INTMASK is always 0 and SETINT never written: everything is polled.
* `CTRL = $10` (RESET_WD) is written after every poll (watchdog kick).

Command sequences in execution order on TC:

| # | routine (when) | sequence |
|---|---|---|
| A | `tmc_reset_config` (reset step 5) | `INTMASK = 0`, `CONFIG = 0` |
| B | `adb_probe_kbd_alt_video` sub_0100c626 (reset step 10, **before the display is initialised**) | `mg+$3BE = 2`; `adb_reset_bus(1)`: ack INTSTATUS, `CTRL = $08`, **spin until INTSTATUS bit 3 set**, `INTSTATUS = 8`; `delay_us(5000)`; `adb_talk(2, 3)`: `CMD = $2F` (addr 2 <<4, talk = 3<<2, reg 3), `COUNT = 0`, `CTRL = $04`, **spin until INTSTATUS bit 2 set**, `INTSTATUS = 4`, then if `STATUS & 8` (DATAPEND) read `COUNT>>3` bytes from DATA0/DATA1 else count = 0. If count != 0 and SCR2 byte 2 bit 4 set and type in 4..9: alternate TMC timing (section 2.5). |
| C | `adb_init` sub_0100c1b4 (`mon_init` step 11) | `CONFIG = 0`, `INTMASK = 0`; `adb_reset_bus(1)` as in B; for addr = 1..7: `adb_talk(addr, 3)` (`CMD = addr<<4 \| $0C \| 3` = `$1F, $2F, $3F, ... $7F`); a device exists when count != 0: addr 2 -> `adb_kbd_init`, addr 3 -> `adb_mouse_init`; finally one `adb_send_cmd(addr<<4 \| $0C, NULL, 0, nowait)` (talk reg 0, e.g. `$2C`) to the last device. |
| D | `adb_kbd_init` sub_0100c6c4 (keyboard found) | `adb_listen(2, 3, {?, 3}, 2)` (`CMD = $2B` = addr 2, listen = 2<<2, reg 3; DATA0 = buf, `COUNT = 16`, `CTRL = 4`, wait bit 2) -> handler 3; `adb_talk(2, 3)` (`$2F`); if reply byte 1 == 3: `adb_talk(2, 2)` (`$2E`, LED/modifier register); `adb_listen(2, 2, buf, 2)` (`$2A`) with caps LED from bit 5, `buf[1] \|= 5` |
| E | `adb_mouse_init` sub_0100d8a6 (mouse found) | talk reg 3; listen reg 3 `{?,3}`; talk reg 3; if handler 3: talk reg 1; if 8 bytes: three `listen(3, 1, buf, 8)` with `buf[0..1]` = `00 83`, `01 82`, `02 81` |
| F | `adb_kbd_poll` sub_0100c398 (every console read while `mg+$3E2` bit 0 = keyboard present) | ack INTSTATUS; read STATUS; `CTRL = $10`; if ACCESS int and DATAPEND: copy DATA0/1; if not ACCESS and STATUS bit 5: return; else `CMD = $2C` (addr 2 talk reg 0), `COUNT = 0`, `CTRL = 4` (no wait), `delay_us(8000)` |
| G | `adb_kbd_raise_nmi` sub_0100c5a6 (Cmd+Alt+`) | `adb_reset_bus(1)`, `$02200020 \|= 1`, delay 8 ms |

**Minimum behaviour if the core has no ADB devices** (the KMS keyboard is then used): after
`CTRL = $08` INTSTATUS must read with bit 3 set; after `CTRL = $04` INTSTATUS must read with bit 2
set; STATUS must read with bit 3 (DATAPEND) clear (COUNT then irrelevant, `mg+$3D2` stays 0);
bits written to INTSTATUS clear them. Without this the ROM spins forever in `adb_reset_bus`
**before the screen is even initialised**. `mg+$3E5` bit 0 (keyboard present) then stays 0 and
all console input goes through the KMS (section 6).

Key translation (only with an ADB keyboard): ADB-to-NeXT keycode table `$0101B134`, modifier
jump tables `$0101213C..$0101291C`; magic keys Cmd+Alt+`*` -> KMS reset word, Cmd+Alt+` -> NMI.

---

## 6. KMS (keyboard / mouse / sound controller) `$0200E000`

Registers (Previous `kms.c`): `$0200E000` sound status byte (bit 7 SNDOUT_DMA_ENABLE, bit 6
REQUEST, bit 5 UNDERRUN; long reads: bit 22 = KM data received, bit 21 = KM overrun);
`$0200E001` KM status/control (bit 6 KM_RECEIVED, bit 4 NMI_RECEIVED, bit 3 KMS_INT, bit 2
KMS_RECEIVED, bit 1 KMS_OVERRUN; writes of 1 clear); `$0200E002` TX status/control (bit 6 TX_DMA,
bit 4 TX_CPU busy, bit 1 KMS_ENABLE, bit 0 TX_LOOP); `$0200E003` command byte; `$0200E004`
command data long; `$0200E008` KM data long.

KM data long format (`kms_read_key` sub_0100a2ba, `kms_translate_key` sub_0100a3f2): byte 0:
bit 6 no-response, bit 5 user poll, bit 4 invalid/master, bits 3:0 device address (1 = mouse);
byte 2: bit 7 valid, bits 6:0 modifiers (0 ctrl, 1 L-shift, 2 R-shift, 3 L-cmd, 4 R-cmd, 5 L-alt,
6 R-alt); byte 3: bit 7 key-up, bits 6:0 NeXT keycode. Keymap table `$0101A978` (324 words).

### 6.1 Command primitives

* `kms_send_cmd` sub_0100a520 (cmd, data): if `mg+$170` bit 7 clear: `ori.b #2,$0200E002`
  (KMS_ENABLE) once; then `$0200E003 = cmd`, `$0200E004 = data`, `delay_us(100)`.
* `kms_send_cmd_wait` sub_0100a4da: same, then poll `$0200E001` bit 6 (KM_RECEIVED) up to 100000
  times; returns `$40000000` on timeout.
* POST variant `kms_send_cmd` sub_01005606: waits while `$0200E002` bit 4 (TX_CPU) is set, writes
  cmd/data, `delay_us(200)`.

### 6.2 Sequences (TC, in order)

| routine | commands |
|---|---|
| `kms_console_init` sub_010098a4 (first console output, $704 path) | `delay_us(150000)`; `kms_send_cmd_wait($C5, $EF000000)` (KMREG: set keyboard address / reset). **Timeout AND NVRAM byte 0 bit 3 (alt cons)** -> console to SCC A (`mg+$318 = mg+$31C = 1`), return; timeout alone is ignored. If POT_ON and `mg+$170` bit 9 clear: `kms_send_cmd_wait($C5, $30000)`, `delay_us(250000)`. Then `kms_send_cmd_wait($C5, 0)`, `kms_send_cmd($C6, $01FFFFF6)` (KMPOLL: device addresses 0,1, others F, poll speed 6), drain INT_POWER via `rtc_power_int_handler`. |
| `kms_read_key` sub_0100a2ba (polled console input) | loop: `kms_power_key_check`; `kms_send_cmd($C6, $01FFFFF6)`; read `$0200E000` long; if bit 22 set latch `$0200E008` -> `mg+$144`; if byte 0 bit 6 (no response) and not bit 4: `kms_send_cmd_wait($C5, $EF000000)`; device address 1 (mouse) -> ignored (`$100`); else translate. |
| `kms_poll_km_event` sub_0100a00e | reads `$0200E000`; bit 21 (overrun) -> `ori.b #$20,$0200E001` |
| `kms_send_reset` sub_01009860 (monitor reboot / Cmd+Alt+`*`) | `sr = $2700`; `$0200E002 \|= 1` (TX_LOOP); `kms_send_cmd($C6, $1000A825)` = KMS_MAGIC_RESET (**must reset the whole machine**); `kms_send_cmd($C6, 0)`; delay 10 ms |
| `mon_clear_nmi` sub_01009fde | `ori.b #$10,$0200E001` (ack NMI_RECEIVED); Turbo: if `$02200020` bit 0: `clr.l $02200020` |

Keyboard requirement for the prompt: after `$C6/$01FFFFF6` polls, key events appear in
`$0200E008` with `$0200E000` bit 22 set; the ROM re-issues the poll command on every read (no
interrupt). The mouse is never consumed.

### 6.3 Sound / KMS status bits

`$0200E000` byte: bit 7 SNDOUT_DMA_ENABLE (`&= $7F` / `\|= $80` in `post_snd_out_test`), bit 5
UNDERRUN (`bset #5` clears it, `snd_out_clear_underrun` sub_01004142). Commands `$07` sound out
off, `$0F` sound out on (44.1 kHz stereo 16-bit), `$C4` CTRLOUT = volume-chip bit-bang
(`kms_set_volume` sub_0100567e: data bit 25, clock bit 26, strobe bit 24, channel `$40`/`$80`,
base bit 27 = speaker disable (NVRAM byte 3 bit 3), bit 28 = lowpass (byte 3 bit 2)), `$C7`
analog sample (non-Turbo underrun path only).

### 6.4 Where sound is exercised on TC

* POST sound-out test (TEST_MONITOR_POT only): DMA channel `$02000040` (section 7), 8 KB buffer
  at `$04002000`, DMA_ENABLE must drop within ~250 ms.
* **The console BEL character** (`vid_putc` case sub_0100a704) calls `sub_01005758(1)` then
  `sub_01005758(0)` = the same sound-out routine (silence then tone). BEL is emitted by `con_gets`
  when the input buffer is full. Without sound DMA the test loop still terminates (8 underrun
  observations or the 200 ms timeout).

---

## 7. DMA (PC chip TDMA channels) — all CSR/pointer accesses are 32-bit

Channel register set: CSR at `$020000xx`, Next `$020040xx`, Limit `+4`, Start `+8`, Stop `+$C`
(same low byte as the CSR). Turbo also has "saved limit" `$02004050` (read only, Ethernet).

CSR write bits (Previous `dma.c`): `$00010000` SETENABLE, `$00020000` SETSUPDATE, `$00040000`
DEV2M (device->memory), `$00080000` CLRCOMPLETE, `$00100000` RESET, `$00200000` SETCOMPLETE
(Turbo; INITBUF on non-Turbo), `$00400000` FLUSH (Turbo), `$00800000` BUFRESET (Turbo). Read bits:
`$01000000` ENABLE, `$02000000` SUPDATE, `$08000000` COMPLETE, `$10000000` BUSEXC.

Channels used on TC:

| channel | CSR | Next/Limit/Start/Stop | user |
|---|---|---|---|
| SCSI (shared with floppy) | `$02000010` | `$02004010/14/18/1C` | `scsi_*`, `fc_*` |
| Ethernet TX | `$02000110` | `$02004110/14/18/1C` | `enet_write`, `enet_close` |
| Ethernet RX | `$02000150` | `$02004150/54/58/5C` (+ saved limit `$02004050`) | `enet_init`, `enet_rx_dma_start`, `enet_rx_int` |
| Sound out | `$02000040` | `$02004040/44/48/4C` | POST / BEL only |
| Sound in | `$020000C0` (as coded; Previous has the sound-in channel at `$02000080`) | | `post_snd_in_dma_reset` sub_01004872 — **unreferenced**, ignore |
| MO disk | `$02000050` | `$02004050..` | optical driver only (section 14) |
| Video | `$02000180` / limit `$02004184` | | **other** (types 0..2) |

CSR values written, in order, by the generic helpers (used by SCSI, floppy, MO):

| routine | writes |
|---|---|
| `dma_init` sub_0100e8cc | `CSR = $00100000` (RESET) |
| `dma_start` sub_0100eacc | 1. `CSR = dir \| $00100000 \| $00800000` (RESET \| BUFRESET; non-Turbo uses `$00200000` INITBUF) 2. `Next = chain[0].start`, `Limit = chain[0].limit` 3. if a second descriptor: `Start = chain[1].start`, `Stop = chain[1].limit`, `CSR = dir \| $00030000` (SETENABLE \| SETSUPDATE); else `CSR = dir \| $00010000` (SETENABLE). `dir` = 0 (mem->dev) or `$00040000` (dev->mem). All descriptor starts must be 16-byte aligned (ROM panics otherwise). |
| `dma_stop` sub_0100eb90 | read `CSR & $1B000000`; `CSR = $00100000`; read `Next` (= where the transfer stopped) |
| `dma_cleanup` sub_0100ea5a | `dma_stop`, then copies the scratch tail / bounce buffer back |
| `dma_bytes_moved` sub_01011ae8 (floppy) | reads `Next` (`$02004010`) and walks the chain |
| `enet_close` sub_010095b2, `post_*` | `CSR = $00100000` |
| POST resets | `$00900000` (RESET \| BUFRESET) everywhere (`notes/01004000.md` lists 9 sites) |
| `enet_write` | `$00980000` (BUFRESET \| RESET \| CLRCOMPLETE) then `0`, later `$00010000` |
| `enet_init` | `$00940000` (BUFRESET \| RESET \| DEV2M) |
| `enet_rx_dma_start` sub_010096be | `$000F0000` (SETENABLE \| SETSUPDATE \| DEV2M \| CLRCOMPLETE) on first start, `$00070000` on restart, `$000E0000` otherwise |

Descriptor layout (`dma_setup_chain` sub_0100e94a): `$1C` bytes: +0 next descriptor (0 = last),
+4 start, +8 limit, +$C 0, +$10 0. Chains always end on 16-byte-aligned limits; transfers to the
device are copied into the bounce buffer first; the last partial 16-byte burst of a
device->memory transfer lands in a 32-byte scratch buffer inside the softc and is copied back
(`dma_cleanup`); transfers <= 127 bytes go entirely through the scratch buffer. Bounce buffer:
page-aligned, 64 KB below the top of the highest bank (section 3.1).

Completion detection: SCSI — ESP interrupt then `dma_stop`; floppy — 82077 interrupt then
`dma_bytes_moved` from `Next`; Ethernet RX — level-6 interrupt (INT_EN_RX_DMA); Ethernet TX — TX
status READY bit; sound POST — `CSR` bit 24 (ENABLE) dropping and `Next` moving. `SUPDATE`
(single update) with Start/Stop is used for two-descriptor chains: after the first descriptor
completes the channel must continue with Start/Stop.

---

## 8. Ethernet AT&T 7213 — `$02106000` (alias of `$02006000`)

Registers (Previous `ethernet.c`): +0 TX status (READY `$80`, NET_BUSY `$40`, TX_RECVD `$20`,
SHORTED `$10`, UNDERFLOW `$08`, COLL `$04`, 16COLLS `$02`, PAR_ERR `$01`; write 1 clears), +1 TX
mask, +2 RX status (PKT_OK `$80`, RESET_PKT `$10`, SHORT `$08`, ALIGN `$04`, CRC `$02`, OVERFLOW
`$01`), +3 RX mask, +4 TX mode (Turbo: bit 7 TXMODE_ENABLE, bit 2 TPE/TM, bit 1 LOOP/DIS_LOOP), +5 RX
mode (Turbo: bit 7 RXMODE_ENABLE, bit 1 ?), +6 reset/control (bit 7 EN_RESET, bit 6 BADTPE = no
TP link), +8..+$D node ID bytes 0..5. All byte accesses; the driver wraps each in the bus-error-safe
probes `mon_probe_read_byte/write_byte` (15 attempts), except the two writes in the `$704` path.
`$02106010..$02106014` (5 timing bytes) are written only on non-Turbo (types 0..2).

### 8.1 Writes in order (TC)

| # | routine | register writes |
|---|---|---|
| 1 | `exc_dispatch` $704 ($01001aXX) | `$02106006 = $80` (reset); `$02106004 &= ~$04` |
| 2 | `enet_init` sub_01008e5e (boot from "en", or POST) | `$02106006 = $80`; `$02106001 = 0`; `$02106000 = $FF`; `$02106004 = 0`; `$02106004 \|= $04` (TPE), `delay_us(500000)`, `mg+$F0 = "en"`; `$02106003 = 0`; `$02106002 = $FF`; `$02106005 = $80`; MAC -> `$02106008..$0210600D` (ROM header `$01000008` unless its bytes 3..5 are FF FF FF, then NVRAM bytes 4..9); RX DMA: `CSR $02000150 = $00940000`, `Next $02004150 = rxbuf0`, `Limit $02004154 = rxbuf0 + $630`, **`$0200411C = rxbuf0`** (TX-channel Stop register per the Previous map; purpose unknown, flagged uncertain — the core should accept the write harmlessly); `enet_rx_dma_start(1)`; `mask \|= $08000000`; `vbr[$78] = sub_01009102`; `sr = $2500` if IPL < 5. **On Turbo `$02106006` is left at `$80`** (non-Turbo writes 0 afterwards); bit 7 must therefore not hold the Turbo chip in reset. |
| 3 | `enet_rx_dma_start` sub_010096be | `$02106002 = $FF`; `Next = buf`, `Limit = buf + $630`, `$0200411C = buf`; `Start = next buf`, `Stop = next buf + $630`; `CSR = $000F0000` / `$00070000` / `$000E0000`; `$02106005 = $82`; reads `CSR`: bits 27:24 all 0 -> "i3", bit 24 clear -> "X" flag |
| 4 | `enet_rx_int` sub_010095f0 (vector `$78`) | reads `CSR` (bits 27:24 must be non-zero), `$02106002`, saved limit `$02004050`; `$02106002 = $FF`; `enet_rx_dma_start(0)` |
| 5 | `enet_read` sub_01009116 | reads `$02106002`; if PKT_OK: `$02106002 = $FF`, `$02106005 = rxmode \| $80`; frame length = `(saved limit & $3FFFFFFF) - buffer`; **if bytes 1..6 of the buffer equal our MAC or broadcast the frame is shifted down one byte** (the Turbo chip deposits the frame one byte late) |
| 6 | `enet_write` sub_0100928a | (TP toggle dance with 500 ms delays if `tpcheck`); `TX CSR $02000110 = $00980000`, `= 0`; copy to txbuf; `Next $02004110 = txbuf`, `Start $02004118 = txbuf`, `Limit $02004114 = txbuf + len`; `CSR = $00010000`; `$02106004 \|= $80`; poll `$02106000` bit 7 (READY) up to 300000 times; if `$02106006` bit 6 (BADTPE): `$02106004 &= ~4`, 500 ms, retry; finally wait READY again, `$02106004 &= ~$80` |
| 7 | `enet_close` sub_010095b2 | `$02000110 = $00100000`, `$02000150 = $00100000`, `$02106006 = $80` |

### 8.2 RX ring

32 buffers of `$2000` bytes below the top of RAM (section 3.1), limit `$630` = 1584 bytes each;
producer index `state+$18`, consumer `state+$1A`; a frame is valid if 0 < len <= `$62E`. The
receive filter must deliver frames whose destination is our MAC or FF:FF:FF:FF:FF:FF (`net_poll_recv`
sub_01007354 also checks). BOOTP replies must be unicast to our MAC.

### 8.3 Interrupt

RX DMA completion -> status bit 27 (level 6) -> vector `$78` `sub_01009102` -> `enet_rx_int`. The
ROM runs with `sr = $2500` during network boot so the level-6 interrupt is taken.

### 8.4 Network boot protocol (for completeness)

`bootp_request` sub_01006e12 (UDP 68 -> 67, vendor "NeXT", xid from the event counter, 5 tries x
rounds with random backoff), `tftp_load_kernel` sub_01006a44 (RRQ "octet", 512-byte blocks, ACK per
block, a.out OMAGIC or Mach-O MH_PRELOAD header via `boot_load_image_header` sub_01006914, then
`jsr entry`). ARP replies are answered (`net_arp_reply` sub_010071ec).

### 8.5 POST loopback (`post_enet_test` sub_01004bf0, TC path)

`$02106004 &= ~2`, 9 us, `\|= 2` (LOOP), `&= ~4`; 100 ms; drain; send a 1500-byte frame (own MAC
-> own MAC, type `$55AA`, payload 0,1,2,...) and expect it back unchanged; set `$0210600D` = own
byte 5 + 1 and expect **no** reception; broadcast destination and expect reception; restore
`$02106004 &= ~2`; `enet_close`. Error codes `$71..$77`.

---

## 9. SCSI NCR 53C90 ("ESP") — `$02114000` (alias of `$02014000`)

ESP registers: +0 transfer count low, +1 high, +2 FIFO, +3 command, +4 status (r) / select bus ID
(w), +5 interrupt status (r, clears the interrupt) / select timeout (w), +6 sequence step (r) /
sync period (w), +7 FIFO flags (r) / sync offset (w), +8 configuration 1, +9 clock conversion
factor, +$A test, +$B configuration 2. All byte accesses.

### 9.1 SCSI DMA control register `$02114020` (byte; Previous `esp.h`)

bits 7:6 clock select (00 = 10 MHz), `$20` ENABLE_INT, `$10` MODE_DMA, `$08` DMA_READ
(scsi->mem), `$04` FLUSH, `$02` RESET (hard reset of the ESP), `$01` CHIP_TYPE (0 = 53C90).
Values written: `$02` (reset, `$704` path and POST), `$00`, `$22` (reset + int), `$20` (PIO, int
on — the idle state), `$30` (DMA out), `$38` (DMA in), `$3C` (DMA in + flush pulse), and the
floppy's RMWs of bits 3, 4, 2 (section 10).

### 9.2 Init sequence — `scsi_init` sub_0100d9b4 (called by `sd_open` and by `scsi_abort`)

| # | write |
|---|---|
| 0 | (first touch, `exc_dispatch` $704: `$02114020 = $02`; ESP command `+3 = $03` SCSI bus reset) |
| 1 | `$02114108 &= ~$40` (floppy external control: deselect the 82077 — it shares the DMA channel) |
| 2 | `dma_init`: `$02000010 = $00100000` |
| 3 | `$02114020 = $22`; 10 us; `$02114020 = $20`; 10 us |
| 4 | config 1 `+8 = $57` (parity enable, SCSI-reset interrupt disabled, bus ID 7) |
| 5 | clock conversion `+9 = 5` (ROM assumes a 25 MHz ESP clock on Turbo; 4 on non-Turbo) |
| 6 | select timeout `+5 = $99` (153 -> 250 ms) |
| 7 | sync offset `+7 = 0` (async), sync period `+6 = 5` |
| 8 | command `+3 = $03` (**SCSI bus reset**), `delay_us(2000000)` |
| 9 | read interrupt status `+5` twice (clears the reset interrupt) |
| 10 | config 1 `+8 = $17` (reset-interrupt reporting on) |

### 9.3 Command flow

* `scsi_start` sub_0100dc44: command `$01` (flush FIFO); 10 us; `+4 = target`; FIFO <-
  `$80 | lun` (IDENTIFY), FIFO <- CDB (6/10/12 bytes); command **`$42` (SELECT WITH ATN)**; state 1.
* Completion is polled: `scsi_run_cmd` sub_0100db8e sleeps 10 ms per iteration and calls
  `scsi_intr` when **status register bit 12 (INT_SCSI)** is set; 1000 iterations -> "sc: Didn't
  complete". `mg+$302/$306` also let `boot_l3_isr` call `scsi_intr`.
* `scsi_intr` sub_0100dd4e: if a DMA phase was running: 20 us; for data-in 3 x {`$02114020 =
  $3C`, 5 us, `= $38`, 5 us}, 20 us; then `$02114020 = $20`. Reads status `+4`, seq step `+6`,
  interrupt status `+5` (clears). Bit 7 of int status (SCSI reset) -> wait up to 10 s for it to
  clear, else config 1 `$57` and result 5. Gross error / illegal command -> "sc: software error";
  parity -> "sc: parity error" (both call `scsi_abort` -> full `scsi_init`).
  State machine (`scsi_intr_state_tab` `$01012A3C`): 1 selected: int status bit 5 (disconnect) =
  selection timeout (result 1), else needs seq step & 7 in {2,4} and int status == `$18` (FC|BS)
  -> state 2 -> `scsi_phase_dispatch`.
* `scsi_phase_dispatch` sub_0100df9e: command `$01` (flush), switch on `status & 7`:
  * 0 DATA OUT `scsi_phase_data_out` sub_0100dfe4 / 1 DATA IN sub_0100e05e: if no bytes remain:
    state 6, count `+0 = 0, +1 = 1` (256), FIFO <- 0, command `$00` then **`$98`** (DMA transfer
    pad). Else state 4: `dma_setup_chain` + `dma_start` (dir 0 / `$40000`), `+0 = count low`,
    `+1 = count >> 8`, command `$00` then **`$90`** (DMA transfer information), `$02114020 = $30`
    (out) / `$38` (in).
  * 3 STATUS: state 3, command **`$11`** (initiator command complete) -> `scsi_intr_status`:
    needs int status bit 3 (FC) and FIFO level 2; status byte and message byte from the FIFO.
  * 7 MSG IN: state 7, command `$00` then **`$10`** (transfer information, PIO); FIFO level must
    be 1; message must be 0 (COMMAND COMPLETE) -> state 5, command **`$12`** (message accepted).
  * 2, 4, 5, 6 -> errors.
  * DMA done (state 4 interrupt): residual = `(+1 << 8) | +0`; `dma_cleanup`; if
    `softc+$2C & $4000` -> "sc: bus error".
* `sd_open` sub_0100e1ec: `scsi_init`; INQUIRY (`12 lun<<5 00 00 42 00`, 66 bytes in) to targets
  0..6 until the n-th responder (device type 0/4/5/7/8); "booting SCSI target %d, lun %d";
  START UNIT (`1B lun<<5|1 00 00 01 00`), TEST UNIT READY loop (1 s retries); READ CAPACITY
  (`25 ...`, 8 bytes) -> block size and last LBA; REQUEST SENSE (`03 ... 0E 00`) on CHECK
  CONDITION. `sd_read` sub_0100e646: READ(6) `08 (lun<<5)|(lba>>16) lba>>8 lba n 00`, up to
  8 KB per call (`boot_fs_read` chunks of `$2000`).
* Disk boot: 4 label copies at blocks 0, 15, 30, 45 (`$1C48` bytes, magic 'NeXT'/'dlV2'/'dlV3',
  16-bit checksum `sub_0100743c`), then `cd_boot_blkno[0..1]` -> 1 KB header read ->
  a.out/Mach-O -> rest loaded -> `jsr entry` with the boot-arg string ("sd(0,0,0)file").

### 9.4 Interrupt handling summary

The ROM never installs an ESP vector; it needs **status bit 12 to follow the ESP INT line** and
the interrupt to drop when `+5` is read. FIFO flags `+7` bits 4:0 = FIFO count are checked
exactly (5, 3, 2, 1, 0 in the various paths).

### 9.5 POST (`post_scsi_test` $01004a2a, `post_ext_scsi_test` $01004ada)

`$02114108 &= ~$40`; `$02114020 = $02`, 10 us, `= 0`, 10 us; command `$02` (chip reset), `$00`
(NOP); FIFO <- 0,1,2,3,4; flags & `$1F` == 5; read FIFO 0 then 1; flags == 3. Extended: `$01`
flush -> flags 0; `+0 = +1 = $55`, command `$80` (DMA NOP loads the counter) -> read back `$5555`
(then `$AA`); config `+8` written/read 0..255; command `$FF` -> int status bit 6 (illegal command)
within 10 us; `$02`, `$00`.

---

## 10. Floppy Intel 82077AA — `$02114100` (alias of `$02014100`) and external control `$02114108`

Only reached by booting "fd", the monitor `ef` (eject) command, the power-down eject, and
`fd_pick_default_boot` sub_0100187c (when the NVRAM boot command starts with "FD": `$02014108 |=
$40`, DOR `$02014102 = 0` then `$14`, status bit 2 -> "en" else "fd", then restore). Also
`scsi_init` and the SCSI POST clear `$02114108` bit 6. So the **minimum** for a SCSI-boot core is:
`$02114108` readable/writable with bit 2 (no drive) = 1, and the 82077 registers not bus-erroring.

Registers: +0 status A (bit 4 TRK0_N), +1 status B, +2 DOR, +4 MSR (r; RQM `$80`, DIO `$40`) /
DSR (w), +5 FIFO, +7 DIR (r) / CCR (w). External register `$02114108`: write `$80` eject, `$40`
select 82077, `$20` reset; read `$04` no drive, `$03` media id (3 = 720K, 2 = 1.44M, 1 = 2.88M,
0 = none).

| step | routine | writes |
|---|---|---|
| init | `fc_init` sub_01010e14 | `$02114108 = $40`; `fc_reset`; DMA: `dma_init` on `$02000010` |
| reset | `fc_reset` sub_010110d8 | DOR `= $00`; 250 us; DOR `= $04` (RESET_N high); DSR `= 0`; CCR `= 0`; `$02114108 = $40`; `fc_configure`: `13 00 58 00` (implied seek, FIFO on, threshold 8, polling off; no result phase); `fc_specify(3)`: `03 SRT<<4\|HUT HLT<<1` with DSR = CCR = rate first (rate 0 = 500 kbps for density 2, 2 = 250 kbps for 1, 3 = 1 Mbps for 3; SPECIFY bytes `03 D8 04` / `03 E4 02` / `03 A0 08`) |
| select | `fc_start` sub_01010e96 | DOR `= (DOR & ~3) \| drive` |
| motor | `fc_motor_on` sub_01011670 | DOR `\|= $10 << drive`, wait 500 ms; before every R/W-class command the ROM checks `$02114108` bit 2 and fails with "no drive" (status 5) if set |
| command | `fc_send_cmd` sub_010116d2 | for DMA commands: `fc_dma_reset` (dummy 16-byte dev->mem transfer + `$02000010 = $00100000`), `dma_setup/dma_start` on `$02000010` (dir `$40000` for reads); command bytes via FIFO after `MSR & $C0 == $80`; then **`$02114020 \|= $08`** (read) or `&= ~$08` (write), **`\|= $10`** (DMA mode); wait for **status bit 7 (INT_PHONE)** with `fd_wait_intr` (timeouts 1000 ms R/W/recal, 400 ms seek, 10 ms specify/configure); `fc_intr`: if DMA: `$02114020 \|= $04`, 5 us, `&= ~$04`, 5 us (once on Turbo, 8x on `$139`), `&= ~$10`; poll RQM; if DIO = 0 send `08` (SENSE INTERRUPT); result bytes read while `MSR & $C0 == $C0` |
| media probe | `fd_probe_media` sub_010103d0 | RECALIBRATE `07 00` (x2), needs ST0 SE bit, PCN 0 and status A TRK0_N low; media id from `$02114108` bits 1:0 (0 -> "No Floppy Disk Present"); then trial READ DATA (`46 hh C H R N EOT GPL FF`, 7 result bytes) at densities 3,2,1 and sector sizes 512/1024 |
| eject | `fc_eject` sub_0101156c | SEEK `0F 00 4F`; `$02114108 \|= $80`; `&= ~$80`; 2 s; motor off |

Read result acceptance: ST0 IC = 0, or ST1 == `$80` (EN only), or IC = `$40` with all requested
bytes moved by DMA and ST1 bit 4 (OR) set.

---

## 11. SCC Z8530 — `$02118000` (alias of `$02018000`)

`$02118000` channel B control, `$02118001` channel A control, `+2` = data of each channel
(`$02118002` B, `$02118003` A), `$02118004` clock select register (long). Every register write is a
register-index byte followed by the value byte on the control port.

### 11.1 `scc_init` sub_01008964 (called in the `$704` path on every boot; TC)

1. `$02118001 <- $09`, `<- $C0` (WR9 = force hardware reset), `delay_us(10)`.
2. `scc_init_channel($02118001, 9600)` (A), then `($02118000, 9600)` (B), each:

| # | index, value | meaning |
|---|---|---|
| 1 | `09, 02` | WR9 NV, interrupts off |
| 2 | `0B, 50` | WR11 Rx/Tx clock = BRG |
| 3 | `30` | WR0 error reset |
| 4 | `10` | WR0 reset ext/status interrupts |
| 5 | `04, 44` | WR4 x16 clock, 1 stop bit, no parity |
| 6 | `03, C0` | WR3 Rx 8 bits, Rx disabled |
| 7 | `05, 60` | WR5 Tx 8 bits, Tx disabled |
| 8 | `0E, 00` | WR14 BRG off |
| - | **`$02118004 <- $0A`** (long) | clock select: A and B clock = 4 MHz RTxC, PCLK 3.6864 MHz (Previous `scc.c`), written by `scc_calc_baud_tc` sub_01008b30 |
| 9 | `0C, 0A` | WR12 time constant low (9600 from PCLK 3.6864 MHz: TC = 10) |
| 10 | `0D, 00` | WR13 time constant high |
| 11 | `0E, 02` | WR14 BRG source = PCLK |
| - | `delay_us(10)` | |
| 12 | `0E, 03` | WR14 BRG enable |
| 13 | `03, C1` | WR3 Rx enable |
| 14 | `05, EA` | WR5 DTR, Tx 8 bits, Tx enable, RTS |

3. `mg+4 &= $CF`.

### 11.2 Use

Serial console only when the KMS keyboard times out **and** NVRAM alt-cons (byte 0 bit 3) is set
(`mg+$318/$31C = 1` -> channel A): getc spins on RR0 bit 0, putc spins on RR0 bit 2, XON/XOFF
honoured, even parity added over 7 bits by the table at `$0101A8BC`. Otherwise the SCC is only
initialised. POST (`post_scc_test` $010048a6): WR9 `$CA`, then the 20-byte table `$010195F4`
(`04 44 0B 50 0E 10 0C 0A 0D 00 0E 11 0A 00 03 C1 05 EA 0F 00` — WR14 `$10/$11` = local loopback)
on both channels; writes `$40` to the data register and expects RR0 bit 0 and the same byte back
(errors 1..7).

---

## 12. RTC / NVRAM (MC68HC68T1 or MCCS1850 behind SCR2 byte 2)

### 12.1 Bit-bang protocol (`rtc_read_reg` sub_010087cc/sub_010087e8, `rtc_write_reg` sub_010086e8)

`base = SCR2 & $FFFFF8FF` (RTCE/RTCLK/RTDATA cleared); every step separated by `delay_us(1)`
(~2 ticks). Long writes to `$0200D000`.

1. `SCR2 = base | $100` (CE high).
2. Address byte, MSB first, 8 bits: `SCR2 = base | $100 | (bit ? $400 : 0)` (data, CLK low);
   `|= $200` (CLK high); `&= ~$200` (CLK low). Write commands use `reg | $80`.
3. Read: 8 data bits MSB first: `SCR2 = base | $300` (CLK high); `SCR2 = base | $100` (CLK low);
   sample bit 10 (`$400`) -> the chip shifts out on the falling edge, sampled after it.
   Write: 8 data bits exactly like the address bits.
4. `SCR2 = base` (CE low).

The chip must drive RTDATA (SCR2 bit 10 read-back) during reads; ROM-written RTDATA must not
disturb the other SCR2 bits.

### 12.2 Registers used

| reg | use | routine |
|---|---|---|
| `$00..$1F` | NVRAM read (32 bytes) | `nvram_read` sub_0100861c |
| `$80..$9F` | NVRAM write | `nvram_write` sub_0100866c (writes, then re-reads and compares) |
| `$20..$27` | time (old chip BCD: sec, min, hour, weekday, mday, month, year) / `$20..$23` 32-bit seconds (new chip) | `rtc_get_time` sub_010084d6, `rtc_wait_tick` sub_0100823e, `post_rtc_test` (seconds must change within ~1.1 s) |
| `$30` | status: bit 7 = new chip (MCCS1850), bit 4 FIRSTUP, bit 2 LBAT, bit 1 ALARM, bit 0 PDOWN (power button) | `rtc_power_int_handler` sub_010082ca (only when status bit 2 INT_POWER), `rtc_start_clock` sub_01008400 |
| `$31` | control (new chip): `\|= 4` CLRFTU, `&= ~2`, `\|= 8`, `\|= 1` CLRPDOWN, `\|= $80` START, `\|= $40` POWERDOWN; old chip: `= $B0` (START, 32.768 kHz) | sub_010082ca, sub_01008400, `rtc_power_down` sub_01008380 |
| `$32` | old chip interrupt control: `= 0` at boot | sub_010083d4 ($704 path) |

If the NVRAM checksum is bad at reset, `nvram_check_or_rtc_ramtest` sub_01005cd2 does a
walking-one write/read test of registers 0..31 (bits 1,2,4..$80); any mismatch -> 4 LED blinks,
halt. **RTC RAM must therefore be fully read/write even before the ROM writes a valid image.**

### 12.3 NVRAM byte layout as the ROM uses it (copy at `mg+$16`)

| byte(s) | field | ROM use |
|---|---|---|
| 0..3 (long `ni_reset`) | bits 31:28 reset field (must be 9 for the image to be accepted); 27 alt cons; 26 allow eject; 25:20 volume R; 19:14 brightness (0..$3D, forced >= $14 at video enable); 13:10 hardware password (6 = set); 9:4 volume L; 3 disable speaker; 2 lowpass; 1 boot any; 0 any cmd | `mg_init_machine`, `mon_password_check`, `vid_enable_display`, `kms_set_volume` |
| 4..9 | password xor `$4E` (when set) / Ethernet address fallback | `mon_cmd_password`, `enet_init`, `exc_dispatch` |
| 10..11 | `ni_simm`: 3 bits per bank at 3i (size code), parity bits at 9+i | `mon_init` step 8 (rewritten if it differs from the sizing result) |
| 14 | POT: `$01` POT_ON, `$02` EXTENDED, `$04` LOOP, `$08` VERBOSE, `$10` TEST_DRAM, `$20` BOOT, `$40` TEST_MONITOR | `post_run_all`, reset |
| 15, 16 | oldest / most recent POST error code | `mon_init` |
| 17 | bit 7 new clock chip (not read by the ROM: it reads reg `$30` bit 7 instead), bit 5 USE_CONSOLE_SLOT, bits 4:3 CONSOLE_SLOT, bit 2 USE_PARITY_MEM | `vid_console_init`, `mem_config_test_t` |
| 18..29 | boot command string (max 11 chars + NUL; default "en") | `boot_cmd`, `fd_pick_default_boot` |
| 30..31 | checksum: `~sub_0100743c(buf, 32)` = one's-complement 16-bit sum computed with the checksum word zeroed | `nvram_read/write` |

Default image built when the checksum is bad or the reset field != 9: all zero, reset field 9,
brightness `$3D`, POT `$11`, bootcmd "en", allow-eject set.

---

## 13. Timers

### 13.1 Event counter `$0211A000..3` (alias of `$0201A000`) — 20-bit free-running microsecond counter

`timer_read_us` sub_0100889c reads the four bytes: +0 is read and discarded, +1 = bits 19:16,
+2 = bits 15:8, +3 = bits 7:0 (`mg+$2F6` extends it in software to 32 bits on wrap). **Every ROM
delay** (`delay_us` sub_01008936, hundreds of call sites: 1 us RTC edges, 8 ms ADB polls, 750 ms
video enable, 2 s SCSI reset, 3 s boot retries) busy-waits on it: if the counter does not run at
1 MHz the ROM hangs at the first delay (before the screen is on). `post_evcnt_test` $01005440
requires: two reads 1 us apart differ; 1000 us delay measures 900..1100 counts; 100 back-to-back
reads have deltas within 3 us of their mean.

### 13.2 Hardclock `$02116000/1` (count high/low bytes) and CSR `$02116004` (alias of `$02016000`)

Used only by `post_timer_test` $0100534e (TC): CSR `= $80` then `0`; for every 16-bit value: low,
high, low written, CSR `= $40` (LATCH), read high<<8|low must equal the value; then vector `$78` =
ISR, mask `= $20000000`, `sr = $2500`, CSR `= 0`, count = 1000 (`$03E8`), CSR `= $C0`
(ENABLE|LATCH), `delay_us(1100)`, CSR bit 7 must have been cleared by the ISR (which reads the
CSR and writes 0) -> INT_TIMER (status bit 29, level 6) must fire within 1 ms. Not needed to
reach the prompt when POT_ON is clear.

---

## 14. Devices a Turbo Color core can leave out

| device / address | ROM behaviour on TC | minimum the core must provide |
|---|---|---|
| BMAP `$020C0000..` | first write at `reset_entry` ($01000022) is the "is this a Turbo?" probe; `mg+$3B2 = 0` afterwards so no other access. `mon_enter_from_os` sub_010008e2 (OS re-entry callback) also writes BMAP+4 unguarded | **bus error** on `$020C0008` (required); the whole `$020C0000` page should bus-error |
| NCC `$02210000`, cache tag `$03E00000`, data `$03F00000` | probed by `reset_probe_ncc` $01000092; `mg+$3CA = 0` for type 5 so never used later | **bus error** at `$02210000` (recommended; if it reads, `isp` bit 13 is set and `mon_init` step 5/6 could try NCC paths only if `mg+$3CA` were set — it is not for type 5) |
| NBIC `$02020000/4`, slot space `$F0FFFFxx` | only in the cube branch of `vid_console_init` (`mg+$3B6 == 0`); skipped on stations | nothing (bus error is fine) |
| GPIO `$02012000..7` | `$02012000 = $88` cube branch only; `$02112004..7` written for types 0/2 in the `$704` path and `od_reset` | nothing |
| Optical disk `$02112000..$0211201F`, DMA `$02000050` | only when the user boots "od" or presses `eo`/`ej`; `od_open` does not exclude Turbo types; `od_ctrl_init` sub_0100f060 polls `$02112004` bit 0 up to 3,000,000 times, then "no optical disk" and the boot falls back to "en" | reads of `$02112004` must return 0 (the poll is an unprotected byte read; a bus error there would drop into the monitor with "Exception #2") |
| DSP `$02008000` | never accessed (only SCR2 bit 31 cleared) | nothing |
| Printer `$0200F000`, printer DMA | never accessed | nothing |
| Sound in DMA | unreferenced code only | nothing |
| Brightness register `$02110000` | mono driver only | nothing |
| MWF mirrors, colour VRAM `$2C000000`, video DMA `$02000180/$02004184`, colour video reg `$02118180` | non-Turbo paths (`$139`) | nothing |
| Ethernet `$02106010..14` timing bytes | types 0..2 only | nothing |
| SCR2 TIMERIPL7, ROM-local, DSP bits | not written on TC | reads must return a stable value; bit 12 (byte 2 bit 4) = 1 |
| Sound out (KMS `$07/$0F/$C4`, DMA `$02000040`) | POST with TEST_MONITOR_POT, console BEL | optional; loops terminate without it |
| Floppy | see section 10 | `$02114108` reads `$04` (no drive), registers don't bus-error |
| ADB | see section 5 | INTSTATUS bits 3/2 set after CTRL `$08`/`$04`, STATUS DATAPEND clear |

---

## 15. Exceptions the ROM relies on

| mechanism | where | requirement |
|---|---|---|
| Bus error as a probe, pre-stack | `reset_entry` `$020C0008`, `reset_probe_ncc` `$02210000` | 68040 access-error exception (format 7 frame) pushed on the header SSP `$04000400` (DRAM bank 0 must accept writes before it has been tested); the handlers are `sub_01000092` / `sub_010000b0` via the 8-entry vector tables `dat_010145b0/bc` (only slot 2 used). No `rte`: the handler just continues. |
| Bus error as a probe, with mg | `mon_probe_read_byte` sub_0100237a, `mon_probe_write_byte` sub_010023b8, `mon_probe_read_long` sub_010023f6 (continuation in `mg+$1A4`); used by the Ethernet register wrappers (every byte access) and the NBIC probe | `exc_dispatch` loc_01001d32 patches the saved PC (frame+`$8E`) to the continuation and adjusts the stack for frame formats 0/1 (+0), 2/3 (+4), 7 (+`$34`); formats 4..6 print "bogus stack frame". So the core's bus errors must produce a well-formed format-7 frame with correct FA/SSW so the `rte` resumes. |
| Addresses that **must** bus-error on TC | `$020C0008` (write, reset), `$02210000` (write, reset) | otherwise the machine is treated as BMAP / NCC equipped |
| Addresses that must **not** bus-error on TC | everything in sections 1..13 (`$0200xxxx`, `$0211xxxx` aliases, `$02200000..$0220008C`, `$02208000..$02208088`, `$0201C000..3`), all of DRAM bank 0..3 as populated (partial banks must alias, section 3.3, not fault), the full 2 MB at `$0C000000`, ROM at `$00000000` and `$01000000` (128 KB, CRC-checked up to `$0101FFFF` — the ROM CRC loop reads `$0100001E..$0101FFFF`, so the whole 128 KB window must be readable, zero-filled after `$0101B47F`), `$02112004` (returns 0) | |
| NMI / level 7 | vector `$7C`; sources: TMC NMI register bit 0 (ADB magic key), KMS NMI_RECEIVED (Cmd+` on a KMS keyboard sets status bit 31), parity (status bit 30 + TMC parity registers) | `exc_dispatch` $7C path: `mon_clear_nmi` then `mon_init(reinit=1)` -> monitor. The parity-probe NMI vector (`mem_vectors_t` entry 31) expects the NMI to be delivered synchronously with the faulting read while `TMC ctrl` bit 10 is set; a core without parity must not raise it. |
| Level 3 autovector `$6C` | boot animation (INT bit 13) and SCSI hook (bit 12) while `sr = $2200` | see section 2.4 |
| Level 6 autovector `$78` | Ethernet RX DMA (bit 27) with `sr = $2500`; POST timer / sound | |
| Trap #13 (vector `$B4`) | "mon_trap" from a booted program; `$600` = return trap | ROM internal |
| `$700` / `$704` pseudo-vectors | fake frames pushed by the reset code / `mon_reenter_704` | ROM internal |
| Address error / illegal etc. | print "Exception #%d (0x%x) at pc ... sp ..." and enter the monitor | |

---

## 16. Minimum viable hardware

### 16.1 To reach the `NeXT>` prompt (POT_ON clear, no boot device)

1. **CPU**: 68040 with FPU (POST only), MMU transparent translation, `cinva/cpusha`, line-burst
   reads from ROM/DRAM/VRAM.
2. **ROM** 128 KB at `$00000000` (reset alias) and `$01000000`, readable to `$0101FFFF`.
3. **SCR1** `$0200C000` type nibble 4 or 5, `$02200000` type 5, cpu speed 7; **SCR2** `$0200D000`
   byte/long r/w, bit 0 LED, bits 10:8 RTC bit-bang, byte 2 bit 4 = 1, other bits readable.
4. **Bus errors** at `$020C0008` and `$02210000`.
5. **TMC**: `$02200010` r/w long; `$02200004/8/C` writable, read 0; `$02200020` r/w bit 0 -> NMI;
   `$02200080` byte-0 semantics of section 2.4 (at least: accept `$04/$05/$06`, generate status
   bit 13 per frame when bit 25 set, clear on bit 24 write); `$02200088/8C` writable, reset
   default = 1120x832 timing.
6. **DRAM**: bank 0 at `$04000000` (>= 2 MB) with correct aliasing at +`$200000`/+`$800000` for
   the sizing test. Absent banks (`$06000000`, `$08000000`, `$0A000000`) must **not** bus-error
   (no `mg+$1A4` handler is armed in `mem_config_test_t`; the pre-stack `mem_dram_probe` has no
   handler at all) and must read back something other than the pattern just written (0 or
   `$FFFFFFFF` is fine; a write-buffer echo would make the ROM believe the bank exists).
7. **VRAM** 2 MB at `$0C000000`, 16-bit pixels, low nibble may be ignored, readable/writable
   as longs/words/bytes, line-burst readable.
8. **Bt463** at `$0201C000..3` with auto-increment (section 4.2).
9. **Interrupt registers** `$02007000` (status; bits 2, 12, 13, 27, 30, 31 meaningful) and
   `$02007800` (mask); IPL generation per the level table in 1.3.
10. **Event counter** `$0211A000..3` (and `$0201A000`) running at 1 MHz, 20 bits.
11. **RTC/NVRAM** behind SCR2 bits 10:8: 32 bytes RAM r/w at 0..$1F / write $80..$9F, status
    reg `$30` (bit 7 selects chip type; bit 0 = 0 unless the power button is pressed), `$31/$32`
    writable, seconds registers.
12. **ADB** window `$02208000..$02208088` with the no-device minimum of section 5.
13. **KMS** `$0200E000..$0200E008`: `$0200E002` bit 1 writable, `$0200E003/4` command sink,
    `$0200E001` bit 6 set after a `$C5` command (else the ROM waits 100000 polls x 3 and
    continues), `$0200E000` bit 22 + `$0200E008` for key events after `$C6/$01FFFFF6` polls;
    `$C6/$1000A825` must reset the machine.
14. **SCC** `$02118000..4`: accept the register-index/value writes (no reads needed unless the
    serial console is used).
15. **ESP** `$02114000..B` + `$02114020`: accept the `$704`-path writes (`$02114020 = 2`,
    command `3`); **Ethernet** `$02106004/6`: accept the two `$704`-path writes.
16. **Floppy** `$02114108` read `$04`.
17. Interrupt status bit 2 (power) = 0.

### 16.2 Additionally, to boot from SCSI

The NVRAM boot command must be "sd" (the built-in default "en" does not fail over to SCSI;
`boot_cmd` retries the network forever). With no valid NVRAM the ROM builds a default of "en", so
the core should ship an NVRAM image whose bytes 18.. read "sd" (checksum per section 12.3).

1. **ESP 53C90** full register model of section 9: bus reset command with interrupt, SELECT WITH
   ATN with sequence step 2/4 and interrupt status `$18`, phase reporting in status bits 2:0,
   DMA transfer information (`$90`) and pad (`$98`), ICCS (`$11`) leaving status + message in the
   FIFO, message accepted (`$12`), FIFO flags count, transfer counter, config 1, select timeout
   giving a disconnect interrupt (bit 5) for absent targets (7 targets are probed: 0..6).
2. **SCSI DMA control** `$02114020` bits 5:2 as used (`$20/$30/$38/$3C` and floppy RMWs).
3. **TDMA channel** `$02000010` + `$02004010..1C` with RESET/BUFRESET, SETENABLE, SETSUPDATE
   chaining (Start/Stop taken after Next/Limit complete), DEV2M direction, 16-byte-aligned
   bursts, `Next` readable after `dma_stop`, ENABLE/COMPLETE status bits.
4. **Interrupt status bit 12** following the ESP INT pin; **bit 7** = floppy IRQ (only if the
   floppy is modelled).
5. A SCSI disk with a NeXT disk label at block 0 (or 15/30/45) and a boot block (a.out OMAGIC or
   Mach-O MH_PRELOAD) at `cd_boot_blkno[0]`; READ(6) with 21-bit LBAs, INQUIRY type 0,
   READ CAPACITY, START UNIT, TEST UNIT READY, REQUEST SENSE.
6. The level-3 frame interrupt of section 2.4 is used during the boot animation; without it the
   animation simply does not advance (the open/load path is polled), so it is optional but
   expected.

### 16.3 To boot from the network instead

Ethernet register model of section 8 with RX DMA ring, saved limit `$02004050`, level-6 interrupt
(status bit 27), destination filter, and the one-byte-late frame deposit (or the ROM's shift
compensation will corrupt frames whose first byte is not our MAC: the ROM shifts only when
bytes 1..6 match our MAC or broadcast, so a core that deposits frames at offset 0 works as long
as byte 0 of a frame never equals the first MAC byte — safer to deposit at offset 1 like the
real chip / Previous).

---

## Disagreements and open points between the notes

| topic | what the notes say | resolution / status |
|---|---|---|
| Machines with `mg+$194 = $139` | `01000000.md`: types 0,1,2; `0100e000.md`: types 0 and 1; others: 0..3 | **0..3** (listing $01000d20..$01000d4c: type 0 -> `loc_01000d32`, 1 <= type <= 3 -> `loc_01000d3c`). Irrelevant to TC (always 0). |
| Initial stack location | brief: VRAM+$3F800 | DRAM bank+$800 on colour types (`01002000.md`, confirmed by $0100041e/$01000508/$01000514); VRAM only on mono types |
| TMC colour reset timing 208/624 "unit unknown" (`01000000.md`, `0100c000.md`) | | It is the 832x624 mode (208 x 4 = 832), written only when SCR2 byte 2 bit 4 is clear; with bit 4 set the ROM writes no timing at all. The alternate ADB timings are 1120x832 in 4-px units. |
| SCR2 bit 12 gating the timing write "meaning not established" (`01000000.md`) | | Same bit as `btst #4,$0200D002` = the 1120x832/832x624 selector (`0100a000.md`, `0100c000.md`) |
| TMC control bit 3 (`&= ~8` when non-parity SIMMs) and `$02200004` role | flagged uncertain in `01002000.md` | still an interpretation; Previous does not model either. Core: bit 3 r/w, `$02200004` write-ignore/read-0 |
| `$0200411C = rxbuf` in `enet_init` / `enet_rx_dma_start` | `01008000.md` flags as unknown (TX stop register in the Previous map) | unresolved; accept the write |
| Ethernet control `$02106006` left at `$80` on Turbo | `01008000.md` | the Turbo chip must run with bit 7 set (Previous only treats it as reset on the non-Turbo path) |
| ESP clock 25 MHz assumption (CCF 5, timeout `$99`) | `0100c000.md`; Previous uses 20 MHz | the values are written regardless; only affects the real select timeout |
| Bt463 CR0/CR1/CR2 = `$40/$00/$80` meaning | unverified (`0100a000.md`) | store and ignore |
| Sound-in DMA CSR `$020000C0` | `01004000.md`; Previous sound-in channel is `$02000080` | unreferenced routine; ignore |
| `adb_intr` sub_0100c2c2, `adb_set_config` sub_0100c5e0 | no callers found | dead code; ADB is fully polled |
| Optical `od_issue` waits on `+5 & 4` (interrupt mask register per Previous) | `0100e000.md` | write path only; not reached on TC |
| `vid_vram_test` leaving "VRAM..." text at bank+$1000 for `mon_init` | inferred (`01000000.md`) | not verified; cosmetic |
| KMS `$C5 $30000` / `$C5 0` command meanings | not decoded | sent once at console init; the core may ignore the data |
