#!/usr/bin/env bash
# Lint rtl/tc_dsp.sv (verilator -Wall) and build + run verilator/unit/tb_tc_dsp.sv
# against the ARM side from ../Main_MiSTer (branch next-color):
# support/next/next_dsp.cpp and Previous's DSP core in support/next/dsp56k.
# Run inside WSL (Verilator 5.020), from anywhere:
#   bash verilator/unit/run_tb_tc_dsp.sh [+arm_every=N +arm_slice=N]
# Build output goes to $OUT (default /tmp/tb_tc_dsp).  Exit status is non-zero
# on a lint warning, a build error or a failed check.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# the Windows checkout (sim_wsl.sh runs the benches from a copy in $HOME)
MAIN="${MAIN:-/mnt/c/Temp/mistercore/Main_MiSTer}"
[ -f "$MAIN/support/next/next_dsp.cpp" ] || MAIN="$ROOT/../Main_MiSTer"
OUT="${OUT:-/tmp/tb_tc_dsp}"
mkdir -p "$OUT/c"

echo "== lint: verilator --lint-only -Wall rtl/tc_dsp.sv"
verilator --lint-only -Wall --top-module tc_dsp "$ROOT/rtl/tc_dsp.sv"

echo "== Previous's DSP core (C) from $MAIN/support/next/dsp56k"
OBJS=""
for f in dsp_core dsp_cpu dsp_disasm; do
	gcc -O2 -std=gnu99 -c -o "$OUT/c/$f.o" "$MAIN/support/next/dsp56k/$f.c"
	OBJS="$OBJS $OUT/c/$f.o"
done

echo "== build tb_tc_dsp"
verilator --binary --timing --timescale 1ns/1ps -Wno-fatal \
	--top-module tb_tc_dsp -Mdir "$OUT/obj" -o tb_tc_dsp \
	-CFLAGS "-I$MAIN/support/next -O1" -LDFLAGS "$OBJS -lpthread" \
	"$ROOT/rtl/tc_dsp.sv" "$ROOT/verilator/unit/tb_tc_dsp.sv" \
	"$ROOT/verilator/unit/tb_tc_dsp_dpi.cpp" "$MAIN/support/next/next_dsp.cpp" \
	> "$OUT/build.log" 2>&1 || { cat "$OUT/build.log"; exit 1; }

echo "== run"
"$OUT/obj/tb_tc_dsp" "$@"
