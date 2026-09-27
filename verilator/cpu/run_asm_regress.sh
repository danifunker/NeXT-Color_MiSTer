#!/usr/bin/env bash
# Run every rtl/ap68040/tb/asm/*.s program through the AP68040 program bench
# under Verilator (sibling of run_pageend.sh; the tree's run_tests.sh wants
# iverilog).  Prints PASS/FAIL per program and a summary line.
#   wsl -e bash -lc 'cd /mnt/c/Temp/mistercore/NeXT-Color_MiSTer && bash verilator/cpu/run_asm_regress.sh'
#   CPU_TREE=<other AP68040 tree> OUT=/tmp/x bash verilator/cpu/run_asm_regress.sh
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CPU="${CPU_TREE:-$ROOT/rtl/ap68040}"
OUT="${OUT:-/tmp/cpu_asm_regress}"
VASM="${VASM:-$HOME/local/bin/vasmm68k_mot}"
DEFS="${DEFS:-}"                      # e.g. -DAP040_EXPERIMENTAL_XSTORE=1 -DAP040_EXPERIMENTAL_LEA=1
mkdir -p "$OUT"

SRC="$CPU/rtl/ap040_tg68k_compat.v $CPU/rtl/ap040_core.v $CPU/rtl/ap040_bus16_adapter.v
     $CPU/rtl/ap040_bus_timeout.v $CPU/rtl/ap040_regfile.v $CPU/rtl/ap040_alu.v
     $CPU/rtl/ap040_muldiv.v $CPU/rtl/ap040_mmu.v $CPU/rtl/ap040_cache.v $CPU/rtl/ap040_fpu.v
     $CPU/rtl/ap040_walker_cdc.v $CPU/rtl/primitives/dpram.v"
[ -f "$CPU/experimental/ap040_pipeline_integer.sv" ] && SRC="$SRC $CPU/experimental/ap040_pipeline_integer.sv"
[ -f "$CPU/rtl/primitives/dpram.v" ] || SRC="${SRC/$CPU\/rtl\/primitives\/dpram.v/$CPU/rtl/dpram.v}"
[ -f "$CPU/tb/tb_bus32_host16.v" ] && SRC="$SRC $CPU/tb/tb_bus32_host16.v $CPU/rtl/ap040_bus32_adapter.v"

echo "== build"
verilator --binary --timing -Wno-fatal -Wno-lint -Wno-style -Wno-TIMESCALEMOD -Wno-INITIALDLY \
	-Wno-BLKLOOPINIT -Wno-MULTIDRIVEN -Wno-COMBDLY -Wno-BLKSEQ -Wno-UNOPTFLAT -Wno-LATCH \
	-Wno-SIDEEFFECT --timescale-override 1ps/1ps \
	--x-assign fast -O2 -j 0 --unroll-count 256 $DEFS -I"$CPU/rtl" --top-module tb_ap040_program \
	-Mdir "$OUT/obj" -o tb_prog "$CPU/tb/tb_ap040_program.v" $SRC \
	> "$OUT/build.log" 2>&1 || { tail -30 "$OUT/build.log"; exit 1; }

pass=0; fail=0; failed=""
for s in "$CPU"/tb/asm/*.s; do
	n="$(basename "$s" .s)"
	if ! "$VASM" -Fbin -m68040 -no-opt -o "$OUT/$n.bin" "$s" > "$OUT/$n.asm.log" 2>&1; then
		echo "ASMFAIL $n"; fail=$((fail+1)); failed="$failed $n"; continue
	fi
	python3 "$CPU/tb/bin2hex.py" "$OUT/$n.bin" "$OUT/$n.hex"
	timeout 600 "$OUT/obj/tb_prog" +prog="$OUT/$n.hex" > "$OUT/$n.log" 2>&1
	if grep -q "ALL TESTS PASSED" "$OUT/$n.log"; then
		echo "PASS $n"; pass=$((pass+1))
	else
		echo "FAIL $n: $(grep -E 'FAIL|TEST FAILED|timeout|TIMEOUT' "$OUT/$n.log" | head -1)"
		fail=$((fail+1)); failed="$failed $n"
	fi
done
echo "SUMMARY pass=$pass fail=$fail failed:$failed"
