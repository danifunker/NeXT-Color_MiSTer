#!/usr/bin/env bash
# Unit test of rtl/tc_mccs1850.sv (MCCS1850 RTC / NVRAM).
# Run from anywhere inside WSL, e.g.
#   wsl.exe -e bash -lc 'cd /mnt/c/Temp/mistercore/NeXT-Color_MiSTer && verilator/unit/run_tb_tc_mccs1850.sh'
# Optional first argument: "iverilog" to use Icarus instead of Verilator.
# Build outputs go to /tmp, never into the repository.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT="${TMPDIR:-/tmp}/tb_tc_mccs1850"
SIM="${1:-verilator}"
mkdir -p "$OUT"

RTL="$ROOT/rtl/tc_mccs1850.sv"
TB="$ROOT/verilator/unit/tb_tc_mccs1850.sv"

echo "== lint (verilator -Wall)"
verilator --lint-only -Wall "$RTL"
verilator --lint-only -Wall -GCLK_HZ=10000 "$RTL"

LOG="$OUT/run.log"
if [ "$SIM" = "iverilog" ]; then
	# Icarus lives in ~/oss-cad-suite/bin on the dev box (only on the interactive PATH)
	IVL_BIN="$(dirname "$(command -v iverilog || echo "$HOME/oss-cad-suite/bin/iverilog")")"
	echo "== iverilog ($IVL_BIN)"
	"$IVL_BIN/iverilog" -g2012 -o "$OUT/tb.vvp" -s tb_tc_mccs1850 "$RTL" "$TB"
	set +e
	"$IVL_BIN/vvp" -n "$OUT/tb.vvp" | tee "$LOG"
	rc=${PIPESTATUS[0]}
	set -e
else
	echo "== verilator"
	verilator --binary --timing -Wno-fatal -Wno-WIDTH -Wno-INITIALDLY \
		--top-module tb_tc_mccs1850 -Mdir "$OUT/obj" -o Vtb "$RTL" "$TB" >"$OUT/build.log" 2>&1 \
		|| { cat "$OUT/build.log"; exit 1; }
	set +e
	"$OUT/obj/Vtb" | tee "$LOG"
	rc=${PIPESTATUS[0]}
	set -e
fi

if [ "$rc" -ne 0 ] || ! grep -q '^PASS: tb_tc_mccs1850' "$LOG"; then
	echo "tb_tc_mccs1850: FAILED (exit $rc)"
	exit 1
fi
echo "tb_tc_mccs1850: OK"
