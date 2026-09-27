#!/usr/bin/env bash
# Lint rtl/tc_kms.sv (verilator -Wall) and build + run verilator/unit/tb_tc_kms.sv.
# Run inside WSL (Verilator 5.020), from anywhere:
#   bash verilator/unit/run_tb_tc_kms.sh
# From Windows:
#   wsl.exe -e bash -lc 'cd /mnt/c/Temp/mistercore/NeXT-Color_MiSTer && bash verilator/unit/run_tb_tc_kms.sh'
# Build output goes to $OUT (default /tmp/tb_tc_kms).  Exit status is non-zero
# on a lint warning, a build error or a failed check.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT="${OUT:-/tmp/tb_tc_kms}"
mkdir -p "$OUT"

echo "== lint: verilator --lint-only -Wall rtl/tc_kms.sv"
verilator --lint-only -Wall --top-module tc_kms "$ROOT/rtl/tc_kms.sv" "$ROOT/rtl/next_sound_output.sv"

echo "== build tb_tc_kms"
verilator --binary --timing --timescale 1ns/1ps -Wno-fatal \
	--top-module tb_tc_kms -Mdir "$OUT/obj" -o tb_tc_kms \
	"$ROOT/rtl/tc_kms.sv" "$ROOT/rtl/next_sound_output.sv" "$ROOT/verilator/unit/tb_tc_kms.sv" > "$OUT/build.log" 2>&1 \
	|| { cat "$OUT/build.log"; exit 1; }

echo "== run"
"$OUT/obj/tb_tc_kms"
