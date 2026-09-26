KNOWN = {
    # --- cache tag RAM selftest tail (NCC, Turbo only) ---
    0x01006018: ("post_cache_tag_test", "NCC cache tag RAM walking-pattern test (16 rotations of $D32B6D5B), prints failure; ret 0 ok / addr"),
    0x010060d6: ("post_cache_clear", "zero NCC cache tag RAM $03E00000 and data RAM $03F00000 (size from NCC reg bits 4:3); no caller found"),

    # --- boot command ('b') parser and boot driver ---
    0x0100610c: ("boot_cmd", "parse 'b [dev(ctrl,unit,part)] [file] [flags]' (default from NVRAM), run device open/load, ret entry pc"),
    0x01006560: ("boot_case_ok", "boot_cmd switch case 0: device opened, select 'Loading from ...' animation ($10 of dev entry)"),
    0x01006566: ("boot_case_flip_disk", "boot_cmd switch case 2: animation $13 of dev entry (od: 'Please flip disk')"),
    0x0100657a: ("boot_case_insert_disk", "boot_cmd switch case 3: animation $12 of dev entry (od: 'Please insert disk')"),
    0x0100658c: ("boot_case_no_media", "boot_cmd switch case 1: optical drive absent -> replace boot command by 'en' and restart"),
    0x0100662a: ("boot_case_error", "boot_cmd switch case 4/default: 'Bad disk/network' animation, od eject, wait 3 s, retry open"),
    0x0100660c: ("boot_cmd_diag_check_tail", "NOT a routine: tail of boot_cmd after strcmp(file,'diagnostics'); false pointer hits"),
    0x01006612: ("boot_cmd_reload_default", "NOT a routine: boot_cmd path that reloads NVRAM boot command and restarts the parse"),
    0x01006300: ("boot_cmd_paren_check", "NOT a routine: middle of boot_cmd (bne after cmpi ')'); false pointer at $01007894"),

    # --- boot-time level-3 interrupt (video frame / SCSI) and boot animation ---
    0x0100670a: ("boot_l3_isr", "level-3 ISR body: SCSI intr -> mg+$302 hook; video frame intr -> ack (per mg+$3BE) and animate"),
    0x010068be: ("boot_l3_isr_entry", "vector $6C (level-3 autovector) wrapper: save d0-d1/a0-a1, jsr boot_l3_isr, rte"),
    0x010068ba: ("boot_l3_isr_entry_link", "unused link.w prologue in front of boot_l3_isr_entry (compiler artifact)"),
    0x010067e0: ("boot_l3_isr_tmc_tail", "NOT a routine: Turbo branch of boot_l3_isr: TMC $02200080 := $05000000, animate, := $06000000"),
    0x0100680c: ("boot_anim_step", "advance boot panel animation: draw text/icon of table entry mg+$2FA, count down mg+$2FE, poll keyboard"),
    0x010068d2: ("boot_anim_set", "select animation sequence n (entry $0101A354+10n) into mg+$2FA/$2FE and install boot_anim_step at mg+$30E"),

    # --- kernel image loader ---
    0x01006914: ("boot_load_image_header", "parse a.out $0107 or Mach-O FEEDFACE/MH_PRELOAD header in buf, copy first chunk, ret bytes left"),

    # --- Ethernet boot device ('en'/'tp' entry ops at $0101A582) ---
    0x010069cc: ("enet_boot_open", "en ops[0]: alloc $73C-byte netboot state (dev+$20), server MAC=broadcast, enet_init; ret 0 ok / 4"),
    0x01006a2e: ("enet_boot_close", "en ops[1]: call netif devops[1] (enet shutdown)"),
    0x01006a44: ("tftp_load_kernel", "en ops[2]: BOOTP then TFTP RRQ (octet) of the boot file, load via image header, ret entry pc"),
    0x01006e12: ("bootp_request", "broadcast BOOTP request (ports 68->67, vendor 'NeXT'), retry w/ backoff, handle NeXT login prompt"),
    0x010071ec: ("net_arp_reply", "answer an ARP request for our IP: swap addresses, op=2, send through netif devops[3]"),
    0x010072a8: ("net_send_ip", "build ethernet+IP header (type $800, dst MAC state+$22, src state+$1C), checksum, pad to 60, send"),
    0x01007354: ("net_poll_recv", "netif read into state buffer; answer ARP; ret frame length if IP frame addressed to us else 0"),
    0x0100743c: ("net_ip_checksum", "16-bit ones-complement sum over len bytes (IP/UDP checksum, caller inverts)"),

    # --- console / printf family ---
    0x01007480: ("con_putc_crlf", "putc with CR inserted before LF (console)"),
    0x010074b2: ("vid_draw_char", "draw glyph c from font metrics $0101A4D0+6c at cursor mg+$1CE/$1D2 (bpp mg+$324); LF = newline"),
    0x0100766e: ("print_char_sink", "printf output: dest 0 console, 1 screen text, 2 log buffer mg+$320 (or console), else string ptr"),
    0x010076d2: ("print_number", "print unsigned/signed number in base with zero-pad/width to sink; args val,base,zero,width,sink"),
    0x01007772: ("printf", "printf(fmt,...) to the console (vprintf dest 0)"),
    0x0100778a: ("sprintf", "sprintf(buf,fmt,...) (vprintf with dest = buf)"),
    0x010077a4: ("vid_printf_at", "clear boot panel text area (opt) and print fmt at screen x,y (dest 1, sets mg+$1CE/$1D2)"),
    0x0100785c: ("printf_log", "printf(fmt,...) to dest 2: verbose log buffer mg+$320, or console when mg+$170 bit3 set"),
    0x01007876: ("vprintf", "format engine: %% %0 %1-9 %D %d %u %O %o %X %x %c %l %s %b(BSD bit names); args fmt,dest,argp"),
    0x01007b06: ("vprintf_case_s", "vprintf case %s"),
    0x01007b24: ("vprintf_case_pct", "vprintf case %%"),
    0x01007926: ("vprintf_case_b", "vprintf case %b: value + BSD-style bit/field description string (base byte, <BIT,..>)"),
    0x01007904: ("vprintf_case_c", "vprintf case %c: prints the 4 bytes of the long, high to low, non-zero 7-bit chars"),
    0x010078d6: ("vprintf_case_zero", "vprintf case %0: set zero-pad flag"),
    0x010078da: ("vprintf_case_width", "vprintf case %1..%9: accumulate field width"),
    0x010078e0: ("vprintf_case_hex", "vprintf case %x/%X: base 16"),
    0x010078e4: ("vprintf_case_dec", "vprintf case %d/%D/%u: base 10"),
    0x010078e8: ("vprintf_case_oct", "vprintf case %o/%O: base 8"),
    0x01007b38: ("print_line", "printf(s) followed by newline"),

    # --- line input and number parsing (monitor) ---
    0x01007b5c: ("con_gets", "read a line (buf,size,echo): ^H/DEL erase, ^U kill, ^W word erase, CR/LF end; ret len+1, -1 on $FF"),
    0x01007ca8: ("str_skip_space", "skip spaces, tabs, CR, LF; ret pointer to first other char"),
    0x01007cd8: ("parse_number", "parse [-][~](0t|0x)digits[.digits..] into *out (dotted = byte-packed); base 0 = mg+$192; ret ptr/0"),

    # --- memory helpers ---
    0x01007dd6: ("mem_alloc", "mg_alloc(n): mg+$EC (alloc_brk) -= n, bzero, ret pointer (installed at mg+$2EA)"),
    0x01007e0c: ("abs_l", "abs(long); unreferenced"),
    0x01007e16: ("mem_cmp", "bcmp(a,b,n): ret 0 equal, 1 different (long-wise when aligned)"),
    0x01007ec8: ("mem_move", "bcopy(src,dst,n) with overlap handling (byte loops; the long fast path at +$26 is dead code)"),
    0x01007ffc: ("mem_zero", "bzero(p,n): byte-align then long clears"),
}
