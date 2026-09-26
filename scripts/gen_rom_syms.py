#!/usr/bin/env python3
"""Write the simulator's ROM symbol table from rom-dissassembly/known_names.py.

Output: one line per named routine, "ADDRESS NAME" (hex address, no 0x), sorted.
The Verilator harness (verilator/sim_main.cpp) loads it for the named PC trace
and to resolve the reset-step checkpoints.

    python3 scripts/gen_rom_syms.py [out]        (default verilator/rom_syms.txt)
"""
import importlib.util
import os
import sys

here = os.path.dirname(os.path.abspath(__file__))
root = os.path.dirname(here)
src = os.path.join(root, "rom-dissassembly", "known_names.py")
out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(root, "verilator", "rom_syms.txt")

spec = importlib.util.spec_from_file_location("known_names", src)
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

with open(out, "w", newline="\n") as f:
    for addr in sorted(mod.KNOWN):
        name = mod.KNOWN[addr][0]
        f.write("%08X %s\n" % (addr, name))
print("%d symbols -> %s" % (len(mod.KNOWN), out))
