# NeXT-Color full-machine simulation

Verilator, headless. `sim.v` instantiates the machine (`rtl/tc_machine.sv`) and
the real memory system (`rtl/tc_memsys.sv`: the SDRAM bridge against two
`sdram_model` chip ranks, the ROM, the DDR3 VRAM engine against `ddr3_model`).
The emu shell (`NeXT-Color.sv`: hps_io, PLLs, video_freak) is not simulated.

## Build and run (from Git bash on the Windows box)

```bash
bash scripts/sim_wsl.sh build                 # sync to ~/NeXT-Color (ext4) and build
bash scripts/sim_wsl.sh run --max-cycles 140000000 --stop-at-pc 1001dd8 --vram-png prompt.png
bash scripts/sim_wsl.sh log 'STEP|FATAL|EXC|BERR'
bash scripts/sim_wsl.sh fetch prompt.png      # -> scratch/sim/
```

About 380k clk_sys (33 MHz) cycles per second on this box, so a second of
machine time is ~90 s. The real ROM reaches `NeXT>` (POST off, empty boot
command) in about 3 s of machine time.

`+rom=rom_fast.hex` runs a sim-only ROM with the CRC, the 2 MB VRAM test,
the 750 ms video delay, the 2 s SCSI bus-reset settle and the TEST_DRAM
memory test patched out (`scripts/make_fastboot_rom.py`): the prompt in ~30M
cycles instead of ~110M, and a `--pot-on` POST in ~71M.

## GUI

`make gui` (in `~/NeXT-Color/verilator`) builds `obj_dir_gui/Vemu` with
MacQuadra800's ImGui/SDL framework: the VGA output in a window, the host
keyboard through SimInput's SDL -> PS/2 mapping, RUN/batch/scale controls and a
"VRAM PNG" button. Needs a display (WSLg):
`wsl -e bash -lc 'cd ~/NeXT-Color/verilator && ./obj_dir_gui/Vemu +rom=rom_fast.hex'`.
The same command-line options apply.

## Options (`./obj_dir/Vemu --help`)

| option | |
|---|---|
| `--max-cycles N` | stop after N clk_sys cycles |
| `--stop-at-pc A,B` | stop when the executed PC reaches A or B (hex), with registers |
| `--trace-calls N` | log the first N entries of every named ROM routine |
| `--trace-pc FROM,N` | log N executed PCs from cycle FROM |
| `--vram-png F` | at exit, the framebuffer from the DDR3 model through the Bt463 LUT |
| `--png-at C1,C2` | the same at those cycles (`vram_<cycle>.png`) |
| `--frames F1,F2` | save those frames of the VGA output (`frame_NNNN.png`) |
| `--ram N` | 0 = 64 MB (default), 1 = 128 MB, 2 = 16 MB, 3 = 32 MB |
| `--pot-on` | NVRAM default image with the power-on test (POT $11) |
| `--boot CMD` | NVRAM default boot command (empty = stop at `NeXT>`) |
| `--type C:TEXT` | type TEXT from cycle C (`\|` = Return) through the PS/2 -> KMS path |
| `--disk0 F`, `--disk1 F` | SCSI target 0 / 1 image (SD slot 0 / 1); **written back**: use a copy |
| `+hostlat=N` | the HPS answers an SD request only after N clocks (default at once) |

## SCSI disks

`sim.v` models the HPS side of tc_scsi's SD block interface (the protocol of
NeXT_MiSTer's `tb/tb_next_boot.sv`).  Disk blocks come from the `--diskN` image
through DPI (`host/host_dpi.cpp`, 64-bit offsets, so 2 GB images work); the
target-response windows (INQUIRY, READ CAPACITY, MODE SENSE, ... on slot 3) are
answered by Main_MiSTer's own `support/next` sources, which `sim_wsl.sh build`
copies from `../Main_MiSTer` (branch next-color) into `~/NeXT-Color/host_main`
together with the shim headers in `host/shim` (from NeXT_MiSTer `tb/host`).

```bash
bash scripts/sim_wsl.sh run +rom=rom_fast.hex --boot sd \
    --disk0 /home/dani/next_prof/ns33_color.hda --max-cycles 250000000
```

reaches the kernel (`[BOOT] first instruction from DRAM` marks the jump into
the loaded boot program; `[SD]` lines log block reads/writes).  With
`rom_fast.hex` the ROM's 2 s SCSI bus-reset settle is 1 ms.

## Log lines

`[STEP]` the reset-to-prompt checkpoints of `rom-dissassembly/hardware-summary.md`
section 0.3; `[CALL]` named routine entries (`rom_syms.txt`, generated from
`rom-dissassembly/known_names.py`); `[EXC]` exceptions; `[BERR]` bus errors;
`[LED]` SCR2 LED changes; `[FATAL]` the ROM's LED blink halt with its code (in
A0: 1/2 = CRC, 5 = no DRAM bank, ...); `[VID]` frames; `[HB]` heartbeat.

## Unit benches

`verilator/unit/`: `bash scripts/sim_wsl.sh unit tc_kms`, `... unit tc_mccs1850`,
`... unit tc_scsi` (tc_scsi + tc_tdma against the ROM's SCSI driver sequences).
