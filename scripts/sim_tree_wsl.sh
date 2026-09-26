#!/bin/bash
# usage (inside WSL): bash scripts/sim_tree_wsl.sh <name> <commit>
# Builds the sim of any commit in ~/NC_<name> (from MacQuadra800's script).
set -e
name=$1; commit=$2
REPO=/mnt/c/Temp/mistercore/NeXT-Color_MiSTer
D=$HOME/NC_$name
rm -rf "$D"; mkdir -p "$D"
git -c safe.directory='*' -c core.autocrlf=false -C $REPO archive $commit rtl verilator releases rom-dissassembly scripts | tar -x -C "$D"
find "$D" \( -name '*.sh' -o -name Makefile \) -exec sed -i 's/\r$//' {} +
cd "$D/verilator"
make -j$(nproc) > build.log 2>&1 || { echo "BUILD FAILED $name"; tail -20 build.log; exit 1; }
ls -l obj_dir/Vemu rom.hex
echo "BUILT $name ($commit)"
