#!/bin/bash
# Cross-build the Main fork (../Main_MiSTer, branch next-color -- never switch
# it) for the DE10-Nano inside WSL.  From MacQuadra800_MiSTer's script of the
# same name: rsync the tree to ~/Main_MiSTer (ext4; the /mnt/c tree is slow
# and case-insensitive), build from no objects at all (stale objects from an
# older checkout once survived a header change there), and copy the binary
# to scratch/MiSTer_<md5[:8]>.  Installing it on the MiSTer is a separate,
# deliberate step (scripts/local.env names the host).
#   wsl.exe -e bash -lc 'bash /mnt/c/Temp/mistercore/NeXT-Color_MiSTer/scripts/build_main_wsl.sh'
set -e
HERE=$(cd "$(dirname "$0")/.." && pwd)
SRC=${SRC:-$HERE/../Main_MiSTer}
DST=${DST:-$HOME/Main_MiSTer}
TC=/opt/gcc-arm-10.2-2020.11-x86_64-arm-none-linux-gnueabihf/bin
BRANCH=$(git -C "$SRC" rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)
[ "$BRANCH" = next-color ] || { echo "Main_MiSTer is on '$BRANCH', expected next-color"; exit 1; }
mkdir -p "$DST" "$HERE/scratch"
rsync -a --delete --exclude .git --exclude bin --exclude "*.o" --exclude "*.d" "$SRC/" "$DST/"
cd "$DST"
if [ "${CLEAN:-1}" = 1 ]; then rm -rf "$DST/bin"; fi
git -C "$SRC" log --oneline -1 2>/dev/null || true
PATH=$TC:$PATH make -j8
BIN=MiSTer; [ -f bin/MiSTer ] && BIN=bin/MiSTer
MD5=$(md5sum "$BIN" | cut -c1-32)
cp "$BIN" "$HERE/scratch/MiSTer_${MD5:0:8}"
echo "built MiSTer md5 $MD5 -> scratch/MiSTer_${MD5:0:8}"
