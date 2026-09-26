#!/usr/bin/env bash
# Lint rtl/tc_scsi.sv and rtl/tc_tdma.sv (verilator -Wall) and build + run
# verilator/unit/tb_tc_scsi.sv (the ROM's SCSI/DMA driver against the two
# modules, a DRAM model and an HPS block-device model).
# Run inside WSL (Verilator 5.020), from anywhere:
#   bash verilator/unit/run_tb_tc_scsi.sh
# From Windows:
#   wsl.exe -e bash -lc 'cd /mnt/c/Temp/mistercore/NeXT-Color_MiSTer && bash verilator/unit/run_tb_tc_scsi.sh'
# Build output goes to $OUT (default /tmp/tb_tc_scsi).  Exit status is
# non-zero on a lint warning, a build error or a failed check.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT="${OUT:-/tmp/tb_tc_scsi}"
mkdir -p "$OUT"

echo "== lint: verilator --lint-only -Wall rtl/tc_tdma.sv"
verilator --lint-only -Wall --top-module tc_tdma "$ROOT/rtl/tc_tdma.sv"
echo "== lint: verilator --lint-only -Wall rtl/tc_scsi.sv (CLK_HZ 33 MHz and the bench's 4 MHz)"
verilator --lint-only -Wall --top-module tc_scsi "$ROOT/rtl/tc_scsi.sv"
verilator --lint-only -Wall -GCLK_HZ=4000000 --top-module tc_scsi "$ROOT/rtl/tc_scsi.sv"

echo "== build tb_tc_scsi"
verilator --binary --timing --timescale 1ns/1ps -Wno-fatal -Wno-INITIALDLY -O3 --x-assign fast -j 0 \
	--top-module tb_tc_scsi -Mdir "$OUT/obj" -o tb_tc_scsi \
	"$ROOT/rtl/tc_tdma.sv" "$ROOT/rtl/tc_scsi.sv" "$ROOT/verilator/unit/tb_tc_scsi.sv" \
	> "$OUT/build.log" 2>&1 \
	|| { cat "$OUT/build.log"; exit 1; }

echo "== run"
"$OUT/obj/tb_tc_scsi"
