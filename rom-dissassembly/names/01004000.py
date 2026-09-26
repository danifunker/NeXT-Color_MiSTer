# Names for ROM range $01004000..$01005FFF (Rev 3.3 v74).
# See notes/01004000.md for the evidence behind every entry.

KNOWN = {
    # --- TMC / cache / LED primitives ---------------------------------------
    0x01004072: ("tmc_parity_init_range", "rewrite longs a0..a1 with TMC ctrl bit10 set per word; leaves bit10 set. Turbo only. args: start,end"),
    0x010040a8: ("cache_push_data", "cpusha dc: push dirty data cache lines"),
    0x010040ac: ("cache_inval_set_cacr", "cinva both caches, set CACR from arg; returns old CACR in d0"),
    0x010040bc: ("cache_get_cacr_push", "d0 = CACR, then cpusha dc"),
    0x010040c4: ("led_on", "SCR2 |= 1 (SCR2_LED) via displacement arg (normally 0)"),
    0x010040d6: ("led_off", "SCR2 &= ~1 (SCR2_LED) via displacement arg (normally 0)"),
    0x010040e8: ("led_blink_halt", "C entry: blink LED $4(a7) times, long pause, repeat forever (never returns)"),
    0x010040ec: ("led_blink_loop", "asm entry, a0 = blink count: SCR2 LED on/off n times, pause, loop forever"),
    0x01004142: ("snd_out_clear_underrun", "KMS_Ctrl_Snd |= $20 (SNDOUT_DMA_UNDERRUN) with ints off; Turbo version"),
    0x01004156: ("snd_out_clear_underrun_wait", "wait KMS TX bit6 while SNDOUT enabled, then KMS_Ctrl_Snd |= $20; non-Turbo"),
    0x0100418e: ("crc32_calc_asm", "CRC-32 poly $04C11DB7 of d3 bytes at a1, LED on during calc, result d0, jmp (a0)"),
    0x010041e2: ("crc32_calc", "C wrapper: crc32(buf $8(a6), len $c(a6)); continuation at $010041fe, d0 = CRC"),
    0x010041fe: ("crc32_calc_ret", "continuation of crc32_calc: restore regs, unlk, rts"),

    # --- boot picture (icon) drawing, mg+$324 = pixels per long -------------
    0x01004208: ("vid_span_2bpp", "expand run of 2bpp pixels (byte val, count) into 2bpp framebuffer via mg+$33c lut"),
    0x01004274: ("vid_span_8bpp", "expand run of 2bpp pixels into 8bpp framebuffer (byte per pixel) via mg+$33c lut"),
    0x010042f4: ("vid_span_16bpp", "expand run of 2bpp pixels into 16bpp framebuffer (word per pixel) via mg+$33c lut"),
    0x01004378: ("vid_span_32bpp", "expand run of 2bpp pixels into 32bpp framebuffer (long per pixel) via mg+$33c lut"),
    0x010043fc: ("vid_draw_image_onscreen", "ints off, mg+$368 := mg+$374 (visible fb), vid_draw_image(x,y,img), restore"),
    0x01004440: ("vid_draw_image", "draw NeXT image struct (type 'B' RLE,'U' raw,'S' table-RLE) at x,y; picks span fn by depth"),
    0x01004512: ("vid_draw_rle_image", "type 'B': (value,count) byte pairs per row, calls span fn"),
    0x0100457a: ("vid_draw_raw_image", "type 'U': packed 2bpp rows expanded per depth; raw copy if mg+$348 == -1"),
    0x0100471c: ("vid_draw_tbl_rle_image", "type 'S': n (value,count) table then index bytes per row"),

    # --- POST helpers --------------------------------------------------------
    0x010047ac: ("post_delay_9us", "delay(9) wrapper used between register accesses in tests"),
    0x010047be: ("snd_out_clear_underrun_any", "non-Turbo (mg+$194==$139): snd_out_clear_underrun_wait else snd_out_clear_underrun"),
    0x010047e6: ("post_scsi_dma_isr", "ISR frame: save regs, post_scsi_dma_intr, rte (unused in POST: SCSI DMA int)"),
    0x0100480a: ("post_timer_isr", "level-6 autovector ISR frame used by post_timer_test: calls post_timer_ack"),
    0x0100481a: ("post_snd_out_isr", "level-6 autovector ISR frame used by sound test: calls post_snd_out_dma_stop"),
    0x0100483e: ("post_fpu_test", "run fpu_test_regs(1), fpu_test_formats(2), fpu_test_arith(3); d0 = failing sub-test or 0"),
    0x01004872: ("post_snd_in_dma_reset", "ISR body: sound-in DMA CSR $020000c0 = RESET|INITBUF(non-Turbo)/BUFRESET(Turbo)"),
    0x010048a6: ("post_scc_test", "Z8530 loopback via $02118000: WR9 reset, 20-byte init table, tx/rx $40 both channels; d0 1-7"),
    0x01004a16: ("post_scsi_dma_intr", "printf \"SCSI DMA intr?\\n\""),
    0x01004a2a: ("post_scsi_test", "ESP reset via ESP_DMA_CTRL $02114020, chip reset, FIFO 0..4 write/read check; d0 1-3"),
    0x01004ada: ("post_ext_scsi_test", "ESP FIFO flush, transfer count $5555/$AAAA, config reg 0..255, illegal cmd INTR_ILL; d0 4-8"),
    0x01004bf0: ("post_enet_test", "AT&T7213 loopback: drain rx, send/recv 1500B self-addr, filter test, broadcast; d0 1-7"),
    0x01004f12: ("post_ecc_test", "MO drive (OSP $02112000) ECC encode/corrupt/correct via disk DMA $02000050; cubes only; d0 1-6"),
    0x010052d0: ("post_rtc_test", "wait up to 1.1 s for RTC seconds reg ($20 old chip / $23 new) to change; d0 1 on timeout"),
    0x01005338: ("post_timer_ack", "timer ISR body: read hardclock CSR $02116004, write 0 (disable)"),
    0x0100534e: ("post_timer_test", "hardclock counter write/latch/readback 0..$FFFF then 1000us periodic int must fire; d0 2,3"),
    0x01005440: ("post_evcnt_test", "event counter $0211A000 must tick, delay(1000) in 899..1100us, 100 deltas within 3; d0 1-3"),
    0x0100553a: ("post_evcnt_measured", "event counter test: measured delay(1000) in d0 (us)"),
    0x010055f2: ("post_snd_out_overrun_intr", "printf \"Sound Out Over Run Interrupt.\\n\""),
    0x01005606: ("kms_send_cmd", "wait KMS TX bit4 clear, KMS_Ctrl_Cmd $0200E003 = cmd, KMS_Data $0200E004 = data, delay 200us"),
    0x01005634: ("post_snd_out_dma_stop", "ISR body: sound-out DMA CSR $02000040 = RESET(+INITBUF/BUFRESET), KMS cmd 7 (snd out off)"),
    0x0100567e: ("kms_set_volume", "bit-bang volume chip via KMS CTRLOUT ($C4): 11 bits, chan sel $40/$80, 6-bit volume"),
    0x01005758: ("post_snd_out_test", "play 8KB buffer (arg 1 silence / 0 sine) via sound-out DMA $02004040; d0 1 DMA err, 2 not done"),
    0x01005a46: ("post_run_all", "POST master: FPU,SCC,SCSI,Enet,ECC(cubes),RTC,Timer,EvCnt,[SoundOut],[ExtSCSI]; d0 error code"),
    0x01005aa2: ("post_ret_fpu", "POST master: FPU test returned (d0); error code $40|n"),
    0x01005ad2: ("post_ret_scc", "POST master: SCC test returned (d0); error code $50|n"),
    0x01005b26: ("post_ret_enet", "POST master: Enet test returned (d0); error code $70|n"),
    0x01005b5e: ("post_ret_ecc", "POST master: ECC test returned (d0); error code $80|n"),
    0x01005b8e: ("post_ret_rtc", "POST master: RTC test returned (d0); error code $90|n"),
    0x01005bbe: ("post_ret_timer", "POST master: Timer test returned (d0); error code $C0|n; then EvCnt $D0|n, SoundOut $E0|n"),
    0x01005c64: ("post_ret_ext_scsi", "POST master: Ext SCSI (and SCSI) returned (d0); error code $60|n; loop-mode key wait"),
    0x01005cd2: ("nvram_check_or_rtc_ramtest", "read NVRAM: ok -> d0 = POT byte & $10 (TEST_DRAM); bad -> walking-1 RTC RAM test, LED 4 blinks, d0=1"),

    # --- FPU tests (68040 FPU, all machine types) -----------------------------
    0x01005d44: ("fpu_test_regs", "fmovem 8 patterns x 256 rotations through fp0-fp7, compare; d0 != 0 on error"),
    0x01005d82: ("fpu_test_regs_pattern", "inner: push 8 x (d1,d2,d3), fmovem in/out, compare 256 shifted variants"),
    0x01005dd2: ("fpu_test_formats", "fmove.l/.s/.d/.x round trips of 1024 ints from $8000; d0 != 0 on error"),
    0x01005e1c: ("fpu_test_arith", "fadd/fsub/fmul/fdiv/fsqrt/fcmp + fsave/frestore 1024 times; d0 != 0 on error"),

    # --- NCC secondary cache (Nitro 40 MHz board only) ------------------------
    0x01005ea0: ("ncc_cache_data_test", "Nitro NCC: size from NCC bits4:3, test $03F00000 data RAM AA/55/pattern; d0 = fail addr or 0"),
}
