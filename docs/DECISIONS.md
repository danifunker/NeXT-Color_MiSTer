# Bring-up decisions (2026-09-26)

Answers given by the user before M0, and the defaults taken with them. The
evidence behind each one is in `rom-dissassembly/hardware-summary.md` (cited
as "HS §n") and in the Previous r1851 sources under `scratch/resources/`.

## Memory

- **Main RAM in SDRAM** through the MacQuadra800 controller (`rtl/sdram.sv`,
  `rtl/sdram_beat32.sv`, clk_ram 99 MHz = 3 x clk_sys).
- **4 banks** at `$04000000 + n * $02000000` (HS §3.1). Bank *n* lives at SDRAM
  offset *n* x 32 MB; the offset inside a bank is masked to the bank's size, so
  an 8 MB bank aliases every 8 MB and a 2 MB bank every 2 MB, which is exactly
  what the ROM's sizing test expects (HS §3.3).
- **OSD sizes**: 64 MB (default, 2 x 32), 128 MB (4 x 32), 16 MB (2 x 8),
  32 MB (1 x 32).
- **Absent banks** read 0 and never bus-error (HS §16.1 item 6). They are never
  posted, never enter the retained SDRAM line, so the pattern the probe just
  wrote cannot echo back.
- **Boot ROM in M10K**, full 128 KB (`rtl/tc_rom.sv`, ~103 of 553 blocks).
  Loaded by the Main from `games/NeXT-Color/boot.rom` (ioctl index 0). The
  committed copy is `releases/boot.rom` (= `roms/Rev_3.3_v74.BIN`); the deploy
  script seeds it.
- **VRAM in DDR3**, 2 MB at DDR byte address `$30000000` (the scaler uses
  `$20000000..$217FFFFF`). CPU side retains a 16-byte line; scan-out prefetches
  whole lines into a FIFO.

## Main_MiSTer

- The user cut a new branch, **`next-color`**, off main in `../Main_MiSTer`.
  **Never switch that checkout's branch.** `is_next()` needs to match
  "NeXT-Color" as well (it gates the UTC clock, the SCSI response window, the
  mount hooks and the Ethernet daemon); that change goes on `next-color`, and
  the binary is not deployed without asking.

## Keyboard / mouse

- **KMS first** (the mono core's PS/2 -> KMS path, with Previous's Turbo
  "REV_NEW" KMS behaviour), ADB only at the ROM's no-device minimum (HS §5).
  ADB keyboard support only if KMS turns out not to work. The v74 ROM probes
  ADB first and falls back to KMS; both were valid on a Turbo Color with ROM 3.3.

## Video

- 100 MHz pixel clock from its own PLL (`rtl/pll_vid.v`), CE_PIXEL = 1.
- Geometry from the TMC registers `$02200088/8C` in 4-pixel units; reset value
  1120x832 in a 1632x896 frame = 68.4 Hz (HS §2.5).
- Colour: each 4-bit channel value n selects Bt463 palette entry n<<4 of that
  channel (window type `$000100` = 24-plane true colour, read masks `$F0`,
  HS §4.2), so the ROM's brightness palette works. Overlay/cursor/WTT stored,
  not drawn.
- **Fill the screen**: `sys/video_freak.sv` with Aspect (Original = 35:26,
  Full Screen, ARC1/2) and Scale (Normal = fit the output height: 1454x1080
  on 1080p, 969x720 on 720p; V-Integer; HV-Integer). No
  `MISTER_DOWNSCALE_NN`: 832 lines onto 720p is a downscale and text needs the
  filtered scaler.

## CPU

- **The MacQuadra800 AP68040 tree** (`rtl/ap68040`, `rtl/wombat_cpu.sv`,
  `rtl/wombat_bus32.sv`, `rtl/wombat_store_buffer.sv`), with the
  `AP040_EXPERIMENTAL_XSTORE/LEA` macros of Quadra's validated build.
- **`ce` tied high** (Quadra's mode). The v74 ROM times every delay on the event
  counter (`delay_us` $01008936), so the mono core's DBcc floor is not needed.
  NeXT_MiSTer's CPU drop 2 (branch `cpu-drop-20260925`: the Quadra CPU with
  the NeXT port) stalled on hardware under a *gated* `ce`; the planned
  discriminator was exactly "ce never gated".
- **Do not alter the CPU core now** (user). The CPU_NEXT_PORT.md fixes 5, 6
  and 8 are bugs that only appear with a gated `ce` and are not applied; fix 7
  is already in the Quadra tree in another form (`xline_snoop_pending`). Only
  the host wrapper (`wombat_cpu.sv`, `wombat_store_buffer.sv`) is adapted to
  the NeXT memory map (posting window, cacheable window, FPU revision
  parameter). See `rtl/ap68040/UPSTREAM.md`.
- **FPU frame revision `$41`** (Previous: `$41` for Turbo, `$40` otherwise,
  m68000.c:114-118). Exposed as a `wombat_cpu` parameter.
- The user would like the NeXT_MiSTer CPU tried as well, if possible, as an
  experiment; the Quadra CPU is the strong preference.

## System registers

- SCR1: Previous's scheme. `$0200C000` reads `$F0004000` (type 4), the TMC copy
  `$02200000` reads `$FFFF5FDF` (type 5, 33 MHz, 70 ns) (HS §1.1).
- SCR2 reset: byte 2 = `$10` (1120x832 only), byte 3 = `$80` (sysReg.c:209-212).
- Interrupt mask: Previous's Turbo always-on bits `$C22E7600` are ORed in on
  write and hidden on read (sysReg.c:590-615). Unverified on hardware;
  recorded in `docs/OPEN-QUESTIONS.md`.

## NVRAM / RTC

- MCCS1850 model (Turbo), not the mono core's MC68HC68T1.
- A default NVRAM image like the mono core's (`next_scr.sv`): built into the
  FPGA image, boot command rewritten from an OSD "Boot device" setting on
  power-up and user reset. **No persistence** until there is a need for it.
- The ROM's own default (built when the checksum is bad) has boot command "en",
  which retries the network forever (HS §16.2), so the sim/hardware default
  image carries a valid checksum and the OSD-selected boot command.

## SCSI and DMA (M4, 2026-09-26)

- **ESP + targets = `rtl/tc_scsi.sv`** (NeXT_MiSTer's next_scsi.sv minus its
  inline DMA), **PC-chip DMA = `rtl/tc_tdma.sv`** (all seven Turbo channels'
  registers; only the SCSI channel moves data).  They meet on the 13-signal
  channel port the unit bench tested.
- **DMA memory master** in tc_machine's service FSM (quadra800.sv's SONIC
  pattern): one longword beat per request, alternating with the CPU, through
  the ordinary RAM port (the bridge drops its retained line on a DMA write and
  drains posted CPU writes before a DMA read); a DMA write pulses the 68040
  snoop.  **Only present DRAM** is a DMA target; anything else answers m_err
  (channel BUSEXC, Previous dma.c:445-449).
- **hps_io `WIDE=0`, `VDNUM=4`**: tc_scsi keeps next_scsi's 8-bit sd_buff
  port; the boot-ROM loader pairs the ioctl bytes into big-endian halfwords.
  OSD `SC0`/`SC1` (disks, remembered in `config/NeXT-Color.s<n>`) and `S3`
  (CD-ROM, which also carries Main's target-response windows).  Slot 2 has no
  entry: target 2 times out.  tc_scsi's request goes to slot `sd_unit` only.
- **No mount replay**: tc_scsi keeps its mount state outside the machine
  reset (the Quadra's ncr53c96 needed a replay FSM; this engine does not).
- Main_MiSTer `next-color` (f2d08a5, `is_next()` matches "NeXT-Color") is
  required on hardware: without it Main answers no INQUIRY / READ CAPACITY
  windows for this core.  Build: `scripts/build_main_wsl.sh`.

## Simulation

- Full-machine Verilator sim instantiates the machine and the **real memory
  path** (`sdram_beat32` + `sdram.sv` against the `tb_sdram.sv` chip model; the
  DDR3 VRAM bridge against a DDR3 bus model). `+fastmem` switches RAM/VRAM to
  plain arrays for fast iteration.
- **SD slots in the sim** (M4): `sim.v` models the HPS side of the block
  interface; disk images are read/written through DPI (`verilator/host/
  host_dpi.cpp`, 64-bit offsets), and the target-response windows are served
  by Main_MiSTer's own `support/next` sources (copied from `../Main_MiSTer`
  at build time, with NeXT_MiSTer's shim headers), so the sim tests the Main
  code that ships.

## Repository and hardware

- Commit milestones on **`master`** until told otherwise. No worktrees.
- `sys/` is the stock template (verified identical to `../Template_MiSTer/sys`).
- MiSTer for bring-up: **192.168.99.143** (`scripts/local.env`). Nothing is
  deployed without asking.
