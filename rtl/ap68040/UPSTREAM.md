# AP68040 in this repository

This directory is the AP68040 68040 CPU, vendored into MacQuadra800_MiSTer
on 2026-09-17. It used to be a git submodule (`alanswx/AP68040`); the CPU is
where most of this core's work happens now, so the files live here and are
edited and committed like the rest of the RTL.

## Where the tree came from

| what | commit |
|---|---|
| Adam Polkosnik's original core (`apolkosnik/AP68040`) | `0e76761` (2026-08-28), the common base of every fork |
| Alan Steremberg's performance stack (`alanswx/AP68040`, checkpoint 15) | `167c5e8` (2026-09-15) |
| our carrier hoisting R1..R4 (`docs/cpu-area-consolidation.md`) | `8778213` (2026-09-15), **the imported tree** |

`8778213` is what shipped in `releases/MacQuadra800_20260915.rbf` and later.
The two further hoists R5/R6 (`c789ffe`, `923c544` on the old submodule's
`wombat-area-diet` branch) were deliberately not imported: they are 1,300
ALMs smaller but miss the 33 MHz CPU clock, and are to be re-engineered
later.

The full pre-import history is still on this machine in
`.git/modules/rtl/ap68040` (browse it with
`git --git-dir=.git/modules/rtl/ap68040 log`) and on GitHub under
`alanswx/AP68040` and `apolkosnik/AP68040`.

## Taking upstream patches

Neither upstream tree merges: Adam's and Alan's sequencer and cache work
rebuilt the same mechanisms independently (Adam's own post-mortem is the
commit message of his `40_w_Alans_patches` branch, b117757). Patches are
ported by hand or applied one at a time:

```bash
git -C ../AP68040 show <commit> -- rtl/ap040_core.v | git apply -p1 --directory=rtl/ap68040 --3way
```

`docs/cpu-upstream-2026-09.md` records which of Adam's 2026-09 commits were
taken, which were not, and why.

## Local build substitutions

`rtl/primitives/dpram.v` here is the simulation stub. Quartus and the
Verilator full-machine sim resolve `dpram` to the project's
`rtl/dpram.v` (an altsyncram wrapper) instead; the Icarus self-test suite
uses the stub.

## Tests

```bash
cd rtl/ap68040/tb && sh run_tests.sh      # iverilog + vasm, see doc/tests-README
```

From Windows run it through WSL with `scripts/cpu_gates_wsl.sh <this dir> <label>`,
which also runs the profiled `bench_loop` and the corpus-100 silicon gate.

## NeXT-Color_MiSTer (2026-09-26)

Copied from `MacQuadra800_MiSTer/rtl/ap68040` at its commit `d1ce2a3`
("initial commit with CPU at ~85% of a real Quadra 800", 2026-09-25). Per the
NeXT_MiSTer CPU survey that tree equals `alanswx/wombat33_MiSTer` HEAD `6c8bfe9`
(`../old-quadra`) except one line in `ap040_core.v` (`brf_seed_a = 5'bxxxxx`).
The `8778213` in the table above is stale in both Quadra and NeXT_MiSTer.

**One local change to the core** (2026-09-26, user-authorized for this bug
only; otherwise no CPU code changes): `rtl/ap040_core.v`, the queue-fetch
fault branch (`else if (epf_pend && i_err)`, ~line 10280) no longer copies
the faulting fetch into the data channel's `mem_addr_q/mem_size/fc_r/
mem_write/mem_instr_q`.  `aerr_start(1)` builds the frame from `ifr_*`
(P171), so the copy had no consumer, and it corrupted an in-flight data
access when a fetch made ahead of demand faulted: a `jsr` in the last word
of a page whose next page is unmapped got an access error with FA = its own
return-address push, TM = code, PC = the `jsr` -- an endless fault loop
(NeXTSTEP `cc` hang, open question 39).  Regression test:
`verilator/cpu/t_pageend.s` via `verilator/cpu/run_pageend.sh`; the tree's
own `tb/asm` suite is unchanged (`verilator/cpu/run_asm_regress.sh`).
**Upstream candidate**: MacQuadra800 / wombat33 / NeXT_MiSTer carry the same
copy (`mem_addr_q <= ifr_addr; ... mem_instr_q <= 1;`).

Also found: under Verilator the MMU's `for (k = 0; k < 128; ...) atc_v[k] <= 0`
(PFLUSHA, reset) exceeds the default `--unroll-count 64` and is silently
dropped (BLKLOOPINIT), so PFLUSHA was a no-op in every Verilator build --
build with `--unroll-count 256` (verilator/Makefile, verilator/cpu/*.sh).
Icarus (the tree's run_tests.sh) and Quartus are unaffected.

What NeXT_MiSTer's `docs/CPU_NEXT_PORT.md` needed:

| item | here |
|---|---|
| 1 FPU revision parameter | passed through our `rtl/wombat_cpu.sv` (`AP040_FPU_REVISION`, `$41` for a Turbo, Previous m68000.c:114-118); the core already supports it |
| 2 debug_exception stubs, 3 tick_in | not applicable (`ap040_tg68k_compat` only; we use `wombat_cpu`) |
| 4 posted-store window | `rtl/wombat_cpu.sv` / `rtl/wombat_store_buffer.sv` parameters `POST_LO/HI` = `$04000000..$0CFFFFFF` (NeXT RAM + VRAM); cache window `NOCACHE_PAGE` = `$02` |
| 5, 6, 8 cache/MMU bugs under a gated `ce` | **not applied**: this core ties `ce` high (Quadra's mode; the v74 ROM needs no DBcc pacing, its delays use the event counter), so the bugs cannot occur |
| 7 crossing-read snoop guard | already fixed in this tree in another form (`xline_snoop_pending`) |
| 9 bus32 adapter / line sideband | `wombat_cpu` has both natively |
| 10 two-channel arbiter under gated ce (drop 2) | not applicable with `ce` = 1 |

Build macros as Quadra's release: `AP040_EXPERIMENTAL_XSTORE=1`,
`AP040_EXPERIMENTAL_LEA=1` (NeXT-Color.qsf, verilator/Makefile);
`experimental/ap040_pipeline_integer.sv` is compiled (the core instantiates it
under `AP040_EXPERIMENTAL_PIPELINE`, off).
