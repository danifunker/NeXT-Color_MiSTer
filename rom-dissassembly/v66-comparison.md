# Rev 2.5 v66 (NeXTcube 68040, non-Turbo) versus Rev 3.3 v74 (Turbo)

v66 is the ROM the existing `NeXT_MiSTer` mono core boots; its disassembly is in
`C:\Temp\mistercore\NeXT_MiSTer\rom-disassembly\`. v74 is this ROM. The comparison
below was produced from both listings, both string tables and a byte-level alignment
of the two images (16-byte windows). Full evidence: `notes/01012c00.md`, section 6.

What it means for the core: about half of v74 is byte-identical to v66 (the monitor,
printf/console, SCSI/optical/floppy drivers, images, fonts, keymaps), so the mono core's
experience with those paths carries over. Everything new is exactly the Turbo hardware:
the TMC reset path, Turbo memory sizing with 32 MB SIMM pairs and parity, the NCC cache
tests (Nitro only), the AT&T 7213 Ethernet driver, the ADB keyboard/mouse driver and the
Bt463 colour console backend, and the PC-chip DMA differences (`BUFRESET` instead of
`INITBUF`, TDMA "saved limit").

## v66 (Rev 2.5, NeXTcube 68040) versus v74

### 6.1 ROM header

| field | v66 | v74 |
|---|---|---|
| +0 initial SSP | `00000000` | `04000400` (RAM bank 0 + 0x400) |
| +4 initial PC | `0100001e` | `0100001e` |
| +8 MAC | `00:00:0f:00:f3:02` | `00:00:0f:12:34:56` (placeholder; the ROM checks bytes 3..5 against FF FF FF, see 5.7) |
| +0x16 CRC of 0..0x15 | `49730056` (verified) | `187800a7` (verified) |
| +0x1a CRC of 0x1e..end | `f7e91820` (verified) | `25dd9617` (verified) |
| content end | `010170a0` (94 KB) | `0101b480` (109 KB) |
| first instruction | `move.l #0,$020c0008` (BMAP) | `lea dat_010145b0,a0; movec a0,vbr` then the same BMAP write |

### 6.2 Version numbers
"NeXT ROM Monitor %d.%d (v%d)" is printed by `sub_01009a2c` (v74 `$01009a58`, v66 `$01008432`)
as `printf(fmt, mg+$312, mg+$30a, mg+$30c)` (v74 pushes the immediates 3, 3, 0x4A when
`a4 == 0`). The fields are initialised in `sub_01000ec6`:

| | v74 `$01000f5c` | v66 `$01000c4e` |
|---|---|---|
| `mg+$312` (major) | 3 | 2 |
| `mg+$30a` (minor) | 3 | 5 |
| `mg+$30c` (v-number) | 0x4A = 74 | 0x42 = 66 |

so v66 = "2.5 (v66)", v74 = "3.3 (v74)". (The brief's table has +$30A and +$312
swapped; v66 shows +$312 is the major number.)

### 6.3 Strings only in v74 (from the two `strings.md`)
Turbo / NCC / new-board features:
* memory: "32MB of page mode", "32MB of parity page mode" (Turbo SIMM pairs), "Memory sockets %d and %d (%s) have %s SIMMs installed (0x%x-0x%x)", "Memory sockets %d and %d (%s) configured for %s SIMMs but have %s SIMMs installed.", "back", "front" (Turbo front/back SIMM sockets), all SIMM names re-worded with "of" ("16MB of nibble mode" instead of "16MB nibble mode");
* cache (NCC / Nitro): "Secondary Cache ram Test Fail", "Secondary Tag ram Test Fail", "\nCache RAM selftest failure\n", "Memory error at location: 0x%x", "Value at time of failure: 0x%x", "Expected: 0x%x     Received: 0x%x", "\nCache tag selftest failure.\n";
* parity memory: "\nparity error: status 0x%x, address 0x%x, data 0x%x\n";
* banner split into three strings: "%d MHz, memory %d nS\n", "Backplane slot #%d\n", "Ethernet address: %x:%x:%x:%x:%x:%x\n" (one string in v66);
* exceptions: "Exception #%d (0x%x) at pc 0x%x sp 0x%x\n", "faultaddr 0x%x\n" (v66: "Exception #%d (0x%x) at 0x%x\n");
* Ethernet (AT&T 7213 register interface of the Turbo): "enreg_read failed", "enreg_write failed", "[boot]";
* DMA: "dma_start: bad DMA buffer alignment"; floppy: "Sony MPX-111N" (drive record); "cspd" (SCR1 descriptor field), and the new interrupt/SCR bit-descriptor set.
* no ADB or colour/RAMDAC strings exist — those subsystems print nothing.

### 6.4 Strings only in v66
"boot extended diagnostics" (the BOOT_POT parameter, dropped), the un-"of" SIMM names
("16MB nibble mode" .. "1MB parity page mode (illegal)"), the combined banner string,
"Exception #%d (0x%x) at 0x%x\n", "SCSI unaligned DMA segment", "SCSI unaligned DMA",
"dma_list: bad alignment".

### 6.5 Tables
* v66 has a single system-register table (`010105b0`) with the old bit descriptors; v74 keeps it as `tbl_sysreg_old` and adds `tbl_sysreg_new` (selected by `mg+$194`).
* v66 parameter table (`01010614`) = v74 `tbl_params` plus "boot extended diagnostics" (0x20) after "verbose test mode"; handlers at v66 `01002058/010020f2/01002220/01002190`.
* The memory-timing table, help text, images, sine table, fonts and keymaps are byte-identical (see the alignment runs `01014af8-01014cd8`, `01014cd8-01015030`, `01015496-0101a354` (20 KB), `0101a978-0101b07c`).

### 6.6 Code alignment
Byte-identical 16-byte windows (merged when the shift is the same and gaps are
< 256 bytes, runs >= 384 bytes) cover 55 KB of v74's 109 KB; since absolute
string/table addresses differ, this is a lower bound on the shared code. The large
runs, which give the module order in both ROMs:

| v74 | v66 | shift | bytes | content |
|---|---|---|---|---|
| 010007c6-01000a3a | 01000576-010007ea | -592 | 628 | early reset helpers (CRC, LED blink) |
| 01001dfc-01001fdc | 01001770-01001950 | -1676 | 480 | monitor command loop |
| 010027de-01002c40 | 01002054-010024b8 | -1930 | 1122 | `p` handlers, help |
| 01004208-010047ac | 010025cc-01002b70 | -7228 | 1444 | image drawing (`vid_draw_image`, U/S decoders) |
| 0100489e-01004a42 | 010031f2-01003396 | -5804 | 420 | SCC POST |
| 01006122-01006322 | 0100527a-0100547a | -3752 | 512 | boot device parsing |
| 01006a3c-0100713c | 01005a5a-0100614c | -4066..-4080 | 1742 | boot loader, BOOTP/TFTP |
| 0100743c-01007ac6 | 0100643c-01006ac4 | -4096..-4098 | 1626 | big-font text, printf |
| 01007b56-0100816e | 01006b32-0100714a | -4132 | 1560 | console I/O, string utils |
| 01008274-01008766 | 01007252-01007744 | -4130 | 1266 | RTC/NVRAM, timers |
| 01009962-01009fe6 | 0100833c-010089c0 | -5670 | 1668 | monitor banner, keyboard |
| 0100a3c4-0100ac8c | 01008cee-010095b6 | -5846 | 2244 | keymap, console font rendering |
| 0100adf0-0100b976 | 010096dc-0100a262 | -5908 | ~1900 | console backends (non-ADB part) |
| 0100ddfa-0100e86e | 0100a980-0100b404 | -13392..-13434 | 2090 | SCSI (53C90) driver |
| 0100ec42-0100f9a0 | 0100b726-0100c48c | -13588..-13596 | 2910 | disk label, optical driver |
| 0100fad4-01010e86 | 0100c5c0-0100d972 | -13588 | 4880 | optical + floppy driver |
| 01011180-010115d4 | 0100dc5c-0100e0b0 | -13604 | 1108 | floppy controller |
| 01012c00-01012e18 | 0100ed58-0100ef70 | -16040 | 536 | register-name strings and descriptors |
| 01014022-010145a8 | 0100fe06-01010380 | -16924..-16936 | 1354 | SCSI/optical/floppy strings |
| 010145e0-010147d0 | 01010398-01010588 | -16968 | 496 | register tables |
| 01014af8-01015030 | 01010854-01010d90 | -17056..-17060 | 1336 | memory timing, help |
| 01015496-0101a354 | 010111e6-010160a4 | -17072 | 20158 | images and sine table |
| 0101a562-0101a8bc | 010162c2-0101661c | -17056 | 858 | device table tail, font metrics |
| 0101a978-0101b07c | 01016654-01016d58 | -17188 | 1796 | keymaps and 8x12 font |

The ranges of v74 with **no** v66 counterpart are the new code: `$01000042..$010007c6`
(Turbo reset path: TMC, ADB masks, TMC video timing), `$01000a3a..$01001dfc` (parts of
`sub_01000ec6`: Turbo memory sizing, front/back sockets, NCC cache test), `$01002c40..$01004208`
(DRAM/VRAM tests rewritten for Turbo), `$01004a42..$01006122` (POST: Ethernet 7213, sound,
cache), `$0100816e..$01008274`, `$01008766..$01009962` (Ethernet AT&T 7213 driver:
`enreg_read/write`), `$0100b976..$0100ddfa` (**ADB keyboard/mouse driver and Bt463 /
colour console backend**, `$0100c14e` brightness, `$0100c318` ADB registers `$02208080`),
`$01011b5a..$01012c00` (Turbo DMA / parity / misc). The reset paths are structurally the
same (vbr to a bus-error-only table, BMAP clear, `cinva`, machine dispatch on SCR1[15:12],
CRC check, stack in VRAM), v74 adding the Turbo branch `loc_010002a6` and reading SCR1
from the TMC when the type reads 4.
