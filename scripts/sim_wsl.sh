#!/usr/bin/env bash
# scripts/sim_wsl.sh — build and run the NeXT-Color Verilator sim under WSL from
# the Windows checkout (run from git-bash; it drives wsl.exe).  From
# MacQuadra800_MiSTer's script of the same name.
#
#  1. BUILD ON ext4, NOT /mnt/c: the sources are synced to ~/NeXT-Color first
#     (Verilator's ~40 C++ files build several times faster there).
#  2. CRLF is stripped from shell scripts and the Makefile on the way.
#  3. The sim runs from verilator/ (rom.hex, rom_syms.txt are cwd-relative).
#
# Usage:
#   bash scripts/sim_wsl.sh build                # sync + build Vemu, rom.hex, rom_syms.txt
#   bash scripts/sim_wsl.sh run [Vemu args...]   # headless run -> sim_run.log (in WSL)
#   bash scripts/sim_wsl.sh log [grep-pattern]   # tail / grep the run log
#   bash scripts/sim_wsl.sh fetch [file...]      # copy PNGs (or files) back to scratch/sim/
#   bash scripts/sim_wsl.sh unit <name>          # build+run verilator/unit/tb_<name>.sv
#
# Useful Vemu args (verilator/sim_main.cpp --help): --max-cycles N (clk_sys
# cycles), --stop-at-pc 1001dd8, --trace-calls 3, --vram-png screen.png,
# --frames 5,20, --pot-on, --boot sd, --ram 1.
set -u
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)" || exit 1

WSL_DIR='$HOME/NeXT-Color'
LOG="${SIM_LOG:-sim_run.log}"
DISTRO="${WSL_DISTRO:-}"
wsl_run() {
    if [ -n "$DISTRO" ]; then wsl.exe -d "$DISTRO" -e bash -lc "$1"
    else wsl.exe -e bash -lc "$1"; fi
}
WIN_ROOT="$(pwd -W 2>/dev/null || pwd)"

cmd="${1:-}"; shift 2>/dev/null || true

case "$cmd" in
build)
    echo "[sim] syncing sources -> WSL $WSL_DIR (ext4)"
    wsl_run "set -e
        mkdir -p $WSL_DIR
        cd \"\$(wslpath '$WIN_ROOT')\"
        rsync -a --delete --exclude obj_dir --exclude '*.png' --exclude '*.log' rtl verilator releases rom-dissassembly scripts $WSL_DIR/
        # the HPS side of the SD slots: Main_MiSTer support/next (branch
        # next-color, ../Main_MiSTer) + the shim headers (verilator/host/shim)
        MAIN=\"\$(wslpath '$WIN_ROOT')/../Main_MiSTer\"
        [ -f \"\$MAIN/support/next/next_scsi.cpp\" ] || { echo \"no \$MAIN/support/next\"; exit 1; }
        mkdir -p $WSL_DIR/host_main/support
        rsync -a --delete \"\$MAIN/support/next\" $WSL_DIR/host_main/support/
        rsync -a verilator/host/shim/ $WSL_DIR/host_main/
        git -C \"\$MAIN\" log --oneline -1 > $WSL_DIR/host_main/MAIN_COMMIT 2>/dev/null || echo unknown > $WSL_DIR/host_main/MAIN_COMMIT
        find $WSL_DIR \( -name '*.sh' -o -name Makefile \) -exec sed -i 's/\r\$//' {} +
        cd $WSL_DIR/verilator
        make -j\$(nproc) 2>&1 | tail -30
        ls -l rom.hex rom_syms.txt obj_dir/Vemu" || exit 1
    ;;
run)
    echo "[sim] headless run -> $WSL_DIR/verilator/$LOG"
    ARGS=""
    for a in "$@"; do ARGS="$ARGS '$a'"; done   # (arguments must not contain ')
    wsl_run "cd $WSL_DIR/verilator && exec ./obj_dir/Vemu $ARGS > $LOG 2>&1"
    ;;
log)
    PAT="${1:-}"
    if [ -n "$PAT" ]; then wsl_run "cd $WSL_DIR/verilator && grep -n -E '$PAT' $LOG | tail -60"
    else wsl_run "cd $WSL_DIR/verilator && wc -l $LOG && tail -40 $LOG"; fi
    ;;
fetch)
    mkdir -p scratch/sim
    if [ $# -eq 0 ]; then set -- '*.png'; fi
    for f in "$@"; do
        wsl_run "cd $WSL_DIR/verilator && cp $f \"\$(wslpath '$WIN_ROOT')/scratch/sim/\"" || true
    done
    ls -l scratch/sim | tail -20
    ;;
unit)
    NAME="${1:?usage: sim_wsl.sh unit <name>}"
    wsl_run "set -e
        mkdir -p $WSL_DIR
        cd \"\$(wslpath '$WIN_ROOT')\"
        rsync -a rtl verilator $WSL_DIR/
        cd $WSL_DIR/verilator/unit
        sed -i 's/\r\$//' *.sh 2>/dev/null || true
        if [ -f run_tb_$NAME.sh ]; then bash run_tb_$NAME.sh; else echo 'no run_tb_$NAME.sh'; exit 1; fi"
    ;;
-h|--help|"")
    awk 'NR>=2 { if ($0 !~ /^#/) exit; sub(/^# ?/,""); print }' "${BASH_SOURCE[0]}"
    ;;
*)
    echo "unknown command: $cmd (try --help)" >&2; exit 2 ;;
esac
