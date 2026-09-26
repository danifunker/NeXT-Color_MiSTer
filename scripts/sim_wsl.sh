#!/usr/bin/env bash
# scripts/sim_wsl.sh — build and run the Verilator sim under WSL from the Windows
# checkout. Run this from git-bash on the Windows box; it drives wsl.exe for you.
#
# Why a wrapper rather than "just run make in WSL":
#
#  1. BUILD ON ext4, NOT /mnt/c. Verilator emits ~40 C++ files and g++ writes as
#     many objects; across the 9p /mnt/c bridge that is several times slower than
#     copying the sources into the WSL filesystem first. This syncs to ~/MacQuadra800.
#  2. STRIP CRLF. Shell scripts checked out on Windows used to arrive with CRLF,
#     and a CRLF `#!/bin/sh` dies under dash with `set: Illegal option -` — which
#     is exactly how docs/tools/make-fastboot-rom.sh failed on 2026-08-29.
#     `.gitattributes` now pins `*.sh text eol=lf`, but this re-strips anyway so an
#     older checkout still works.
#  3. The sim must run from verilator/ (the ROM hex path is cwd-relative) and the
#     disk image should be a COPY — the sim writes to it.
#
# Usage:
#   bash scripts/sim_wsl.sh build                     # sync + build (+ ROM hexes)
#   bash scripts/sim_wsl.sh disk <local-image.hda>    # copy an image into WSL as run.hda
#   bash scripts/sim_wsl.sh run [extra Vemu args...]  # headless run against run.hda
#   bash scripts/sim_wsl.sh log [grep-pattern]        # tail / grep the run log
#   bash scripts/sim_wsl.sh -h
#
# The run is headless and logs to ~/MacQuadra800/verilator/sim_run.log inside WSL.
# Useful extra args (see verilator/sim_main.cpp):
#   +rom=quadra800.rom.hex        pristine ROM (default here is the fast-boot one)
#   --stop-at-pc 4080280e,4080281f   standing Sad Mac tripwire, dumps regs
#   --max-cycles N                N counts HALF-cycles (machine cycles = N/2)
set -u
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)" || exit 1

WSL_DIR='$HOME/MacQuadra800'
DISTRO="${WSL_DISTRO:-}"
wsl_run() {
    if [ -n "$DISTRO" ]; then wsl.exe -d "$DISTRO" -e bash -lc "$1"
    else wsl.exe -e bash -lc "$1"; fi
}

# Throughput reference (2026-08-29, 20 threads): ~2M half-cycles/s, i.e. ~34x
# slower than the 33 MHz hardware. A minute of real machine time is ~35 min here.
cmd="${1:-}"; shift 2>/dev/null || true

case "$cmd" in
build)
    echo "[sim] syncing sources -> WSL $WSL_DIR (ext4, not /mnt/c)"
    wsl_run "set -e
        mkdir -p $WSL_DIR
        cd \"\$(wslpath '$(pwd -W 2>/dev/null || pwd)')\"
        bash scripts/sync_main_mac.sh
        cp -r --parents rtl verilator docs/tools releases $WSL_DIR/
        find $WSL_DIR -name '*.sh' -exec sed -i 's/\r\$//' {} +
        cd $WSL_DIR/verilator
        make -j\$(nproc)
        make fastboot
        ls -l *.hex obj_dir/Vemu" || exit 1
    ;;
disk)
    IMG="${1:?usage: sim_wsl.sh disk <local-image.hda>}"
    [ -f "$IMG" ] || { echo "ERROR: no such image: $IMG" >&2; exit 1; }
    DEST="//wsl.localhost/${DISTRO:-Ubuntu-24.04}/home/$(wsl_run 'echo $USER' | tr -d '\r\n')/MacQuadra800/verilator/run.hda"
    echo "[sim] copying $IMG -> WSL run.hda (this is the sim's WRITABLE copy)"
    cp "$IMG" "$DEST" || exit 1
    wsl_run "cd $WSL_DIR/verilator && ls -l run.hda && md5sum run.hda"
    ;;
run)
    echo "[sim] headless run -> $WSL_DIR/verilator/sim_run.log"
    wsl_run "cd $WSL_DIR/verilator && exec ./obj_dir/Vemu --headless --no-cpu-trace \
        +rom=quadra800-fastboot.rom.hex --disk run.hda $* > sim_run.log 2>&1"
    ;;
log)
    PAT="${1:-}"
    if [ -n "$PAT" ]; then wsl_run "cd $WSL_DIR/verilator && grep -n '$PAT' sim_run.log | tail -40"
    else wsl_run "cd $WSL_DIR/verilator && wc -l sim_run.log && tail -20 sim_run.log"; fi
    ;;
-h|--help|"")
    awk 'NR>=2 { if ($0 !~ /^#/) exit; sub(/^# ?/,""); print }' "${BASH_SOURCE[0]}"
    ;;
*)
    echo "unknown command: $cmd (try --help)" >&2; exit 2 ;;
esac
