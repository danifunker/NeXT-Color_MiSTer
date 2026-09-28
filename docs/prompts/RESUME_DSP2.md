# Prompt: resume the NeXT-Color DSP / Music Kit work and the seed walk (session 6)

Paste everything below the line into a fresh Claude Code session started in
`C:\Temp\mistercore\NeXT-Color_MiSTer`.

---

Continue the NeXT-Color (NeXTstation Turbo Color) MiSTer core work.  Repo
`C:\Temp\mistercore\NeXT-Color_MiSTer`, branch `master`; the ARM side lives in
`C:\Temp\mistercore\Main_MiSTer`, branch `next-color` (never switch it).  Read
first: `RESUME-20260927.md` (sessions 4 and 5 -- the "Session 5" sections are
this work), `RESUME-20260926.md` (rules, gotchas), `docs/DECISIONS.md` ("Sound
and DSP", "SCSI CD-ROM", Video: Y/C and VGA OSD), the Readme (rewritten this
session), memory notes.

## First thing: the seed walk

A seed walk was running when the last session ended:
`STOP_NS=0.000 bash scratch/seedwalk_wait.sh 1 2 3 4 5 6 7 8` on commit
**8129e3f** (log `scratch/seedwalk_vgaosd.log`, results appended to
`scratch/seedwalk/results.txt`).  It waits until no `quartus_*` process has run
for 30 s before each seed (the PC's Quartus is shared with another project, an
SGI Indy core that runs its own seed walks: never two flows at once), sets
`SEED n` in the qsf, runs `scripts/build_only.sh`, keeps an rbf in
`scratch/rbf/` only when all hold slacks are >= 0 and clk_sys/clk_ram/clk_vid
meet setup (HDMI may miss), and stops at the first seed that meets timing
everywhere.  Check whether it is still running (`tasklist | grep quartus_`,
the log); if the session ended it, restart it from the next seed not in the
log, e.g. `STOP_NS=0.000 bash scratch/seedwalk_wait.sh 3 4 5 6 7 8` (run it in
the background; each seed ~20 min, the first after an RTL change ~23 min).
Never edit RTL / qsf / qip / sys while a flow of ours runs.  When it ends, put
the qsf back to the committed `SEED 1` (`git checkout NeXT-Color.qsf`) unless
a seed is being committed (then commit `SEED n` with its numbers).

Timing so far (worst setup / hold, ns; `scratch/seedwalk/results.txt`):
- d0fee87 seed 1: +0.212 / +0.239 -- the last clean build (on the MiSTer now).
- faa8e1a s1: HDMI -0.434 (trial ran fine); s2-s4 worse.
- 37c52da s1: HDMI -0.287 + clk_ram HOLD -0.105 (rejected); s2: sys -0.131 /
  HDMI -0.515 (trial ran fine).
- 863fafc s1: sys -0.079 only (trial ran fine).
- 06de5d4 s1: HDMI -0.044 only, but **DEAD on the MiSTer** (black screen, no
  POST, no disk access; seed 2 of the same RTL shows the POST -> a bad fit);
  s2: sys -0.541, HDMI -0.487 (only tested to the POST).
- 4d9cbd9 (Y/C off) s1: HDMI -0.429 + clk_ram HOLD -0.061 (rejected); **s2:
  sys -0.136 only, HDMI +0.075, holds ok** -> trial candidate
  `scratch/rbf/NeXT-Color_4d9cbd9_seed2_sys-0.136_e42b563b.rbf` (not yet run).
- 8129e3f (VGA OSD off, ~514 ALMs less): the walk above.

Deploy rule (user): a build that misses timing may be tried only with
NeXTSTEP shut down; reject hold violations on the memory clock (general[1]);
small clk_sys setup misses (-0.08..-0.14, all inside ap040_core epf_data)
have run fine.  Always check a new build reaches the POST before letting
NeXTSTEP mount the disk, and **keep the last working rbf until the new one is
verified** (a verified trial was deleted too early this session).

## Where things stand

- **CD-ROM** (faa8e1a): the drive is always on the SCSI bus; hot insert works
  (the user mounted `games/NeXT-Color/NeXTSTEP-Apps3.iso` with NeXTSTEP up: it
  appeared as /NeXTSTEP-Apps3).  That CD has the Music Kit 5.6.2 source
  (libdsp, the DSP monitor `smsrc`), Music Kit apps (Calliope, Sequence,
  SynthBuilder, ...) and 27 scores; the scores were copied to
  `/LocalLibrary/Music/Scores` on the NeXT disk (playscore finds them by
  name).  Extracted sources: `scratch/mk/mksrc/`, scores `scratch/mk/scores/`.
- **DSP / Music Kit fixes this session** (all bench-tested in tb_tc_dsp, each
  with a case that fails on the old code):
  1. a385b18 TRDY: tx_out lost an "HRX read" arriving with a TX word.
  2. 37c52da + Main 0de89be: HC clears at once for the host (NeXTSTEP resets
     the DSP if a host command is not taken in ~0.5 ms); Main holds later
     H2D messages while a command is pending.
  3. 863fafc + Main 208725a: while a command's handler runs the host sees
     HF2/HF3 = 1/0 (hc_pend), Main sends R_HCACK when the handler returns
     (Music Kit relies on HF3 never turning on inside a host message).
  4. Main f60f002: the slice ends when a held command is taken, so the host's
     INIT after HOST_R_DONE comes before the handler's ack (it was dropped).
  5. 06de5d4: DSP DMA goes to the DSP only with TREQ alone (NeXTSTEP writes
     ICR $53 during a DSP->host DMA; the pump sent memory into the DSP and
     wrecked the host message stack), requests qualified by direction.
- **On hardware**: Examp1 (`playscore -w /tmp/ex1 Examp1`) renders fully and
  correctly with fixes 1-3 (WAV `scratch/mk/Examp1_dsp.wav`).  CoventryCarol
  died each time on the next bug (fix 3 -> 2,224 buffers then fix 4 -> 32 s
  then fix 5); **fix 5 has not run on hardware yet** (its seed-1 build was the
  dead one).  Live playscore: the DSP runs at ~1/8 speed, cannot keep up.
- **.143 now**: `_Unstable/NeXT-Color.rbf` = copy of
  `NeXT-Color_d0fee87_seed1.rbf` (b2753af2, the pre-fix FPGA; boots), Main
  a643220f (next-color f60f002; backup MiSTer.bak-20260927-3dce86a8).
  NeXTSTEP may be running on it (writable disk: shut it down before loading
  anything).  Local rbfs: 2cd616c (release), d0fee87 s1, 4d9cbd9 s2 trial.
- **Area** (fit of 4d9cbd9 s1, 39,920 ALMs = 95%): CPU 25,600 (core 21,804),
  sys ~6,300 (ascal 1,906, audio_out 942 incl. IIR 463, hdmi_osd 538, vga_osd
  514 -- now removed, pll_hdmi_adj 541, video_calc 262, shadowmask 135),
  tc_scsi 1,791, tc_tdma 894, tc_memsys 1,116, tc_kms 569, floppy 546, enet
  708, tc_dsp 303.  The user chose Y/C off (4d9cbd9) and VGA OSD off
  (8129e3f).  Other options were offered, not chosen: the Quadra's
  MISTER_BYPASS_AUDIO_FILTER (463), MISTER_DISABLE_VIDEO_CALC (262),
  MISTER_DISABLE_SHADOWMASK (135), stock MISTER_DOWNSCALE_NN, CPU macros off,
  tc_scsi arrays to RAM.  Ask before adding any.

## Next steps (ask the user which)

1. Seed walk result -> deploy the best build (clean, or the 4d9cbd9 s2 /
   an 8129e3f trial): shut NeXTSTEP down, load, check the POST, boot, log in.
2. Rerun `playscore -w /tmp/cc CoventryCarol` with ringmon (below); if it
   stalls again: ring log, DSP core dump, gdb on playscore.
3. Other scores (BachFugue 44.1 kHz, Jungle's FM patches), the CD's Music Kit
   apps, live playscore.
4. Report the DO-loop bug (Main 6a3ae03) upstream to Previous; a dated
   release; the RESUME.

## Tools (all in `scratch/`, gitignored)

- Screenshots `python grab.py OUT.png` (`grab_fb.py` if blank).  Keys:
  `python ../../NeXT_MiSTer/tb/hw/type_text.py "text" ENTER` (csh: `|&`;
  a here-doc with a QUOTED terminator never ends in NeXT csh -- use `<< EOF`),
  `python ws_send.py kbdRawDown:29 kbdRaw:46 kbdRawUp:29` = Ctrl-C,
  Cmd = keycode 125.  Clicks: `NEXT_HW_SCRATCH=. timeout 170 python
  guest_click.py X Y [click|dclick]` (Terminal = dock (1085,543), dclick;
  it needs up to ~60 s).  The OSD is NOT in screenshots: never drive it
  blind (SPACE = select, BACKSPACE in a file browser = unmount).
- Login: type `root`, 2 s, Enter, 1 s, Enter; do it twice after a boot.
- Shutdown: in a root Terminal `sync; sync; halt` (make sure no program is
  hanging in that Terminal first: Ctrl-C), then wait for
  `stat -c %y /media/fat/games/NeXT-Color/disk0.hda` to stay quiet 30 s.
- Deploy rbf: scp to `/media/fat/_Unstable/NeXT-Color.rbf`,
  `echo "load_core /media/fat/_Unstable/NeXT-Color.rbf" > /dev/MiSTer_cmd`.
  New Main: `bash scripts/build_main_wsl.sh` in WSL, stage as
  `/media/fat/MiSTer.new`, then (NeXTSTEP down) swap, `reboot`, load_core, and
  re-copy `dspbench/memdump dspbench/ringmon dspbench/coredump ufsls.py` to
  /tmp (chmod +x).
- DSP link: `devmem 0x30400010` (PC, msgs, flags 4 link/2 run/1 bootstrap),
  `0x30400014` (instr/1024); `python ring_dump.py [N]`;
  `/tmp/ringmon SECS [f] > log` (taskset -c 1; timestamps, control messages;
  `f` = every message).
- DSP state out of the running Main: `/tmp/coredump $(pidof MiSTer)
  0x001627a0 0x010399c0 > dump.txt` (dsp_core, dsp_ram for Main a643220f;
  other builds: `nm scratch/MiSTer_<md5>.elf`), then
  `dspbench/dsp_state dump.txt [FROM TO | x ADDR N | y ADDR N]` (WSL).
- gdb on NeXTSTEP: `gdb /usr/bin/playscore PID`, `bt`, `thread-list`,
  `thread-select N`; libdsp statics: `x/s **(char ***)0x040805f0`
  (s_wd_error_str) etc. (`scratch/mk/macho.py libdsp_s.A.shlib NAME`).
- 68k disassembly of shlibs: `scratch/mk/dis68.py`, `disall.py` (Capstone).
- NeXT UFS images (CDs, the hard disk, read-only): `ufsls.py IMAGE [OUT] |
  --cat PATH | --grep WORDS | --extract DIR OUTDIR` (python3 on the MiSTer).
- Monitor symbols `scratch/mk/mkmon_syms.txt`; DSP message codes
  `scratch/mk/mksrc/MKDSP_56k/dsp_messages_1.0.h` (03 HOST_R_DONE, 05
  HOST_R_REQ, 0a TMQ_LWM, 11 IAA; errors $8x/$9x: $94 DE_HMSBUSY).
- Benches: `bash scripts/sim_wsl.sh unit tc_dsp` (+ real ARM pace:
  `wsl -e bash -c '/tmp/tb_tc_dsp/obj/tb_tc_dsp +arm_every=700 +arm_slice=32'`),
  `unit tc_scsi`; full sim `bash scripts/sim_wsl.sh build` / `run ...`.
- Builds: `bash scripts/build_only.sh`; `scratch/wait_build.sh` (waits for
  Quartus); `scratch/seedwalk_wait.sh` (above).

## Rules (user)

No downloads without OK; never load a core over a running NeXTSTEP (shut it
down gracefully first); never MGL loads; commit on master with `area: what
and why` messages (Co-Authored-By line); rbf retention <= 3 local, <= 2 on the
MiSTer; don't alter CPU core code; every register cites Previous /
hardware-summary; keep the RESUME current; no resume prompt unless asked.
