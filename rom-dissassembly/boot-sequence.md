# Boot sequence of ROM v74 on a NeXTstation Turbo Color (machine type 5)

Everything below is for SCR1 machine-type field = 5. Other types are mentioned
only where the ROM branches on them. Routine names are those in
`known_names.py`; the evidence for every step is in `notes/01000000.md`
(reset, dispatcher), `notes/01002000.md` (memory), `notes/01004000.md` (POST),
`notes/01006000.md` (boot command), `notes/0100a000.md` (display),
`notes/0100c000.md` (ADB, SCSI) and `notes/01008000.md` (console, Ethernet).

## Phase 0: no stack, no RAM (reset_entry .. reset_pick_stack)

The pre-stack code cannot call anything, so it passes continuations in address
registers and enters them with `jmp (aN)`. Hardware presence is detected by
**deliberately provoking bus errors**: the vbr points at a tiny ROM table whose
bus-error slot is the next step.

| step | routine | what happens | hardware |
|---|---|---|---|
| 0.1 | `reset_entry` `$0100001e` | vbr = `$010145b0` (bus-error slot = `reset_probe_ncc`). Writes 0 to BMAP `$020C0008`. | **On a Turbo board this write must bus-error**: that is how the ROM learns there is no BMAP. The bus-error frame goes on the header SSP `$04000400` (DRAM bank 0 must exist and be writable at reset). |
| 0.2 | `reset_probe_ncc` `$01000092` | vbr = `$010145bc` (bus-error slot = `reset_machine_dispatch`); writes 0 to NCC `$02210000`. | **Must bus-error** on a stock 33 MHz board (no Nitro cache). d2 = 0 = no NCC. |
| 0.3 | `reset_machine_dispatch` `$010000b0` | d0 = SCR1 `$0200C000`. If type field (bits 15:12) reads 4, SCR1 is re-read from the TMC copy `$02200000` and the type is taken from there. isp = SCR1, msp = type. Type 5 → `reset_turbo_setup`. | SCR1 must present type 5 (`$5xxx` in bits 15:12), cpu speed field 7 (33 MHz), memory speed field. Unknown type → LED code 6 halt. |
| 0.4 | `reset_turbo_setup` `$010002a6` → `mmu_transparent_setup` `$01000c68` | `cinva`, `cpusha`; TC = 0; ITT1 = DTT1 = `$00FFC000` (all 4 GB transparent, supervisor, cacheable write-through); ITT0 = DTT0 = `$0200C040` (`$02xxxxxx` device space, non-cacheable serialized; TT0 wins); `pflusha`; TC = `$C000` (MMU enable, 8 KB pages). | The core's 68040 must honour the transparent-translation registers: everything outside `$02xxxxxx` is cached; device space is serialized. |
| 0.5 | `tmc_reset_config` `$010002b4` | CACR = `$8000` (I-cache on). TMC control `$02200010` = `$0DF4838F` (33 MHz, mem field 0/2/3) or `$0DF4838B` (mem field 1). ADB INTMASK `$02208008` = 0, ADB CONFIG `$02208018` = 0. If SCR2 bit 12 is clear: TMC horizontal `$02200088` = `$165A10D0`, vertical `$0220008C` = `$10412270`. | These are the 832x624 timings (display fields in 4-pixel units: 208 x 4 = 832, 624 lines). SCR2 bit 12 is byte 2 bit 4, the 1120x832 select, so on a Turbo Color presenting that bit the write is skipped and the TMC power-on timing must already be 1120x832. Mono types write `$6302F118`/`$00438340` instead. |
| 0.6 | `$010003cc` | Interrupt mask `$02007800` = 0. CRC-32 over `$0100001E..$0101FFFF` compared with header +`$1A`; CRC-32 over header bytes 0..21 compared with +`$16`. LED (SCR2 bit 0) is on while the CRC runs. | Mismatch → LED blink halt, 1 blink (header) or 2 blinks (body). |
| 0.7 | `reset_pick_stack` `$0100041e` → `mem_dram_probe` `$01003dfc` | Colour types (3,5,7,9,B) look for DRAM: for bank bases `$04000000`, `$06000000`, `$08000000`, `$0A000000` (32 MB stride) write/verify `$55555555`/`$AAAAAAAA` at +0..+C, then an 8 KB pattern test (`$DB6DB6DB`, complement, incrementing). First passing bank wins. | No bank → LED code 5. (Mono types instead put the stack in VRAM `$0B000000`/`$0C000000` + `$3F800` after a 256 KB probe; LED code 3.) |
| 0.8 | `reset_mg_in_dram` `$01000514` | mg (monitor globals, `$48E` bytes) = bank + `$800`; stack grows down from it; exception vectors at mg + `$400` = bank + `$C00`; mg pointer saved at vbr+4; mg_sid = SCR1 >> 28; mg_machine_type = 5. `vid_vram_test(0)` (`sub_01003a9c`): all 2 MB of VRAM at `$0C000000` tested with `$55505550`, `$AAA0AAA0` and an address pattern under mask `$FFF0FFF0` (the low nibble of each 16-bit pixel is don't-care). | VRAM must be 2 MB, 16-bit words, readable/writable at `$0C000000`. Failure → 4×3 LED blinks and "VRAM failure at 0x%x" text queued for later display. |

## Phase 1: first C code (reset_install_vectors .. exc_dispatch $700)

| step | routine | what happens | hardware |
|---|---|---|---|
| 1.1 | `$01000556` | `nvram_check_or_rtc_test` (`sub_01005cd2`): reads the 32 NVRAM bytes over the SCR2 bit-bang interface; if the checksum is valid returns POT & `$10` (TEST_DRAM), else runs a walking-one test on RTC RAM registers 0..31 (LED code 4 on failure). All 256 vectors = `exc_common_entry`. `vid_console_init` (`sub_0100ac8a`, phase 3 below). `mon_show_test_panel` draws "Testing system ..." when POT_ON or TEST_DRAM. | RTC on SCR2 bits 8 (CE), 9 (CLK), 10 (DATA), 1 µs spacing. |
| 1.2 | | A fake exception frame with vector offset `$700` is pushed and the code falls into `exc_common_entry`, which saves all registers and control registers, sets SR `$2700`, `cpusha`, CACR `$8000`, and calls `exc_dispatch` (`sub_010018d4`). Every later exception, interrupt, trap and re-entry goes through this same routine. | |
| 1.3 | `exc_dispatch` vector `$700` | `mon_init(sid, mg, reinit=0, dotests)` (`sub_01000ec6`). | |

### mon_init (`sub_01000ec6`), Turbo Color path

1. mg_intrstat = `$02007000`, mg_intrmask = `$02007800`; `mg_init_machine` (machine-type table: is_station = 1, memory generation = 1, SIMMs per bank = 2, mg_sid = 0, no NCC, mg_dmachip = 0 (not `$139`), board rev from `$02200002` bits 11:8); NVRAM read and validated (default built if invalid: brightness `$3D`, POT `$11`, boot command "en"). Callbacks: getc/try_getc/putc/alert/alloc; version words 3 / 3 / 74; Ethernet address pointer → ROM header +8; pagesize `$2000`; event counter pointer `$0201A000`.
2. Message buffer at bank+`$1000`, allocator at bank+`$4000`.
3. `mem_config_test_t` (`sub_0100361a`): per bank presence (`$55555555`/`$AAAAAAAA` ×3), SIMM-pair sizing by writing `$12345678` at +0, `$89ABCDEF` at +`$800000`, `$ABCDEF01` at +`$200000` and reading back (32 MB / 8 MB / 2 MB pairs), "Bank %d has mixed size SIMMs."; parity probe per bank with a temporary 32-entry vector table whose NMI slot clears TMC `$02200004` and TMC control bit 10; TMC control bit 10 set, 16 bytes of 0, 16 of `$01010101`, 32 bytes with one odd byte, read back; parity present iff bit 10 still set; then cleared. Any present non-parity bank → TMC control bit 3 cleared (meaning not modelled in Previous).
4. If TEST_DRAM: `mem_full_test_t` (`sub_010039bc`): caches off, 3 passes of pattern tests and an 8-byte-lane test ("Main Memory Test Failed", "DRAM error type", "Check socket").
5. Banner: "CPU MC68040 33 MHz, memory nn nS" (MHz from SCR1 bits 2:0 through the Turbo table [40,50,66,80,16,20,25,33]; nS from bits 5:4 through [60,70,80,100]); "Ethernet address: ..." from the ROM header (NVRAM bytes 4..9 if header bytes 3..5 are FF FF FF); "Warning: non-volatile memory is uninitialized." if applicable.
6. mg_region[4] built; NVRAM SIMM word (bytes 10..11) compared with the detected codes ("Memory sockets %d and %d (front/back) configured for %s SIMMs but have %s SIMMs installed"); "Memory size %dMB".
7. **Relocation**: mg (`$48E` bytes) copied to the top of the highest populated bank, vectors (`$400`) just below it, vbr and mg_mon_stack = that vector table, allocator `$1030` below the vectors, region end rounded down to a page. Everything from here on runs with the stack at the top of DRAM.
8. `adb_init` (`sub_0100c1b4`, Turbo only): CONFIG = 0, INTMASK = 0, CTRL = `$08` (bus reset, spin on INTSTATUS bit 3, write 8 to clear), TALK register 3 on addresses 1..7 to enumerate devices into a table at mg+`$3E6`, keyboard set to handler 3, mouse to handler 3 with three LISTEN register 1 writes. The ROM never enables ADB interrupts; it polls.
9. If POT_ON: `post_master` (`sub_01005a46`): "Testing the FPU, SCC, SCSI, Enet, ECC, RTC, Timer, Event Counter, Sound Out"; error code = (subtest code & `$F`) | `$40` FPU, `$50` SCC, `$60` SCSI, `$70` Enet, `$80` ECC, `$90` RTC, `$C0` Timer, `$D0` EvCnt, `$E0` SoundOut; stored in NVRAM bytes 15/16; "System test passed." or "System test failed. Error code %x.". The ECC/MO test runs only on cube types 0/2.

## Phase 2: dispatcher decides (exc_dispatch after mon_init)

If the NVRAM boot command is empty → monitor prompt `NeXT>`. Otherwise the boot
panel is drawn (unless the test panel is already up), `mon_poll_power_key`
(`sub_0100a1a8`), a boot command beginning with "FD" is resolved to "fd" or "en"
by probing the floppy controller (`$02014108` bit 2 = no drive), mg_boot_arg =
inputline, then `mon_call_on_stack(mg_mon_stack, mon_reenter_704, vbr)`:
switch to the monitor stack, redo the transparent MMU setup, push a fake frame
with vector `$704` and re-enter `exc_common_entry` → `exc_dispatch`.

## Phase 3: device init and boot (exc_dispatch vector $704)

In this order:

| # | write / call | value | note |
|---|---|---|---|
| 1 | `$02007800` | 0 | interrupt mask |
| 2 | `scc_reset_init` (`sub_01008964`) | WR9 = `$C0` hard reset, then per channel (A then B): WR9 `$02`, WR11 `$50`, WR0 `$30`, WR0 `$10`, WR4 `$44`, WR3 `$C0`, WR5 `$60`, WR14 `$00`, WR12/13 = time constant (9600 baud: `$000A`), WR14 = clock source, WR14 |= 1, WR3 `$C1`, WR5 `$EA`; clock select `$02018004` = `$0A` | see `notes/01008000.md` |
| 3 | `$02014020` | 2 | SCSI DMA control: reset |
| 4 | `$02014003` | 3 | ESP command: reset chip |
| 5 | SCR2 `$0200D000` | &= `$7FFFFFFF` | clear DSP reset |
| 6 | RTC | read reg `$30`; if bit 7 clear write 0 to reg `$32` | start clock |
| 7 | TMC `$02200080` | `$05000000` | video enable + clear pending frame interrupt |
| 8 | console select (`sub_0100b04e`, `sub_0100b012`) | | mg_console_i/o: 0 = keyboard/screen, 1 = SCC A, 2 = SCC B; SCC A chosen when NVRAM byte 0 bit 3 (alternate console) is set and no keyboard answers |
| 9 | `$02006006` | `$80` | Ethernet (AT&T 7213) reset; never cleared on Turbo |
| 10 | `$02006004` | &= ~4 | Ethernet TX mode |
| 11 | `boot_cmd(mg, boot_how)` (`sub_0100610c`) | | below |
| 12 | entry | `mon_call_on_stack(mg_mon_stack, entry, mg, console_i, console_o, boot_dev, boot_arg, boot_info, sid<<28, pagesize, 4, &mg_region, etheraddr)` | the NeXT kernel argument list; SR `$2700` |

### boot_cmd (`sub_0100610c`)

Parses `b [device[(ctrl,unit,part)] [filename] [flags]]` against the device
table at `$0101A502` (20-byte entries: name, ops {open, close, load}, devops,
description, 4 animation frames): `en`, `tp`, `sd`, `od`, `fd`. Installs the
level-3 interrupt vector (`$6C`) = `boot_l3_isr` and enables the frame
interrupt: on Turbo, interrupt mask |= `$2000` and TMC `$02200080` =
`$06000000`; the ISR acknowledges with `$05000000` and re-arms with `$06000000`
each frame while stepping the boot animation. Draws the boot picture. Then
`ops.open` in a retry loop (3 s), `ops.load`, and returns the entry point.

* **sd**: `sd_open` resets the ESP, INQUIRY on targets 0..6, START STOP UNIT, TEST UNIT READY loop ("waiting for drive to come ready"), READ CAPACITY; `sd_read` = READ(6) through the SCSI DMA channel (`$02000010` CSR, next/limit at `$02004010/14`), ESP DMA control `$02014020` = `$38` (in) / `$30` (out). The disk label is read from blocks 0/15/30/45 (`'NeXT'` + `dlV2`/`dlV3`, 16-bit checksum), the boot file from label +`$84`, the 1 KB boot block at label `boot_blkno[0..1]` is loaded, its a.out (`$0107`) or Mach-O (`FEEDFACE`) header parsed, and the rest loaded to the load address.
* **en**/**tp**: `enet_init` (32 × 8 KB receive buffers + 1 transmit buffer at the top of the highest bank − `$6000`; RX DMA CSR `$02000150` = `$00940000`, chain, `$00070000`; RX mode `$82`), BOOTP (ports 68→67, vendor "NeXT"), TFTP.
* **fd**: 82077 reset/configure/specify, media id from `$02014108` bits 1:0, autodetect density, same label/boot-block path.
* **od**: probes the Canon MO controller at `$02012000`; with no controller the probe times out after 3,000,000 polls of bit 0 at +4 ("no optical disk").

## Re-entry paths

* **NMI (vector `$7C`)**: if interrupt status bit 31 or TMC NMI register `$02200020` bit 0: `nmi_ack` (KMS `$0200E001` |= `$10`, TMC NMI cleared), `mon_init(reinit=1)` → monitor prompt. If interrupt status bit 30 (parity): prints "parity error: status/address/data" from TMC +`$C`/+`$8`/+`$4` and writes `$02200004` = 0 twice.
* **trap #13 (`$B4`)**: a running program re-enters the monitor with a command string in d0 ("-h" halts, "-x" boots the NVRAM command with extra flags).
* **`$600`**: the return trap handed to booted programs ("Exception #384").
* Any other exception with mg_nofault set resumes at the nofault address (used by every probe); otherwise "Exception #%d (0x%x) at pc 0x%x sp 0x%x" and, for bus errors, "faultaddr 0x%x", then the prompt.

## Monitor prompt

`mon_command_loop`: "NeXT> ", line editor, password gate (NVRAM byte 2 bits
2..5 == 6 enables it; password = NVRAM bytes 4..9 XOR `'N'`), dispatch on
`char - '?'` through the table at `$01011C40`: `?`/`h` help, `P` password,
`R` radix, `S` function code, `a` address regs, `b` boot, `c` continue (rte),
`d` data regs, `e` examine (`moves` with the selected function code), `m` memory
config, `p` parameters (NVRAM), `r` processor regs, `s` system regs (table
`$0101485C` on Turbo, with `%b` bit names; SCR1 redirected to `$02200000`).
