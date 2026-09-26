# Prompt: targeted fix for the page-end prefetch fault loop (open question 39)

Paste everything below the line into a fresh Claude Code session started in
`C:\Temp\mistercore\NeXT-Color_MiSTer`.

---

Fix one CPU bug in the NeXT-Color MiSTer core, as small and targeted as possible.
Repo `C:\Temp\mistercore\NeXT-Color_MiSTer`, branch `master`. Read
`RESUME-20260926.md` (newest RESUME) and `docs/OPEN-QUESTIONS.md` item 39 first.
**This prompt is the user's authorization to change the CPU core
(`rtl/ap68040/rtl/ap040_core.v`) for this bug only**; the standing rule "don't
alter CPU core code" still holds for everything else.

## Symptom (hardware, 2026-09-26)

NeXTSTEP 3.3 boots and runs on the core, but every `cc` hangs: NWBench's
Compile test and a one-line `cc -c t.c` alike. gdb on the stuck `cc`: PC =
`$5FFE`, the instruction `jsr (a3)` (a3 = `$9C9C`) in the **last word of an 8 KB
page**; `si` never returns. `vm_stat`: "Translation faults" rise ~4,000/s (5.8M
since boot) with no page-ins: the kernel repairs a fault and the CPU takes it
again, forever. The mono NeXT core (older CPU tree) compiles the same code fine.

## Reproduction (bare CPU, no NeXT-Color logic)

`verilator/cpu/t_pageend.s` puts `jsr (a3)` at `$5FFE` (target `$7000` valid,
next page `$6000` INVALID) and checks every access error against a real 68040;
`verilator/cpu/run_pageend.sh` builds the CPU tree's own program bench
(`rtl/ap68040/tb/tb_ap040_program.v`) under Verilator (iverilog is not
installed) with and without the two experimental options:

    wsl -e bash -lc 'cd /mnt/c/Temp/mistercore/NeXT-Color_MiSTer && bash verilator/cpu/run_pageend.sh'

Current (buggy) result, both configurations, all three bench phases:
`FAIL: program reports failure, test 91` with repeated fault stamps
`fa01 / 0000 / 33fc / 0506 / 5ffe` = case 1, FA `$000033FC`, SSW `$0506`
(ATC fault, read, TM 6 = supervisor code), stacked PC `$5FFE`. FA `$33FC` is the
`jsr`'s own return-address push (a valid page). A real 68040 lets the `jsr`
complete (the sequential prefetch into `$6000` is discarded by the flow change)
and faults only after the target's `rts` returns to `$6000`: one fault, FA
`$6000`, TM 6, stacked PC `$6000`.

## Root cause (hypothesis to verify first)

`ap040_core.v`, the queue-fetch fault branch (`else if (epf_pend && i_err)`,
around line 10279):

    // the frame builder (aerr_start) reads the faulting request from
    // the mem_* registers: carry the fetch's over (P171)
    mem_addr_q <= ifr_addr; mem_size <= ifr_size; fc_r <= ifr_fc;
    mem_write <= 0; mem_instr_q <= 1;
    ...
    if (epf_kill || epf_flushed) begin /* abandoned */ end
    else if ((state == S_FETCH || state == S_IMMF) &&
             epf_count == 4'd0 && epf_next == ifr_addr) begin
        if (in_exc) fatal_halt; else aerr_start(1);
    end
    else epf_err <= 1;        // fetched ahead of demand: only recorded

The copy into the data channel's `mem_*` / `fc_r` registers runs
**unconditionally**, also when the fault is only recorded (`epf_err`) or the
fetch was abandoned. In the failing case the data channel is busy with the
`jsr`'s push to `$33FC`: the copy turns it into an instruction-space READ of
`$6000` (invalid), that access faults on the data channel, and
`aerr_start(0)` builds the frame from `m_addr_r` (`$33FC`), the overwritten
`fc_r` (6) and `mem_write` (0) -- exactly the observed frame. RTE restarts the
`jsr`, the prefetch faults again, and the cycle repeats.

`aerr_start(1)` already takes FA/size/FC from `ifr_*` (`from_ifr` selects them,
around line 2390), so the copy looks needed at most for the immediate case.
Minimal fix to try: perform the `mem_*`/`fc_r` copy only when the access error
is taken now (the `aerr_start(1)` branch), or only when the data channel is
idle -- whichever the surrounding code shows is correct. Check the
recorded-fault re-arm path (`epf_err` / `epf_armed` / `epf_ftail`, right after
this branch): when execution later reaches the faulting word, the fetch is
re-issued and must fault with its own live context. Read enough of the
`epf_*` fetch-queue logic (tasks `issue_ifetch`, `epf_flush`, `aerr_start`;
the comments cite "P171") to be sure no other consumer relies on the copy.
If the hypothesis is wrong, find the real cause with the same test before
changing anything.

## Acceptance

1. `run_pageend.sh`: all eight cases pass in both configurations (cases 1-4
   caches off, 5-8 caches on). Case 1 must show exactly one fault, FA `$6000`,
   TM 6, stacked PC `$6000`. Note: the mono tree (`NeXT_MiSTer/rtl/ap68040`)
   and upstream `C:\Temp\mistercore\AP68040` already fault correctly at `$6000`
   but then re-fault there in this bench (`CPU_TREE=... bash run_pageend.sh`);
   if this tree does the same after the fix, decide whether the test's handler
   or the core is wrong (compare `rtl/ap68040/tb/asm/t_mmu.s`'s
   instruction-fetch-fault case, which passes) and fix the right one.
2. The CPU tree's own regression is unchanged: record a baseline BEFORE the
   fix by running every `rtl/ap68040/tb/asm/*.s` program through the same
   Verilator bench (extend run_pageend.sh or add a sibling script; assemble
   with `~/local/bin/vasmm68k_mot -Fbin -m68040 -no-opt`, hex with
   `tb/bin2hex.py`, run `+prog=<hex>`), then again after it: no new failures.
3. Full-machine sim (`scripts/sim_wsl.sh build`, `verilator/README.md`):
   `run +rom=rom_fast.hex --pot-on --max-cycles 80000000` still prints
   "System test passed" and reaches `mon_command_loop`; the SCSI boot
   `run +rom=rom_fast.hex --boot sd --disk0 /home/dani/next_prof/ns33_color.hda
   --max-cycles 220000000` still reaches `[BOOT]` and the kernel (before the
   fix: boot program at 37,031,202 cycles, the kernel's NCC probe at
   181,969,122; small shifts are fine).
4. Build: `NeXT-Color.qsf` currently has the two `AP040_EXPERIMENTAL_*` macros
   commented out (an uncommitted A/B experiment that proved them irrelevant);
   restore them (`git checkout -- NeXT-Color.qsf`) unless the user decides
   otherwise. `bash scripts/build_only.sh`; timing must be met (worst slack
   >= 0); if not, seed-walk (`scratch/seedwalk.sh <seeds>`).
5. Hardware (192.168.99.143; no need to ask before MiSTer actions this
   session): NeXTSTEP is running there with a writable disk -- shut it down
   first (wake with a mouse move, log in as root with no password, Workspace
   Log Out -> Power Off; wait until `games/NeXT-Color/disk0.hda` stops
   changing). Deploy (`scripts/deploy_screenshot.sh`), log in, then in a
   Terminal `cd /tmp; echo "int main(){return 0;}" > t.c; time cc -c t.c`
   must finish, and NWBench (`open /me/NWBench.NIHS.bs/NWBench.app`, Compile
   button) must report a time (mono core: 170.7 s). Input tools:
   `NeXT_MiSTer/tb/hw/type_text.py`, `scratch/guest_click.py`,
   `scratch/ws_send.py`, screenshots `scripts/grab_fresh.sh`.

## Rules (from the user)

- Git bash builds; never two Quartus flows; never edit files.qip, the qsf or
  RTL while a flow runs; no git worktrees; commit on `master` with
  `area: what and why` messages.
- Every build's rbf into `scratch/rbf/`; after the experiment keep the best 3
  locally and at most 2 on the MiSTer.
- Don't edit `sys/`. No downloads without OK. Never load a core over a running
  guest with a writable disk.
- Document: note the local CPU change in `rtl/ap68040/UPSTREAM.md` (the tree is
  imported from MacQuadra800 and is an upstream candidate), update
  `docs/OPEN-QUESTIONS.md` 39 and the RESUME, and keep `t_pageend` as the
  regression test.
