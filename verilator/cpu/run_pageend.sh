#!/usr/bin/env bash
# Build and run verilator/cpu/t_pageend.s (the page-end fault test, open
# question 39) on the AP68040 tree's program bench, under Verilator (the
# tree's run_tests.sh wants iverilog, which this box does not have), twice:
# without and with the two experimental CPU options the core's qsf used.
#   wsl -e bash -lc 'cd /mnt/c/Temp/mistercore/NeXT-Color_MiSTer && bash verilator/cpu/run_pageend.sh'
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CPU="${CPU_TREE:-$ROOT/rtl/ap68040}"     # CPU_TREE=<another AP68040 tree> to compare
OUT="${OUT:-/tmp/cpu_pageend}"
VASM="${VASM:-$HOME/local/bin/vasmm68k_mot}"
mkdir -p "$OUT"

"$VASM" -Fbin -m68040 -no-opt -o "$OUT/t_pageend.bin" "$ROOT/verilator/cpu/t_pageend.s" >/dev/null
python3 "$CPU/tb/bin2hex.py" "$OUT/t_pageend.bin" "$OUT/t_pageend.hex"

SRC="$CPU/rtl/ap040_tg68k_compat.v $CPU/rtl/ap040_core.v $CPU/rtl/ap040_bus16_adapter.v
     $CPU/rtl/ap040_bus_timeout.v $CPU/rtl/ap040_regfile.v $CPU/rtl/ap040_alu.v
     $CPU/rtl/ap040_muldiv.v $CPU/rtl/ap040_mmu.v $CPU/rtl/ap040_cache.v $CPU/rtl/ap040_fpu.v
     $CPU/rtl/ap040_walker_cdc.v $CPU/rtl/primitives/dpram.v"
# newer drops instantiate the experimental pipeline module unconditionally
[ -f "$CPU/experimental/ap040_pipeline_integer.sv" ] && SRC="$SRC $CPU/experimental/ap040_pipeline_integer.sv"
[ -f "$CPU/rtl/primitives/dpram.v" ] || SRC="${SRC/$CPU\/rtl\/primitives\/dpram.v/$CPU/rtl/dpram.v}"
# NeXT_MiSTer's drop: its bench talks to the core through a 32-bit bus model
[ -f "$CPU/tb/tb_bus32_host16.v" ] && SRC="$SRC $CPU/tb/tb_bus32_host16.v $CPU/rtl/ap040_bus32_adapter.v"

rc=0
for cfg in plain experimental; do
	defs=""
	[ "$cfg" = experimental ] && defs="-DAP040_EXPERIMENTAL_XSTORE=1 -DAP040_EXPERIMENTAL_LEA=1"
	echo "== build ($cfg)"
	# warning set of verilator/Makefile (the full-machine sim builds this CPU);
	# --unroll-count 256: see the note in verilator/Makefile (PFLUSHA's 128-entry loop)
	verilator --binary --timing -Wno-fatal -Wno-lint -Wno-style -Wno-TIMESCALEMOD -Wno-INITIALDLY \
		-Wno-BLKLOOPINIT -Wno-MULTIDRIVEN -Wno-COMBDLY -Wno-BLKSEQ -Wno-UNOPTFLAT -Wno-LATCH \
		-Wno-SIDEEFFECT --timescale-override 1ps/1ps \
		--x-assign fast -O2 -j 0 --unroll-count 256 $defs -I"$CPU/rtl" --top-module tb_ap040_program \
		-Mdir "$OUT/obj_$cfg" -o tb_prog "$CPU/tb/tb_ap040_program.v" $SRC \
		> "$OUT/build_$cfg.log" 2>&1 || { tail -30 "$OUT/build_$cfg.log"; exit 1; }
	echo "== run ($cfg)"
	"$OUT/obj_$cfg/tb_prog" +prog="$OUT/t_pageend.hex" > "$OUT/run_$cfg.log" 2>&1 || true
	grep -E "STAMP|FAIL|PASS|TEST FAILED" "$OUT/run_$cfg.log" | head -80
	grep -q "ALL TESTS PASSED" "$OUT/run_$cfg.log" || rc=1
done
exit $rc
