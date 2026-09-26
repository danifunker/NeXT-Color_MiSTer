# NeXTstation Turbo Color: resource index

Target: NeXTstation Turbo Color (33 MHz 68040, Turbo chipset, 12-bit color,
1120x832). Compiled 2026-09-25 from local files. Nothing here is code.

All resources below are copied into this repo under `scratch/resources/` (gitignored;
copied 2026-09-26, originals untouched, 3.3 GB). Paths in this file are relative to that
folder. `scratch/resources/README.md` maps each folder back to its origin.

Original locations: `NF` = `C:\Temp\NeXTfiles.20250902`, `NM` = `C:\Temp\NeXTSTEP-mirror`,
`MC` = `C:\Temp\mistercore`.

## 1. Hardware documents (`docs/`)

### Read first
| File | Why |
|---|---|
| `docs/schematics/Turbo_slab/CSlab33-01..16.pdf`, `CSlab33-map.pdf` | **Turbo Color Slab motherboard schematics** (Charles Dvorak redraw, 1999, ~99% accurate). The best single source for this target. Page index: 1 index, 2 CPU/TMC/EPROM/PLL/config/ADB, 3 PC/RTC/LED/PWR, 4 DRAM/bus mux, 5 mono display, **6 color display**, 7 KMS/laser printer, 8 Ethernet, 9 DSP, 10 SCC, 11 SCSI, 12 floppy, 13-16 bypass/test/mech/impedance |
| `docs/schematics/Turbo_slab/CSlab33_Schematics.README` | Page index and drawing conventions (red items are best-guess) |
| `docs/schematics/Turbo_cube/Cube33-01..17.pdf` | Turbo cube schematics. The color slab was derived from these (14 of 16 pages are near-identical), so use them to cross-check unreadable parts |
| `docs/product/nextstation_color.pdf` | Product sheet: TMC and PC (Peripheral Controller) ICs, 4 x 72-pin SIMMs (16 to 128 MB), 4,096 colors, 1120x832, 2.88 MB floppy |
| `docs/datasheets/Video Processor/Brooktree Bt463_Datasheet*.pdf` | The color RAMDAC. Previous models it in `ramdac.c` |
| `docs/datasheets/NetworkingASICNeXThardwaret7203ec.pdf` | Turbo Ethernet ASIC (AT&T T7213). Different from the MB8795 in the non-Turbo machines |
| `docs/FAQ_Hardware/HW_internal_FAQ.txt`, `HW_general_FAQ.txt`, `HW_RAM_FAQ.txt`, `HW_peripherals_FAQ.txt` | Plain-text hardware FAQs |
| `docs/FAQ_Hardware/True Color_vs_CLUT.pdf`, `Display_Configurations.pdf` | Video pixel format and CLUT behavior |
| `docs/TCA/Turbo_Color_Accelerator_Installation_Guide.pdf` | Turbo Color Accelerator (upgrade board). Read only for context |

### Parts shared with the existing core
`docs/datasheets/`: `SCSI_Controller/` (NCR 53C90), `Floppy_Controller/` (82077AA),
`Serial_Controller/` (Am85C30), `DSP/DSP56001.pdf`, `MCCS1850.pdf` (RTC),
`Ethernet-nonTurboNeXT/` (MB8795, not used on Turbo). Also `NextBus_Interface_Chip_Specification.pdf`
(NBIC; the Station has no NBIC, so this is optional).

### Other
`docs/service_manual/` (`NeXT Service Manual 2 Sections *_OCR.pdf`, `NeXTServiceManualPages1-160_OCR.pdf`),
`docs/product/nextstation.pdf` (mono Station sheet), `docs/monitor/Monitor_ASIC/ASIC-2.pdf`,
`docs/monitor/NeXT4000MonitorFactoryManual/`, `docs/monitor/sony_gdm-1632.pdf` and
`docs/monitor/GDM-1601_Service_Manual_1988.pdf` (the color monitor tube).
`docs/patents/` (48 files) and `docs/posters-patents/` (16 files): not reviewed; may or may not touch DMA/memory.

## 2. ROMs (`roms/68040_Turbo_Chipset/`)

| ROM | Notes |
|---|---|
| `Rev_3.3_v74.BIN` (128 KB) | **Use this one.** Final Turbo ROM. Also in the repo at `roms/Rev_3.3_v74.BIN` |
| `Old_Versions/Rev_3.0_v70.BIN`, `Rev_3.1_v71.BIN.zip`, `Rev_3.2_v72.BIN` | For diffing against v74 |
| `*.jpg` | Chip label photos |

`roms/68040_Non-Turbo_Chipset/`: the non-Turbo Rev 2.5 v66 (which the existing core boots), plus
v58, v59 and v65.
`previous-r1851-src/ROMV66-0001E-02588.ASM` is an annotated v66 listing;
**there is no v74 listing.** `tooling/rom-disassembly/` (`disasm_rom.py`,
`hardware-refs.md`, `functions.md`) is the tooling that produced the v66 disassembly and
can be pointed at v74. Its `hardware-refs.md` uses Previous's *non-Turbo* I/O table, so it
would need the Turbo table (see section 3).

## 3. Emulator reference (Previous)

- `previous-r1851-src/` is a full Previous source tree (SVN r1851) with the Turbo code paths.
- `previous-submodule/` is the copy the existing core follows (`MC\NeXT_MiSTer\reference\previous`). Despite the path it is a plain source export, SVN r1850 taken 2026-08-31 (see its `REVISION`), and it includes the Turbo files (`tmc.c`, `ioMemTabTurbo.c`, `ramdac.c`). It is one revision behind r1851. It also has the build and networking how-tos.
- Binaries: `previous-binaries/Previous_1.6` through `2.4`. Use these for running and comparing behavior.

Turbo-specific files in `previous-r1851-src/`, in reading order:

| File | Content |
|---|---|
| `ioMemTabTurbo.c` (236 lines) | Complete Turbo device-register table. Diff it against `ioMemTabNEXT.c` |
| `tmc.c` (502) | **Turbo Memory Controller**: SCR1 replacement, ADB at `0x02208000`, video timing and interrupt registers, NMI |
| `ncc.c` (186) | Nitro Cache Controller. Only mapped when the CPU is 40 MHz (Nitro board). **Not needed for a stock 33 MHz machine** |
| `ramdac.c` (275) | Bt463 model: ID reg 0x2A, rev 0x0A, CCR / register / window type table (WTT) address spaces |
| `video.c`, `dma.c` (`TDMA_*`), `ethernet.c` (Turbo branches), `esp.c` (turbo at line 173), `dsp/dsp.c` (unpacked DMA), `sysReg.c`, `cpu/memory.c` | Turbo branches. Search for `bTurbo` and `bColor` |
| `readme.previous.txt` | Board revisions, ROM versions, known Turbo Color notes |

## 4. What differs from the existing NeXT_MiSTer core

The existing core is a **NeXTcube 68040, monochrome, non-Turbo** (SCR1 `0x00012052`, ROM v66,
1120x832 2bpp, 64 MB in DDR3). The following comes from Previous's source and needs
verification against the schematics.

| Area | Existing (non-Turbo mono) | Turbo Color |
|---|---|---|
| CPU | 25 MHz 68040 (AP68040) | 33 MHz. TMC SCR1 speed field 7 = 33 MHz. CPU-type field 5 = Turbo Color |
| System register | SCR1 in device space | TMC at `0x02200000` (64 KB). Also the ADB window at `0x02208000` |
| Memory controller | Discrete, BMAP chip | **TMC**; no BMAP. Device space still at `0x02000000`, BMAP mirror at `0x02100000` is plain IO |
| DMA | Fujitsu MB610313 (`DMA_CSR`) | **PC chip, `TDMA_CSR`** at `02000010/40/80/90/d0/110/150`. New channel layout: SCSI `0x2004010`, sound out `0x2004040`, sound in `0x2004080`, printer `0x2004090`, DSP `0x20040d0`, enet TX `0x2004100`, enet RX `0x2004140`, plus DMA-init registers at `0x2004210+` and an enet "saved limit" at `0x2004050` |
| Ethernet | MB8795 | **AT&T T7213**. TX/RX register semantics and masks differ (`tx_mask & 0xBE` vs `0xAF`) |
| RAM map | 4 banks x 16 MB stride `0x01000000` from `0x04000000` | Stride `0x02000000`, bank select mask `0x06000000`. 72-pin SIMMs, 16 to 128 MB. The memory-write-function mirrors (MWF) do not exist |
| Video memory | 256 KB at `0x0B000000` + MWF mirrors | Color VRAM 2 MB (`0x200000`) at `0x0C000000`; no MWF mirrors. (Non-Turbo Color was at `0x2C000000`.) |
| Video output | 2bpp gray, fixed timing | 16bpp color (12-bit RGB + spare bits), Bt463 palette/window logic, TMC horizontal/vertical/video-interrupt registers |
| Keyboard/mouse | KMS via `0x0200E000` | Previous maps an ADB window at `0x02208000` (TMC). Unverified whether the color Station still uses KMS; check schematic pages 2 and 7 |
| ROM | Rev 2.5 v66 | Rev 3.3 v74 (same 128 KB size). The ROM diagnostics and boot path use the Turbo tables |
| Cache | none | NCC only with a Nitro board; skip |
| SCSI / floppy / SCC / RTC / DSP / sound / MO | Existing modules | Mostly reusable, but check ESP turbo differences (`esp.c:173`) and DSP DMA (`dsp.c:147,161`) |

Existing RTL likely to carry over: `next_scsi`, `next_floppy`, `next_scc`, `next_kms_snd`
(sound path), `next_snd_in`, `next_enet_bridge` and `next_ddram_arb` (the host-side bridge; the
NIC front-end changes), `next_rom`, `next_intc` (check IPL assignments), `next_timer`. New RTL: TMC, PC/TDMA
engine, T7213 front-end, Bt463 + 16bpp scan-out, color VRAM, ADB.

## 5. Software (`software/`)

- `software/Diagnostic_Utilities/`: `68040.tar.gz` and `68040_manual.pdf` (68040 diagnostics), `68030.tar.gz`, `BT-68030.tar.gz` (memory-test class tools), `Formatdisk`, `Disktab-util`, `OD-Recovery`. `next-hw-utilities-readme.rtf` documents them. Useful as later test payloads. (Source: `NM` only; the `NF` folder is empty.)
- `software/memtester-NS33.tar.gz`: RAM test for a bring-up stage.
- `software/kernel-sources/kernel-1.tar.gz` and `driverkit-139.1-1.tar.gz`: NeXTSTEP kernel and DriverKit sources. **These may contain the machine-dependent headers (SCR, TMC, PC, video) that name registers and bits.** Not opened yet. (Source: `NM` only.)
- `tooling/NeXT_MiSTer-docs/`: notes from the previous build. `PORTING.md` has the module map. `RESUME-20260925.md` has the state of the last session (a fifth update; branch `upgraded_cpu_and_more`).
- `software/os/NEXTSTEP/` (2.4 GB), `OPENSTEP/` (320 MB), `Rhapsody/` (313 MB): OS install media, patches, developer tools. The Turbo Color runs NeXTSTEP 3.x or OPENSTEP 4.x. Each folder combines `NF` and `NM`. No file was in both with a different size. `NM` has most of the content (`NF` has 681 MB of NEXTSTEP and 18 MB of OPENSTEP).

## 6. External sources not yet fetched (need your OK before I download anything)

- Previous upstream: `github.com/probonopd/previous` (mirror) and `previous.alternative-system.com` (current source and Turbo release notes). The local tree is r1851; the latest may fix Turbo details.
- NetBSD `next68k` port (`sys/arch/next68k`): register headers for the NeXTstation, including TMC/PC. Verify how far its Turbo coverage goes.
- Linux kernel history: no NeXT port in mainline as far as I know (verify).
- `nextcomputers.org` and `nextcomputers.org/NeXTfiles/`: the origin of the mirror. Check for newer items, especially the "submissions" folder mentioned in the schematics README.
- The old `next-ftp.peak.org/next-ftp/next/submissions` folder (mentioned only in the schematics README). Not in either local mirror. The Wayback Machine mostly does not capture FTP, so try other FTP mirrors (funet, nluug) that were later uploaded to archive.org, the old NeXT CD-ROM compilations, or ask on nextcomputers.org.
- MAME `next.cpp`: has NeXT machine drivers (verify whether Turbo Color is present). Another behavioral reference, GPL-compatible.
- Motorola/Freescale MC68040 manual; Bt463 errata; NeXT Turbo hardware notes on forums (NeXTComputers.org, "NeXT Mailing list" archives, Hackaday/YouTube teardown posts). Search for "TMC" and "Peripheral Controller" specifically.
- Real hardware ROM dumps or NVRAM dumps from a Turbo Color, if you or a friend own one. That is the best ground truth.

## 7. Housekeeping / open issues

- Everything needed for this project is in `scratch/resources/`. `scratch/` is gitignored, so a fresh clone will not have it; recreate it from the original locations listed in `scratch/resources/README.md`.
- `NM` is a partial re-mirror (see its `MISSING_refused_exe.txt`, which lists refused WebObjects `.exe` patches; `state*.json`, `fetch*.log` are scraper state). It has no `Docs` folder. Neither mirror is complete on its own: `NF` has all the docs, but `NM` has far more OS media, the kernel/DriverKit archives and the diagnostics (`NF`'s `Diagnostic_Utilities` folder is empty).
- The `NF` copy is 10 GB and `NM` is 8.7 GB, and most of that is software that isn't relevant here. Only what is listed in this file was copied.
- This folder is a git repository with the MiSTer template, renamed to the core name `NeXT-Color` (`NeXT-Color.qpf`, `.qsf`, `.sv`, and so on).

## 8. Suggested reading order

1. `docs/schematics/Turbo_slab/CSlab33-map.pdf`, then pages 2, 6 and 8 (CPU/TMC, color display, Ethernet).
2. `previous-r1851-src/tmc.c`, `ioMemTabTurbo.c`, `dma.c` TDMA sections.
3. `docs/datasheets/Video Processor/Brooktree Bt463_Datasheet.pdf` plus `previous-r1851-src/ramdac.c`.
4. `docs/FAQ_Hardware/HW_internal_FAQ.txt`, `True Color_vs_CLUT.pdf`.
5. Disassemble `roms/68040_Turbo_Chipset/Rev_3.3_v74.BIN` with `tooling/rom-disassembly/` and list the absolute device addresses it touches.
6. `software/kernel-sources/kernel-1.tar.gz` headers for register names.
