# Prompt: resume the NeXT-Color DSP56001 work (session 4, 2026-09-27)

Paste everything below the line into a fresh Claude Code session started in
`C:\Temp\mistercore\NeXT-Color_MiSTer`.

---

Continue the DSP56001 work on the NeXT-Color (NeXTstation Turbo Color) MiSTer
core.  Repo `C:\Temp\mistercore\NeXT-Color_MiSTer`, branch `master`; the ARM side
lives in `C:\Temp\mistercore\Main_MiSTer`, branch `next-color` (never switch it).
Read first: `RESUME-20260927.md` (this session), `RESUME-20260926.md` (rules,
gotchas, older state), `docs/DECISIONS.md` "Sound and DSP", memory notes.

## Where things stand

- **Sound out works on hardware** (commit 85522cb; user confirmed).  No sound
  input and no DSP serial ports by design (user decision).
- **The DSP56001 runs on the MiSTer's ARM** (user choice "ARM now, FPGA later"):
  Previous r1851's interpreter in Main (`support/next/next_dsp.cpp` +
  `support/next/dsp56k/`, host port split), a thread on ARM core 0.  The FPGA
  keeps the 68040's side of the host port (`rtl/tc_dsp.sv`: ICR/CVR/ISR/IVR,
  TX/RX, HREQ, INIT, DMA byte pump, SCR2 DSP bits, int -> status bit 14) and
  the DSP DMA channel (`rtl/tc_tdma.sv` dd_*).  They trade the host port's
  internal transfers through a DDR3 mailbox at $30400000 (protocol in the
  header of next_dsp.cpp; FPGA word +0, ARM word +8, status +$10, H2D ring
  +$1000, D2H ring +$2000).
- Build on .143: `_Unstable/NeXT-Color.rbf` = d0fee87 seed 1 (qsf SEED 1,
  +0.212 ns, 39,652 ALMs = 95%, md5 b2753af2); fallback
  `_Unstable/NeXT-Color_85522cb_seed2.rbf` (sound only).  Main on .143 =
  c2e7cfad (next-color 6a3ae03); old Main kept as
  `/media/fat/MiSTer.bak-20260927-50aff88c`.  Local rbfs in `scratch/rbf/`:
  d0fee87 seed1, 85522cb, 2cd616c (max 3 locally, 2 on the MiSTer).
- **Hardware results**: `sndplay` of a mono 22 kHz sound (Sound Kit's
  mono.snd DSP program, 4096-word DMA buffers) plays in real time and sounds
  right (user); mu-law 8 kHz plays through the DSP in real time ("landline",
  as G.711 should).  Two bugs fixed on the way (Main 67f650c, 6a3ae03): RX
  depth 1 (as the real host port), and a Previous interpreter bug -- a JSR
  landing on LA+1 was taken for the end of a DO loop.
- Mandelbrot.app (/NextDeveloper/Demos) does NOT use the DSP by default (it
  draws on the 68040; the DSP counter stays still).
- Speed: ~1.5 M DSP instructions/s on ARM core 0 (12% of a 25 MHz 56001).
  64-bit 56-bit helpers (`scratch/dspbench/fast56.c`, `patch_fast56.py`) are
  bit-exact but only +5% on the A9; not applied.  ARM gprof: time spread over
  parallel moves, address generation (modulo), dispatch.

## Was doing when the session ended

Looking for Music Kit score files to test `playscore` (the heavy DSP user):
the last command typed in the NeXT Terminal was
`ls /NextLibrary/Music /LocalLibrary/Music /NextDeveloper/Examples/MusicKit;
find /NextLibrary /LocalLibrary /NextDeveloper -name '*.score'`
(screenshot `scratch/hw_scores.png`).  NeXTSTEP is RUNNING on .143, logged in
as root, Terminal open -- shut it down gracefully before loading anything.

## Next steps (ask the user which)

1. Music Kit: `playscore` a score (expect it slower than real time at 12%);
   Sound.app; `sndconvert` compressed sounds (hostdecompress.snd).
2. ARM speed: targeted interpreter work (parallel-move/AGU paths), a check
   of the link latencies (FPGA active poll 4 us, ARM slice ends at spin loops).
3. Report the DO-loop bug upstream to Previous (fix text in Main 6a3ae03).
4. A dated release (`releases/`) with the DSP build + the next-color Main.
5. The mono NeXT core could get the same ARM DSP (non-Turbo SCR2/DMA glue;
   its M10K is at 90%).

## Tools and how-tos (all in `scratch/`, gitignored)

- Screenshots: `python grab.py OUT.png` (MiSTer Remote API).  If Main's
  screenshot saves nothing (seen once after a reboot: no scaler header),
  `python grab_fb.py OUT.png` reads the scaler buffer (stride 3584, offset 192).
- Input: `python ws_send.py kbdRaw:28 ...`, `python ../../NeXT_MiSTer/tb/hw/type_text.py "text" ENTER`
  (csh: use `|&`, not `2>&1`), `NEXT_HW_SCRATCH=. python guest_click.py X Y [click|dclick]`,
  `python fb_click.py X Y` (steers the pointer with small moves).
- Login: root, empty password; type `root` (no Enter), wait 2 s, Enter,
  wait 1 s, Enter (the first attempt after boot is often lost).  Terminal =
  the "MACH" icon at dock (1085,543), double-click.
- Graceful shutdown: in the root Terminal `sync; sync; halt` (-> NeXT>), or
  Workspace Cmd-Q (`kbdRawDown:125 kbdRaw:16 kbdRawUp:125`) -> Power Off, or
  the login panel's Power (747,500) + Return; then watch
  `stat -c %y /media/fat/games/NeXT-Color/disk0.hda` until quiet (~30 s).
- Deploy: scp the rbf to `/media/fat/_Unstable/NeXT-Color.rbf`, then
  `echo "load_core /media/fat/_Unstable/NeXT-Color.rbf" > /dev/MiSTer_cmd`.
  New Main: `bash scripts/build_main_wsl.sh` (in WSL) -> scratch/MiSTer_<md5>,
  copy to /media/fat/MiSTer, `reboot`, then load_core.  After a reboot re-copy
  `dspbench/memdump` and `dspbench/ringmon` to /tmp on the MiSTer.
- DSP link state: `devmem 0x30400004` ($D5F1+gen), `0x3040000C` ($D5A1+gen),
  status `0x30400010/14` ([63:32] instr/1024, PC, msgs, flags: 4 link, 2 run,
  1 bootstrap).  `python ring_dump.py [N]` = last N messages each way;
  `/tmp/ringmon SECS [f] > log` on the MiSTer (taskset -c 1) follows the rings
  live (f = every message).  `dspbench/proto.c` replays a captured session
  (`tx_all.txt`) through Main's DSP core on x86; `dspbench/dis` disassembles
  DSP words.
- Benches: `bash scripts/sim_wsl.sh unit tc_dsp` (tc_dsp + Main's
  next_dsp.cpp through DPI; `+arm_every=700 +arm_slice=32` = real ARM pace),
  `unit tc_scsi` (DMA channels incl. sound/DSP), `unit tc_kms` (sound box);
  full sim `bash scripts/sim_wsl.sh build` / `run +rom=rom_fast.hex --pot-on
  --max-cycles 72000000 --stop-at-pc 1001dd8` (NeXT> at 70,865,640).
- Builds: `bash scripts/build_only.sh` (~22 min; never two Quartus flows,
  never edit RTL/qsf/qip during one); seed walk `STOP_NS=0.000 bash
  scratch/seedwalk.sh 1 3 4 ...`.  Git Bash heredocs mangle backslashes:
  write scripts with the Write tool.

## Rules (user)

No downloads without OK; never load a core over a running NeXTSTEP (shut it
down gracefully yourself first); never MGL loads; commit on master with
`area: what and why` messages (Co-Authored-By line); rbf retention <=3 local,
<=2 on the MiSTer; don't alter CPU core code; every register cites Previous /
hardware-summary; keep the RESUME current.
