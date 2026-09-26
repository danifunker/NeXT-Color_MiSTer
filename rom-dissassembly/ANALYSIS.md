# What the v74 ROM does, and what the Turbo Color core has to provide

This is the narrative summary of the disassembly. Every claim has its evidence in
`notes/<range>.md`; the register-level checklist is `hardware-summary.md`; the
step-by-step path is `boot-sequence.md`.

## The ROM in one paragraph

Rev 3.3 v74 is one 128 KB image for every 68040 NeXT. At reset it identifies the
board from SCR1 bits 15:12 (Turbo Color = 5) and from which writes bus-error (no
BMAP means Turbo; no NCC means no Nitro cache). It configures the 68040 with
transparent translation so that everything except `$02xxxxxx` device space is
cached, programs the TMC (control word, ADB masks, video timing), checks its own
two CRC-32s, finds the first working 32 MB DRAM bank and builds its C runtime
there: a `$48E`-byte globals struct ("mg"), a 1 KB vector table where all 256
entries point at one common exception stub, and a stack. From then on it is C
code entered through a fake "reset" exception: initialise the machine, size and
optionally test memory, initialise the ADB keyboard and mouse, run the power-on
self test if enabled, relocate the runtime to the top of DRAM, print the banner
on a 1120x832 16-bit colour console it draws itself through a Bt463 RAMDAC, and
either sit at the `NeXT>` monitor prompt or boot: SCSI disk, optical disk,
floppy, or the network (BOOTP + TFTP). Booting means reading a NeXT disk label,
loading the boot block, parsing an a.out or Mach-O header and jumping to it with
the NeXT kernel argument list.

## Numbers

| | |
|---|---|
| image | 131,072 bytes, content to `$0101B47F` |
| code | 72,252 bytes, 21,286 instructions, 664 routines (662 named) |
| strings | 271, 6,635 bytes |
| data | tables, images, fonts, keymaps: about 33 KB (`notes/01012c00.md` maps all of it) |
| byte-identical to v66 | at least 55 KB (see `v66-comparison.md`) |
| pointer-table / jump-table entries | 2,700 |

## Structure of the image

| range | content |
|---|---|
| `$01000000`..`$0100001E` | header: SSP, PC, MAC address, two CRC-32s |
| `$0100001E`..`$01000C68` | pre-stack reset code, continuation-style (`jmp (aN)`); BMAP DRAM sizing (non-Turbo only) |
| `$01000C68`..`$01001DFC` | MMU setup, machine init (`mg_init_machine`), `mon_init`, the exception dispatcher `exc_dispatch` |
| `$01001DFC`..`$01002C40` | monitor command loop, commands, parameter (`p`) and register (`a`/`d`/`r`/`s`) handlers |
| `$01002C40`..`$01004208` | DRAM configuration/sizing/parity probe and full tests, VRAM tests, LED halt, CRC-32 |
| `$01004208`..`$010047AC` | image drawing (2 bpp and 16 bpp), boot panel |
| `$010047AC`..`$01006122` | POST: FPU, SCC, SCSI, extended SCSI, Ethernet, ECC (cube only), RTC, timer, event counter, sound out, NCC cache |
| `$01006122`..`$01007B56` | boot command parser, device table, boot ISR and animation, kernel image loader, BOOTP/TFTP/ARP/IP, printf |
| `$01007B56`..`$0100816E` | console line editor, number parsing, allocator, string/memory utilities |
| `$0100816E`..`$01009962` | console callbacks, SCC driver, RTC/NVRAM bit-bang, timers, AT&T 7213 Ethernet driver |
| `$01009962`..`$0100B976` | banner panel, KMS keyboard, text console, keymaps use, NextBus slot scan (cubes) |
| `$0100B976`..`$0100DDFA` | display drivers (colour 1120x832, colour 832x624, mono), Bt463 programming, brightness, ADB driver, alternate TMC timings, SCSI driver core |
| `$0100DDFA`..`$01011B5A` | SCSI phases, SCSI disk ops, generic DMA helpers, disk label and boot-block loader, Canon MO driver, 82077 floppy driver |
| `$01011B5A`..`$01012C00` | switch jump tables and a 256-byte gamma ramp |
| `$01012C00`..`$01014600` | register-name strings and bit descriptors, then the message strings |
| `$010145B0`..`$01014CD8` | vbr stub tables, register and parameter tables, SIMM tables, MHz/ns tables, memory timing table |
| `$01014CD8`..`$0101B480` | help text, 18 images (icons, logo, animation frames), SCC init list, sound-test sine table, boot animation script, boot device table, font metrics, parity table, keymaps, 8x12 font, display driver table, brightness LFSR table, ADB tables, MO and floppy device records |

## How the ROM is organised as a program

* **One global struct.** Every C routine takes or finds the `mg` pointer (kept at
  vbr+4). The proven layout is in `notes/01000000.md` section 3 and in the
  ADB/video/SCSI notes; it matches NetBSD's `mon_global` (`nextrom.h`) in the
  early fields (pagesize at +`$A`, NVRAM copy at +`$16`, region table at +`$C8`,
  allocator at +`$E8`) and extends it with the Turbo fields (+`$194` "original
  memory system" flag, +`$3A8` machine type, +`$3B6` is_station, +`$3BA` memory
  generation, +`$3CA` NCC, +`$3E6` ADB devices).
* **One exception entry.** All 256 vectors point at `exc_common_entry`, which
  saves the full register set and calls `exc_dispatch`. The ROM's own control
  flow uses fake exception frames: `$700` = cold start, `$704` = device init and
  boot, `$600` = "program returned", `$B4` = trap #13 re-entry from a running OS,
  `$7C` = NMI (the ADB `cmd+alt+backquote` combination raises it through the TMC
  NMI register). Probing code sets `mg_nofault`; any exception then resumes there.
* **Continuations before the stack exists.** The pre-stack code passes its next
  step in an address register and uses bus errors as boolean tests: the write to
  BMAP `$020C0008` must fault on a Turbo board, the write to NCC `$02210000` must
  fault without a Nitro board. The core must implement these faults, not ignore
  the writes.
* **Polling, not interrupts, for input.** ADB is polled (TALK addr 2 reg 0 every
  8 ms), KMS is polled, SCSI is polled through the interrupt status register bit
  12 with `scsi_intr` called in a loop. Only three interrupts are actually taken:
  the level-3 frame interrupt during boot (TMC video interrupt register), the
  level-6 hardclock interrupt during the timer POST, and level 7 for NMI/parity.

## The machine the ROM expects (Turbo Color)

Summarised from `hardware-summary.md`; that file has values and order.

1. **CPU**: 68040 at 33 MHz with working ITT/DTT transparent translation, `cinva`,
   `cpusha`, `pflusha`, `movec` of `isp`/`msp`/`vbr`/`cacr`/`sfc`/`dfc`/`tc`, `moves`
   with function codes (the `e` command), FPU present (the POST FPU test uses
   `fmovem`, format conversions, `fsave`/`frestore`). The ROM keeps the data cache
   in copyback for VRAM and pushes it after drawing (`vid_unlock` does `cpusha`).
2. **ROM** at `$01000000`, aliased at 0 for the first fetch; the code body CRC is
   checked, so patched images need both CRCs recomputed.
3. **SCR1** at `$0200C000` and its TMC copy at `$02200000` reading type 5, cpu speed 7,
   a memory speed code; board revision in bits 11:8. **SCR2** at `$0200D000`: LED
   bit 0, RTC bit-bang bits 8..10, DSP reset bit 31, and byte 2 bit 4 (bit 12 of
   the longword) = 1, which selects the 1120x832 driver and skips the reset-time
   832x624 TMC timing write.
4. **Interrupt status/mask** at `$02007000`/`$02007800` with the Turbo bit
   assignment (`INT_SCSI` bit 12, video/`INT_DISK` bit 13, `INT_EN_RX_DMA` bit 27,
   timer bit 29, parity bit 30, NMI bit 31).
5. **TMC** at `$02200000`: SCR1 copy, control `$02200010` (the ROM writes
   `$0DF4838F`), parity registers +`$4`/+`$8`/+`$C`, NMI +`$20`, video interrupt
   +`$80` (`$04000000` enable, `$06000000` enable+int, `$05000000` ack),
   horizontal/vertical timing +`$88`/+`$8C`. Bit 3 and bit 10 of the control word
   are touched by the parity probe.
6. **DRAM**: banks at `$04000000`, `$06000000`, `$08000000`, `$0A000000`; each bank
   a SIMM pair sized by aliasing (`$12345678` at +0, `$89ABCDEF` at +`$800000`,
   `$ABCDEF01` at +`$200000`). A 32 MB bank must not alias; absent banks must
   fail the `$55555555`/`$AAAAAAAA` test cleanly (bus error or wrong data).
7. **VRAM**: 2 MB of 16-bit pixels at `$0C000000`, `RRRRGGGGBBBBxxxx`, 2240 bytes
   per line, tested with masks `$FFF0FFF0`; the ROM writes it with `move16`-free
   longword stores through the copyback cache.
8. **Bt463** at `$0201C000` (address low, address high, register data, palette
   data): the programming order is CR0 `$40`, CR1 `$00`, CR2 `$80`, read masks
   `$F0`, blink masks 0, 16 window-type entries `$000100`, 256 palette entries
   from the gamma table scaled by NVRAM brightness (mirrored to 256..511), overlay
   entries `$FF`.
9. **ADB** through the TMC window `$02208000` with the register set Previous
   models (INTSTATUS, INTMASK, CONFIG, CTRL, STATUS, CMD, COUNT, DATA0/1); the
   keyboard is expected at address 2, the mouse at 3, both moved to handler 3.
10. **PC-chip DMA** with the Turbo CSR bit set (`RESET $100000`, `BUFRESET
    $800000`, `SETENABLE $10000`, `SETSUPDATE $20000`, `DEV2M $40000`), channels
    SCSI `$02000010`, sound out `$40`, sound in `$80`, printer `$90`, DSP `$D0`,
    Ethernet TX `$110`, RX `$150`; next/limit/start/stop at CSR+`$4000`.. and a
    2-descriptor chain for every transfer.
11. **AT&T 7213 Ethernet** at `$02006000` (used through the `$02106000` mirror),
    reset by `$80` to +6, TX/RX status, mask and mode bytes with the Turbo
    semantics, the 6 node-ID bytes, the RX ring of 32 × 8 KB buffers and the
    saved-limit register `$02004050`.
12. **NCR 53C90** at `$02014000` with the SCSI DMA control register `$02014020`
    (`$02`/`$20`/`$22` reset, `$30` out, `$38` in, `$3C` pulse) and config
    `$57`/`$17`, clock conversion 5, select timeout `$99`.
13. **Z8530 SCC** at `$02018000` with clock select `$02018004` = `$0A`, channel A as
    the optional console at 9600 baud.
14. **RTC (MCCS1850 or MC68HC68T1)** bit-banged through SCR2 with the 32-byte NVRAM
    layout Previous documents; the ROM writes it back when it changes the SIMM
    word, brightness, boot command or test codes.
15. **82077 floppy** at `$02014100` with the external control/status byte at
    `$02014108` (bit 6 selects the 82077, bits 1:0 media id, bit 2 no drive).
16. **KMS/sound** at `$0200E000`: used for the sound-out POST, the reboot magic
    (`$C6` `$1000A825`) and volume; on a Turbo Color with ADB the keyboard path
    goes through ADB, but the KMS status bits are still read.
17. **Hardclock** `$02016000` and the 20-bit microsecond counter `$0201A000`: every
    delay in the ROM is derived from the counter, and the timer POST expects a
    1000 µs periodic interrupt on level 6.
18. **Things that may be absent** if they fail the way the ROM expects: BMAP (bus
    error), NCC (bus error), NBIC/NextBus (skipped on stations because
    `is_station` = 1), the Canon MO controller (`$02012004` bit 0 reads 0 forever),
    DSP (only SCR2 bit 31 is touched), printer.

## Reading the listing

Names follow subsystem prefixes (`tmc_`, `adb_`, `dac_`, `vid_`, `scsi_`, `sd_`,
`od_`, `fd_`/`fc_`, `enet_`, `net_`, `scc_`, `kms_`, `rtc_`/`nvram_`, `dma_`,
`mem_`, `post_`, `mon_`, `boot_`, `exc_`). Each labelled routine is preceded by
its callers, jump sources and pointer-table references; `callgraph.md` gives the
tree from `reset_entry`. `functions.md` lists for every routine the strings it
prints and the devices it touches, which is the quickest way to find "who writes
this register": `hardware-refs.md` is the inverse index.

## Known gaps and uncertainties

* Bt463 CR0/CR1/CR2 bit semantics are taken from the datasheet only; Previous
  just stores them.
* The meaning of TMC control bit 3 (cleared when a non-parity bank is present)
  and of SCR2 bit 12 (skips the reset-time TMC timing write) is not established.
* TMC timings, resolved while consolidating: the horizontal/vertical display fields are in
  4-pixel units. The reset-time colour values (`$165A10D0`/`$10412270`) are the 832x624
  mode, and the SCR2 bit that skips that write (bit 12 of the longword = byte 2 bit 4) is
  the same bit that selects the 1120x832 driver. A Turbo Color core that presents that bit
  as 1 therefore never receives a TMC timing write from the ROM: the TMC's power-on timing
  must already be 1120x832 (Previous defaults `$31048118`/`$10430340`). The ADB-keyboard
  alternate values (`$29044118`/`$021A0340`) are 1120x832 as well (280 x 4 = 1120, 832 lines).
* `mg+$374`: visible or off-screen frame buffer (two notes disagree).
* The MO controller register names are inferred from Previous's non-Turbo model.
* Struct field names not present in the ROM (there are no symbols) are
  reconstructions; NetBSD's `nextrom.h` would confirm the `mg` field names
  (not fetched: no downloads without approval).
