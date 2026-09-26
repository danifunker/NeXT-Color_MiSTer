# NeXT 68040 Turbo boot ROM Rev 3.3 v74 — full disassembly and analysis

Target of this repository: a MiSTer core for the **NeXTstation Turbo Color**
(33 MHz 68040, TMC memory controller, PC peripheral controller, AT&T 7213
Ethernet, Bt463 RAMDAC, 12-bit colour at 1120x832, 2 MB VRAM at `$0C000000`).
`roms/Rev_3.3_v74.BIN` is the ROM that machine runs, and it is the first piece
of software the core has to execute correctly. This directory is the complete
reverse-engineering of it.

Generated from `roms/Rev_3.3_v74.BIN` (131,072 bytes, MD5
`dadf3fb6b6b18b2d325eb42b61d83175`, identical to the copy in Previous's source
tree). Linked at `$01000000`; the first 8 bytes are also the reset vectors at
`$00000000`. Real content ends at `$0101B47F`; the remaining 19 KB is zero.

## Start here

| file | what it is |
|---|---|
| **`ANALYSIS.md`** | the narrative: what the ROM does from reset to boot, what hardware it needs, and what that means for the core. Read this first |
| `boot-sequence.md` | the reset/POST/boot path step by step for machine type 5 (Turbo Color), with every register write in order |
| `hardware-summary.md` | per-device register maps and the exact programming sequences the ROM uses (TMC, ADB, DMA, Ethernet, SCSI, SCC, KMS, RAMDAC, floppy, RTC): the checklist for the RTL |
| `Rev_3.3_v74.asm` | the full listing: every byte of the ROM as code, string, pointer table or hex data, with labels, cross-references and hardware annotations |
| `functions.md` | index of every routine: address, name, size, how it was reached, callers, strings and devices it touches |
| `callgraph.md` | the call tree from reset and the caller/callee table |
| `strings.md` | every string and the routine that uses it |
| `hardware-refs.md` | every absolute device address in the code with the register name from Previous's Turbo I/O table |
| `memory-map.md` | every other absolute address (RAM, VRAM, TMC, NCC, cache) plus the notable 32-bit immediates (patterns, masks, timing constants) |
| `v66-comparison.md` | what changed from the non-Turbo Rev 2.5 v66 ROM (the one the existing NeXT_MiSTer mono core boots) |
| `notes/*.md` | the detailed per-range analysis notes (evidence for everything above) |
| `names/*.py`, `known_names.py` | the routine names, per range and merged |
| `unreached-linear.asm` | linear-sweep disassembly of the bytes the descent did not reach (tables, and any code reached only through computed jumps) — speculative, for lookup |
| `disasm_rom.py`, `merge_names.py` | the generator and the name merger |
| `ANALYSIS-BRIEF.md` | the brief the per-range analyses were written against |

## Regenerating

Needs Python 3 and `capstone` (5.x), and the Previous source tree for the I/O
names (`PREVIOUS_SRC`, default `../previous-code-r1851-trunk/src`). From the
repository root:

```bash
python rom-dissassembly/merge_names.py
```

```bash
python rom-dissassembly/disasm_rom.py
```

Add or fix names in `names/*.py` (one file per 8 KB range), never in the
generated files.

## How it was produced

Recursive descent with Capstone (M68K, 68040 mode) from the reset vector, from
every longword in the image that is an even address inside the ROM (the C
function-pointer tables the monitor is built from: the `mg` globals, the
command tables, the exception stubs), and from every C prologue (`link a6,#n`
after `rts`/`unlk`/`nop`/`jmp`) the descent had not reached. Capstone 5 does
not decode the 68040 MMU/cache instructions (`pflusha`, `ptest`, `move16`,
`fsave`/`frestore`, some `cinv`/`cpush`), so `decode040()` handles those;
without it the descent stalls at the first `pflusha` in the reset path.
Strings are found before the descent (long ones) and after it (short ones) so
code never runs into text and text is never decoded as code. Pointer targets
that begin with a zero word are treated as data (that is how the small
bus-error vector tables at `$010145B0`/`$010145BC` are kept out of the code).
Everything reached is code; everything else is data. Routine names identified
in the v66 disassembly were ported automatically where the code is byte
identical, then the rest were named by hand from the per-range analyses.

## Conventions

```
address   bytes             mnemonic operands              ; notes
010004e2  20390200c000      move.l   $200c000.l, d0        ; $0200c000 = System Control Register 1: SCR1
```

* `sub_XXXXXXXX` — a `bsr`/`jsr` target, a pointer-table target that decodes as code, or a C prologue.
* `loc_XXXXXXXX` — a branch target inside a routine (or a block reached only by jumps).
* `str_XXXXXXXX` — a string; the referencing instruction shows the text in its note.
* `dat_XXXXXXXX` — data referenced by an absolute operand or a pointer table.
* Named labels come from `known_names.py`.
* Capstone prints branch targets and PC-relative operands as absolute addresses; ROM addresses are replaced by their labels.
* Operands naming a device register carry `; $0200c000 = ...` from Previous's Turbo I/O table plus the TMC/ADB register names from `tmc.c`/`adb.c`. Accesses through an address register (the usual C idiom, `movea.l #$2000040,a0` then `(a0)`) are annotated only at the instruction that loads the base.
* Before each labelled routine: `; called from:`, `; jumped to from:` and `; pointer table entries at:` list the cross-references.

## ROM header

| offset | value | meaning |
|---|---|---|
| `+0` | `$04000400` | initial SSP (1 KB into DRAM bank 0; the reset code does not use it, it builds its own stack in VRAM) |
| `+4` | `$0100001E` | initial PC = `reset_entry` |
| `+8` | `00 00 0F 12 34 56` | Ethernet MAC address (placeholder; the real one is programmed per board. Previous's `rom.c` patches bytes 3..5) |
| `+0xE` | 0 | |
| `+0x12` | 0 | |
| `+0x16` | `$187800A7` | CRC-32 (IEEE, `$04C11DB7`, `zlib.crc32` compatible) of bytes 0..21 |
| `+0x1A` | `$25DD9617` | CRC-32 of bytes `0x1E`..end (the whole code body including the zero tail) |

Both CRCs verify. The reset path recomputes both (`sub_01004156`) before it
trusts the ROM; a mismatch ends in the LED-blink halt path. **A modified ROM
image must have both CRCs fixed** or the machine will not boot.

## Landmarks

| address | label | |
|---|---|---|
| `0100001e` | `reset_entry` | vbr = bus-error-only table, `cinva`, into the pre-stack init chain |
| `01000c68` | `loc_01000c68` | MMU: TC=0, ITT1/DTT1 = `$00FFC000` (everything transparent, cacheable), ITT0/DTT0 = `$0200C040` (`$02xxxxxx` device space transparent, cache-inhibited serialized), `pflusha`, TC = `$C000` (enable, 8 KB pages) |
| `010000e0` | | machine-type dispatch on SCR1 bits 15:12 (see `ANALYSIS.md`) |
| `010002b4` | | Turbo path: TMC control register, ADB masks, TMC video timing |
| `010003cc` | | interrupt mask cleared, ROM CRC checks |
| `0100042e` | | pick VRAM base by machine type, stack = VRAM + `$3F800`, globals struct, vectors at + `$400` |
| `010005ae` | | common exception entry (all 256 vectors point here) → `sub_010018d4` |
| `010018d4` | | C exception / monitor dispatcher; the "reset" pseudo-vector `$700` runs initialisation, POST and boot |
| `01000ec6` | | globals and device-pointer initialisation, DRAM sizing, NVRAM |
| `01004156` | | CRC-32 |
| `010145c8` | | system-register name table (`s` command) |
| `010148c0` | | configuration-parameter table (`p` command) |
| `01014cd8` | | monitor help text |

Statistics and the remaining landmarks are in `ANALYSIS.md`.
