# Open questions

Things the core does one way on thin evidence. Each says what was chosen, why,
and what would settle it. "HS n" = `rom-dissassembly/hardware-summary.md` section n.

## System

1. **Interrupt mask always-on bits.** `tc_intc.sv` ORs Previous's Turbo
   `INT_ZEROBITS` `$C22E7600` into every mask write and hides them on read
   (sysReg.c IntRegMaskRead/Write). That makes SCSI (12), the video/ADB interrupt
   (13), SCC (17) and a few DMA bits unmaskable. Consistent with the ROM (its
   level-3 boot ISR also services the SCSI chip), but not verified on hardware or
   in the kernel sources. Settle: `software/kernel-sources/` (NeXTSTEP headers),
   or a real Turbo Color.
2. **SCR1 presentation.** `$0200C000` reads `$F0004000` (type 4) and the TMC copy
   `$02200000` reads `$FFFF5FDF` (type 5), Previous's scheme (HS 1.1). The memory
   speed field says 70 ns (Previous's MEMORY_100NS default maps to mem field 1).
   Real boards may differ; the ROM only uses it for the banner and the TMC
   control value.
3. **TMC control bit 10 (parity enable) is forced to 0 on write**, as Previous
   does. The ROM's parity probe (HS 3.3) then concludes "no parity SIMMs" without
   an NMI. If a real TMC keeps the bit, the ROM expects an NMI from a parity
   error on non-parity memory; we never raise it.
4. **TMC registers not modelled**: parity data/address/status read 0; anything
   below `$8000` outside SCR1/control/NMI/video/timing reads 0 (Previous does the
   same, "unimplemented").

## Video

5. **Bt463 display model**: only palette entries `n<<4` (n = 0..15) of each
   channel are kept and used as a per-channel 16-entry LUT (window type `$000100`
   = 24-plane true colour + read masks `$F0`, HS 4.2). If NeXTSTEP programs other
   window types, read masks or the upper palette half, the picture will not
   follow. Settle: log the Bt463 writes the OS makes once it boots.
6. **Pixel clock.** 100 MHz from the "video mode 25 MHz" SCR2 bit x 4-pixel TMC
   units; the real Turbo Color refresh is 68 Hz, the sim uses 99 MHz. The 832x624
   mode (SCR2 bit 12 clear) is not offered.
7. **Frame interrupt timing**: raised at the start of the vertical blank. The
   real TMC may raise it elsewhere in the frame; the ROM only needs one per frame.

## Memory

8. **Absent RAM banks read 0** (Previous returns the address). Either fails the
   ROM's `$55555555`/`$AAAAAAAA` probe, which is all that matters.
9. **VRAM mirrors** every 2 MB across `$0C000000-$0CFFFFFF` (Previous's mask).
   `$0D000000-$0FFFFFFF` bus-error.

## Devices

10. **KMS NMI key and power key** choices: see `rtl/tc_kms.sv` header.
11. **RTC**: see `rtl/tc_mccs1850.sv` header for the default NVRAM image and
    what is modelled of the MCCS1850.

## KMS (rtl/tc_kms.sv, from the unit-bench author's notes)

12. **NMI status bit.** Previous raises INT_NMI for the keyboard NMI without
    setting NMI_RECEIVED; `tc_kms` sets NMI_RECEIVED (`$0200E001` bit 4) and drives
    `nmi` from it, as kms.c's register comment and HS 15 describe. The ROM's
    `mon_clear_nmi` clears it either way. Confirm against NeXTSTEP's NMI handler.
    Keys: Left/Right Win (= Command) + backquote (Previous's three combinations),
    or **F11** alone. Previous's reset combination (Left Win + Left Alt + keypad *)
    pulses `reset_req`.
13. **Magic reset needs TX_LOOP**: `$C6 $1000A825` resets only with TX_LOOP set,
    which is what `kms_send_reset` does.
14. **Keys wait for KMS_ENABLE** (`ori.b #2,$0200E002`), as in Previous; the mono
    core did not gate them.
15. **Sound bits read 0** until the sound engine is attached (Previous keeps
    SNDOUT/SNDIN_DMA_ENABLE r/w).
16. **Power key is a pulse** (F10 down); Previous also calls
    `rtc_stop_pdown_request` on release.
17. Small deviations from Previous: status byte 3 reads `$C6` after a KM message;
    `$E004` reads back the last write; a mouse packet waits behind an unread key
    (keys overwrite with overrun).
18. **Pause key** (inherited): hps_io sends only a make of `$77`, which the table
    maps to backquote: NeXTSTEP would see a stuck backquote, and Win+Pause is an NMI.

## RTC / NVRAM (rtl/tc_mccs1850.sv, from the unit-bench author's notes)

19. **SIMM word** in the default image (`$0009` 64 MB, `$0249` 128 MB, `$0012`
    16 MB, `$0001` 32 MB; parity bits at bit 12+i, which HS 12.3 calls "9+i")
    assumes TMC control bit 10 always reads 0 (no parity) and the bank aliasing
    of HS 3.3. If either changes, the ROM prints "Memory sockets ... configured
    for ..." and rewrites NVRAM.
20. **POWERDOWN is ignored**: no power-off output; the ROM spins at `$010083ce`.
    A `power_off` output could blank the screen and let the power key restart.
21. FIRSTUP, LBAT, ALARM never set; no alarm compare (as Previous). Only Previous
    was consulted, not the MCCS1850 datasheet.
22. **No NVRAM persistence** (user decision): every OSD/power-up reset rebuilds
    `$00-$1F`, so changes made with the monitor's `p` command are lost. Time is
    not re-seeded at an OSD reset.
23. Byte 17 is `$A0` (new clock chip + console slot bits, as Previous); the mono
    core and the ROM's own default use `$00`.
24. Bytes 4-9 are 0 (Previous copies the Ethernet address); the ROM uses its
    header address `00:00:0f:12:34:56` because it is not `FF FF FF`.
25. Boot commands must be 11 characters or fewer (a 12-character one has no NUL).

## SCSI / TDMA (rtl/tc_scsi.sv, rtl/tc_tdma.sv, from the unit-bench author's notes)

26. **CLRCOMPLETE is conditional** (next_scsi / NetBSD rule: only on a running
    channel or with SETENABLE; a completion in the same clock wins). Previous
    clears it unconditionally.
27. **SETCOMPLETE and CSR FLUSH do nothing** (as Previous); the Turbo NeXTSTEP
    driver might use them.
28. **BUSEXC survives a channel RESET** (Previous, NetBSD); only machine reset
    clears it.
29. `dma_interrupt` needs ENABLE and uses Next >= Limit (next_scsi also completed
    a disabled channel at Next == Limit).
30. hardware-summary 9.3 correction: `scsi_intr` pulses the flush 4 times, not 3.
31. Selection timeout follows Previous's 20 MHz formula (~314 ms per try, 3 tries
    per absent target): a boot disk that is not target 0 costs ~1 s per absent
    lower target.
32. Only the SCSI and Ethernet TX/RX channels move data (the Ethernet ones
    since the T7213 model); sound out/in, printer and DSP are registers only.
33. **DMA targets DRAM only** (tc_machine): a channel pointed at VRAM, ROM or
    I/O gets m_err -> COMPLETE|BUSEXC.  Previous DMAs to any memory bank.
    Nothing in the ROM does it; NeXTSTEP might (e.g. a DMA into the frame
    buffer).  Settle: log BUSEXC once the OS runs.
34. **Snoop on DMA writes only.**  A DMA read of a line the 68040 holds dirty
    in a copyback D-cache returns the memory copy (the real 68040 would
    intervene).  The ROM runs write-through; NeXTSTEP is expected to push
    caches before DMA (as the mono core relies on).

## Ethernet (rtl/tc_enet.sv, Ethernet channels of rtl/tc_tdma.sv)

35. **Frames land at offset 0** of the receive buffer (Previous dma.c:839-843).
    hardware-summary 8.1/16.3 says the real Turbo chip deposits them one byte
    late, and the ROM's enet_read handles both.  NeXTSTEP's Turbo driver runs
    on Previous with offset 0.  Settle: a real Turbo, or the driver sources.
36. **No RX status bus error.**  Previous bus-errors a read of `$02006002`
    when neither TPE nor LOOP is set and no thin-wire cable is connected
    (new_enet_buserror, ethernet.c:615-626); tc_enet always answers.
37. **No network attachment**: outside loopback every frame ends in 16
    collisions (Previous "disconnected"), and BADTPE reads 1 whenever TPE is
    selected.  Network boot and NeXTSTEP networking need an HPS bridge (the
    mono core's Main next_enet) -- not started.
38. **CRC bytes are zeros**: an accepted frame is stored 4 bytes longer
    (Previous len += 4), padded to 64; Previous leaves stale buffer bytes
    there, a real chip the FCS.

## CPU / MMU under NeXTSTEP

39. **`cc` hangs in a translation-fault loop** (hardware, seed 3, 2026-09-26):
    every `cc` run spins at a `jsr (a3)` in the last word of an 8 KB page
    ($5FFE), ~4,000 translation faults/s, no page-ins, the instruction never
    completes.  The mono core (same CPU tree without the AP040_EXPERIMENTAL
    macros, gated ce) compiles fine.  Settle: a directed page-end fault test
    in the sim, and an A/B build without the experimental macros.
    **Reproduced on the bare CPU** (`verilator/cpu/t_pageend.s`, run with
    `verilator/cpu/run_pageend.sh`): `jsr (a3)` at $5FFE, target valid, the
    NEXT page $6000 invalid.  This tree (the Quadra drop) takes an access
    error DURING the jsr: FA = $33FC (the jsr's own stack push, a valid page),
    SSW $0506 (ATC, read, TM 6 = supervisor code fetch), stacked PC $5FFE --
    the prefetch of $6000 that the jsr should discard, reported with the data
    address; the handler repairs the wrong page and the jsr faults again,
    exactly the NeXTSTEP loop.  Identical with and without
    AP040_EXPERIMENTAL_XSTORE/LEA (so the macros are not the cause).  The mono
    core's tree (NeXT_MiSTer) and upstream AP68040 let the jsr complete and
    fault correctly at $6000 after the return (FA $6000, PC $6000); in this
    bench they then re-fault at $6000, which looks like a bench/handler
    artefact of those trees (the mono core compiles fine on hardware).  The
    fix is in ap040_core.v's early-prefetch fault handling (CPU core code:
    needs the user's go-ahead).
    **FIXED (2026-09-26, user-authorized CPU change)**: `ap040_core.v`'s
    queue-fetch fault branch copied the faulting fetch into the data
    channel's `mem_addr_q/mem_size/fc_r/mem_write/mem_instr_q`
    unconditionally -- also when the fault was only recorded (`epf_err`,
    fetched ahead of demand) and a data access (the jsr's push) was in
    flight.  `aerr_start(1)` builds the frame from `ifr_*`, so the copy had
    no consumer; removed.  `run_pageend.sh`: cases 1-5 give exactly one
    fault with the real-040 shape (case 1: FA $6000, SSW $0506, PC $6000);
    the tree's tb/asm suite is unchanged (29 pass before and after).
    The "re-fault at $6000" of the mono/upstream trees was **a Verilator
    artefact**: the MMU's 128-entry `atc_v[k] <= 0` loop (PFLUSHA) exceeds
    `--unroll-count 64` and is silently dropped (BLKLOOPINIT), so PFLUSHA
    never cleared the ATC in any Verilator build here (this also explained
    5 tb/asm failures: t_mmu 60, t_atcprobe, t_bitfield_mmu, t_movem_restart,
    t_moves_fc).  Fixed with `--unroll-count 256` in verilator/Makefile and
    verilator/cpu/*.sh.  Case 6 fails a bench FC check: see 40.
40. **Bench FC check in `t_pageend` case 6** (caches on, target page invalid):
    `tb_ap040_program.v` reports "exception/reset data cycle used FC=1,
    expected 5" -- a supervisor-stack READ of $3BFC in core state 111 during
    the access-error entry with a stale `fc_r=1`.  Pre-existing and identical
    in the mono tree (NeXT_MiSTer); upstream `C:\Temp\mistercore\AP68040`
    passes all 8 cases.  Not the cc hang (the mono core runs NeXTSTEP with
    it).  Settle: diff that state's FC source against upstream.
