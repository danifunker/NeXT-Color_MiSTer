> **Corrections found during the analysis** (the text below is the original brief):
> * On colour machine types (3, 5, 7, 9, B) the initial stack, globals and vectors go into the first
>   working DRAM bank (bank + $800 / + $C00), not VRAM. VRAM + $3F800 is the mono path.
> * `mg+$194 == $139` means "original (non-Turbo, types 0..2) memory system" (NetBSD `MG_dmachip`);
>   Turbo Color has 0 there, so every `cmpi.l #$139` picks the TMC/colour path on the `bne` side.
> * The five function pointers at mg+$2D6.. are getc, try_getc, putc, alert (`mon_boot_error`) and alloc.
> * The tables at $010145C8 / $0101467C are register-descriptor tables for the `a`/`d`/`s` commands,
>   the parameter table is at $010148C0, and the command dispatch table is at $01011C40 (index = char - '?').

# Analysis brief for the Rev 3.3 v74 ROM disassembly

Read this before working on any part of the listing. It records what is already
established so every analyst starts from the same facts and writes results in
the same shape.

## The target

`roms/Rev_3.3_v74.BIN`, 131,072 bytes, the final NeXT 68040 "Turbo" boot ROM
(NeXT ROM Monitor 3.3, v74). It runs on every 68040 NeXT (the monitor checks
the machine type at run time), but this project targets the **NeXTstation Turbo
Color** (33 MHz 68040, TMC memory controller, PC peripheral controller, Bt463
RAMDAC, 12-bit colour 1120x832, 2 MB VRAM at `$0C000000`). Turbo-specific paths
are what matter most; non-Turbo paths (BMAP chip, NBIC, MWF mirrors) should be
identified so they can be ignored.

ROM is linked at `$01000000` and aliased at `$00000000` at reset. Real content
ends at `$0101b47f`; the rest is zero.

## Files

| file | content |
|---|---|
| `Rev_3.3_v74.asm` | the listing. Labels `sub_`/`loc_`/`str_`/`dat_`, cross-references before each label, device annotations after `;` |
| `functions.md` | one row per routine: address, size, how it was reached, callers, strings it references, devices it touches |
| `strings.md` | every string with the routine that first references it |
| `hardware-refs.md` | every absolute device address used, with Previous's register name |
| `memory-map.md` | every other absolute address (RAM, VRAM, TMC, NCC, cache) and the notable immediates |
| `unreached-linear.asm` | linear sweep of bytes the descent did not reach (mostly tables) |
| `disasm_rom.py` | generator. Do not edit it. Names go in `known_names.py` (see "Deliverables") |

Reference sources (read-only, do not modify):

* Previous emulator, `C:\Temp\mistercore\previous-code-r1851-trunk\src\`:
  `ioMemTabTurbo.c` (Turbo device map), `tmc.c` (TMC regs, SCR1 layout), `adb.c`
  (ADB regs at `$02208000`), `ramdac.c` (Bt463), `dma.c` (TDMA CSR bits at line 77-110 and 1098-1110),
  `ethernet.c` (AT&T 7213 Turbo differences), `sysReg.c` (SCR2 bits at line 313-335, interrupt bits in
  `includes/sysReg.h`), `rtcnvram.c` (NVRAM byte layout at line 880-950, RTC regs), `esp.c`
  (NCR 53C90), `floppy.c`, `scc.c`, `kms.c`, `cpu/memory.c` (memory map, line 40-190).
* `C:\Temp\mistercore\NeXT_MiSTer\rom-disassembly\` : the same analysis for the older
  non-Turbo ROM v66 (`Rev_2.5_v66.asm`, `functions.md`). About 60 % of v74's code is byte-identical
  to v66 code, so a routine you cannot place may be findable there.
* `C:\Temp\mistercore\previous-code-r1851-trunk\src\ROMV66-0001E-02588.ASM`: a hand-annotated
  v66 listing with occasional comments.

Do not download anything.

## Machine identification (established from the reset path)

SCR1 (`$0200C000`, or the TMC copy at `$02200000` on Turbo boards) bits 15:12 give the
machine type. The reset code branches on it (`$010000e0`):

| type | machine | notes |
|---|---|---|
| 0 | NeXT Computer (68030 cube) | BMAP path |
| 1 | NeXTstation mono (non-Turbo) | BMAP path |
| 2 | NeXTcube 040 (non-Turbo) | BMAP path |
| 3 | NeXTstation Color (non-Turbo) | colour VRAM at `$2C000000` |
| 4 | Turbo mono station | TMC; SCR1 re-read from `$02200000` when type reads 4 |
| 5 | **Turbo Color station (our target)** | TMC, VRAM `$0C000000` |
| 6, 7 | Turbo variants (mono / colour) | same paths as 4 / 5 |
| 8 | Turbo cube | mono timings |
| 9, 0xA, 0xB | Turbo variants | 9, 0xB colour; 0xA mono |

The reset code keeps the raw SCR1 in `isp` and the machine type in `msp` until the
stack exists. Colour Turbo types are 5, 7, 9, 0xB; mono Turbo types are 4, 6, 8, 0xA.

TMC video timing written at reset (`$01000380`/`$0100039a`):
colour = horizontal `$165A10D0`, vertical `$10412270`; mono = `$6302F118` / `$00438340`.

ROM header: `+0` SSP `$04000400`, `+4` PC `$0100001E`, `+8` Ethernet MAC (6 bytes,
`00:00:0F:12:34:56` placeholder), `+0x16` CRC-32 of bytes 0..21, `+0x1A` CRC-32 of bytes
`0x1E`..end. Both verified. The reset path checks both (`$010003cc`..`$0100042e`).

## The monitor globals struct ("mg")

The ROM is C code built around one global structure, the NeXT "mon_global" (NetBSD's
`next68k/nextrom.h` documents a version of it). It is created on the initial stack in
VRAM (`VRAM + $3F800`, see `$010004d0`; exception vectors at `+ $400` of it) and is later
re-created in DRAM. Most C routines get a pointer to it as an argument and keep it in
`a3`, `a4` or `a5`. Field offsets seen so far (from `$010004d0`, `$01000514`, `$01000ec6`):

| offset | size | field | evidence |
|---|---|---|---|
| +0 | byte | mg_simm (SIMM config byte) | `move.b #$14,(a3)` |
| +4 | byte | mg_flags | `clr.b $4(a7)` at start |
| +6 | long | mg_sid (slot id = SCR1 >> 28) | `move.l d2,$6(a7)` |
| +0xA | long | mg_pagesize = 0x2000 | `move.l #$2000,$a(a3)` |
| +0xE | long | mg_mon_stack | |
| +0x12 | long | mg_vbr | |
| +0x16 | 32 bytes | mg_nvram (copy of the RTC NVRAM, layout in rtcnvram.c) | `lea $16(a3),a4` |
| +0x36 | 18 | mg_inetntoa | (by NetBSD layout, unverified) |
| +0x48 | 128 | mg_inputline | (unverified) |
| +0xC8 | 4 x 8 | mg_region[4] {base, size} | (unverified) |
| +0xE8 | long | mg_alloc_base | `move.l d2,$e8(a3)` |
| +0xEC | long | mg_alloc_brk | |
| +0x194 | long | compared with 0x139 | unknown |
| +0x19C | long | pointer to interrupt status reg `$02007000` | |
| +0x1A0 | long | pointer to interrupt mask reg `$02007800` | |
| +0x2D6..+0x2EA | 5 longs | function pointers (`sub_01008140`, `sub_01008184`, `sub_010081c8`, `sub_0100ab7c`, `sub_01007dd6`): console getc/putc/alert etc. | |
| +0x2F2 | long | pointer to event counter `$0201A000` | |
| +0x30A | word | 3 (ROM major) | "NeXT ROM Monitor %d.%d (v%d)" |
| +0x30C | word | 0x4A = 74 (ROM version) | |
| +0x312 | word | 3 (ROM minor) | |
| +0x314 | long | pointer to Ethernet address in ROM header (`$01000008`) | |
| +0x3A8 | byte | machine type (SCR1 bits 15:12) | |
| +0x3AA | long | function pointer `sub_010008e2` | |
| +0x3AE | long | flags word (bit 31, 28, 4 used) | |
| +0x3B2 | long | pointer to BMAP `$020C0000` (non-Turbo) | |
| +0x3BA, +0x3C2 | long | ? | |
| +0x3CA | long | pointer to NCC `$02210000` | |
| +0x3CE | long | pointer to cache tag RAM `$03E00000` | |

Fix these names where the code proves otherwise and add the ones you find.

## Reset flow (established)

1. `reset_entry $0100001e`: vbr = small ROM table (bus-error vector only), BMAP reg cleared, `cinva`, jump to `loc_01000c68` with a0 = continuation (the pre-stack code uses `jmp (aN)` continuations because there is no stack yet).
2. `$01000042`..`$010002a6`: CACR, machine-type dispatch, non-Turbo BMAP setup or, for Turbo, TMC control register, ADB masks cleared, TMC video timing.
3. `$010003cc`: interrupt mask cleared, ROM CRC check (`loc_0100418e` = CRC-32 routine `sub_01004156`, polynomial `$04C11DB7`), failure goes to `loc_010040ec` (LED blink / halt path).
4. `$0100042e`: pick VRAM base by machine type (`$0C000000` for Turbo colour), stack = VRAM+`$3F800`, `sub_01003ca4` probe, mg struct zeroed, vbr = mg+`$400`.
5. `$01000556`: all 256 vectors = `loc_010005ae` (the common exception entry: saves regs and control regs into a frame, calls `sub_010018d4` = the C exception/monitor dispatcher, restores, `rte`). A fake frame with vector offset `$700` is pushed so the first entry into `sub_010018d4` is the "reset" pseudo-exception; `$704` is used by `sub_01000660` for re-entry.
6. `sub_010018d4` runs the C initialisation: `sub_01000ec6` (device pointers, DRAM sizing, NVRAM read, console setup), POST, boot.

## Deliverables (per assigned address range)

Write two files and nothing else:

1. `rom-dissassembly/names/<range>.py`: a Python dict literal

   ```python
   KNOWN = {
       0x01001234: ("nvram_read", "read 32 bytes of RTC NVRAM into mg_nvram; returns checksum ok in d0"),
   }
   ```
   One entry per routine (or important loc_) you can name with reasonable confidence.
   Names: lowercase, underscores, verb-first for routines (`scsi_select`, `print_hex`),
   prefix by subsystem (`tmc_`, `adb_`, `dac_`, `scsi_`, `enet_`, `fd_`, `scc_`, `kms_`,
   `mem_`, `post_`, `mon_`, `boot_`, `tftp_`, `nvram_`, `rtc_`, `dma_`, `vid_`).
   Do not rename `reset_entry` or the already ported `post_*` names (you may improve their notes).
   Keep the note under 120 characters; put detail in the markdown instead.

2. `rom-dissassembly/notes/<range>.md`: what each routine does, with the evidence:
   arguments (stack offsets), return value, mg fields it uses, hardware registers and bit
   values it writes (this is the most valuable part for the FPGA core: every register write
   with its value and the order of writes), strings it prints, callers/callees, and which
   machine types the code path applies to. Mark anything that is Turbo-Color specific.
   Flag uncertainty explicitly. Note any place the descent mis-decoded data as code or missed code
   (give the address) so the generator can be fixed.

Rules: do not edit the listing, the generator or any file outside your two deliverables.
Do not download anything. Prefer reading the listing with `awk '/^sub_XXXXXXXX:/{f=1} f{print} /^sub_YYYYYYYY:/{if(f)exit}' Rev_3.3_v74.asm`
or `sed -n` on line ranges; the file is 32k lines, so never `cat` it whole.
