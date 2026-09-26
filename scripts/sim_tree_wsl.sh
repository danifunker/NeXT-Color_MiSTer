#!/bin/bash
# usage (inside WSL): bash scripts/sim_tree_wsl.sh <name> <commit>   -> ~/MQ_<name>, built Vemu + ROM hexes
set -e
name=$1; commit=$2
REPO=/mnt/c/Temp/mistercore/MacQuadra800_MiSTer
D=$HOME/MQ_$name
rm -rf "$D"; mkdir -p "$D"
git -c safe.directory='*' -c core.autocrlf=false -C $REPO archive $commit rtl verilator docs/tools releases/quadra800.rom | tar -x -C "$D"
mkdir -p "$D/verilator/sim/mac"
cp -p $REPO/verilator/sim/mac/* "$D/verilator/sim/mac/"
find "$D" \( -name '*.sh' -o -name Makefile \) -exec sed -i 's/\r$//' {} +
cd "$D/verilator"
( make -j7 && make fastboot ) > build.log 2>&1 || { echo "BUILD FAILED $name"; tail -20 build.log; exit 1; }
ls -l obj_dir/Vemu quadra800-fastboot.rom.hex
echo "BUILT $name ($commit)"
