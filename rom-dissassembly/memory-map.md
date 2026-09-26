# Absolute addresses outside ROM and device space

Every absolute address the reached code names that is not a ROM address and not a named device register: RAM work areas, VRAM, TMC/NCC regions, cache, low memory.
Regions come from Previous's `cpu/memory.c` for the Turbo configuration.

Only address operands are listed here (absolute EA, or immediates loaded into an address register / stored as a pointer); plain immediates are in the second table.

| address | region | kind | uses | routines | instructions |
|---|---|---|---:|---|---|
| 021a0340 | ? | areg | 1 | tmc_alt_timing_color | 0100c69c move.l #$21a0340, (a0) |
| 03e00000 | NCC cache tag RAM | areg | 6 | mg_init_type6_7 mg_init_typeA_B post_cache_clear post_cache_tag_test | 01000d8e move.l #$3e00000, $3ce(a3)<br>01000db4 move.l #$3e00000, $3ce(a3)<br>01006048 movea.l #$3e00000, a0<br>0100605a movea.l #$3e00000, a0 ... |
| 03f00000 | NCC cache data RAM | areg | 6 | ncc_cache_data_test post_cache_clear | 01005ebe movea.l #$3f00000, a0<br>01005ef0 movea.l #$3f00000, a0<br>01005f38 movea.l #$3f00000, a0<br>01005f56 movea.l #$3f00000, a0 ... |
| 04000000 | RAM bank 0 (Turbo: 32 MB stride) | abs/areg | 5 | mem_dram_probe mon_reenter_704_frame reset_install_vectors vid2_enable vid_color_enable | 010005a6 pea.l $4000000.l<br>0100066c pea.l $4000000.l<br>01003dfc lea.l $4000000.l, a0<br>0100beb0 move.l #$4000000, (a0) ... |
| 04002000 | RAM bank 0 (Turbo: 32 MB stride) | areg | 1 | post_snd_out_test | 010057a2 movea.l #$4002000, a3 |
| 04100000 | RAM bank 0 (Turbo: 32 MB stride) | areg | 2 | vid_draw_panel vid_init_display | 01009b00 move.l #$4100000, $158(a2)<br>0100b298 move.l #$4100000, $374(a4) |
| 05000000 | RAM bank 0 (Turbo: 32 MB stride) | areg | 3 | boot_case_error boot_l3_isr_tmc_tail exc_dispatch | 01001a36 move.l #$5000000, (a0)<br>010066b2 move.l #$5000000, (a0)<br>010067f0 move.l #$5000000, (a2) |
| 06000000 | RAM bank 1 | areg | 2 | boot_cmd_paren_check boot_l3_isr_tmc_tail | 010064be move.l #$6000000, (a0)<br>010067fc move.l #$6000000, (a2) |
| 08000000 | RAM bank 2 | abs/areg | 2 | reset_pick_stack vid_console_init | 01000450 lea.l $8000000.l, a6<br>0100ada0 move.l #$8000000, (a0) |
| 0b000000 | RAM bank 3 | abs | 1 | reset_pick_stack | 01000492 lea.l $b000000.l, a0 |
| 0c000000 | VRAM (Turbo; color 2 MB at $0C000000) | abs | 1 | reset_pick_stack | 010004bc lea.l $c000000.l, a0 |
| 12345678 | RAM MWF mirrors (non-Turbo mono only) | areg | 2 | mem_bank_size_nt mem_bank_size_t | 01002dd8 move.l #$12345678, (a0)<br>010035bc move.l #$12345678, (a2) |
| 20000000 | ? | areg | 1 | post_timer_test | 010053ea move.l #$20000000, (a0) |
| 29044118 | ? | areg | 1 | tmc_alt_timing_color | 0100c690 move.l #$29044118, (a0) |
| 55505550 | ? | areg | 2 | vid_init_color_1120x832 vid_init_color_832x624 | 0100ba54 move.l #$55505550, $344(a0)<br>0100bbd0 move.l #$55505550, $344(a0) |
| 55555555 | ? | areg | 6 | mem_bank_absent_t mem_report_error_nt mem_report_error_t ncc_cache_data_test vid_init_mono_1120x832 | 01002d30 move.l #$55555555, (a3)<br>010033c8 move.l #$55555555, (a3)<br>01003546 move.l #$55555555, (a0)<br>0100354c move.l #$55555555, $4(a0) ... |
| 5b02b118 | ? | areg | 1 | tmc_alt_timing_mono | 0100c6aa move.l #$5b02b118, (a0) |
| 80000000 | ? | areg | 1 | vid_console_init | 0100ad94 move.l #$80000000, (a0) |
| 80008000 | ? | areg | 1 | mem_burst_test_nt | 01003d6a movea.l #$80008000, a0 |
| 89abcdef | ? | areg | 2 | mem_bank_size_nt mem_bank_size_t | 01002dde move.l #$89abcdef, (a1)<br>010035ca move.l #$89abcdef, (a0) |
| aaa0aaa0 | ? | areg | 2 | vid_init_color_1120x832 vid_init_color_832x624 | 0100ba4c move.l #$aaa0aaa0, $340(a0)<br>0100bbc8 move.l #$aaa0aaa0, $340(a0) |
| aaaaaaaa | ? | areg | 6 | mem_bank_absent_t mem_report_error_nt mem_report_error_t ncc_cache_data_test vid_init_mono_1120x832 | 01002d04 move.l #$aaaaaaaa, (a3)<br>010033a4 move.l #$aaaaaaaa, (a3)<br>01003554 move.l #$aaaaaaaa, $8(a0)<br>0100355c move.l #$aaaaaaaa, $c(a0) ... |
| abcdef01 | ? | areg | 2 | mem_bank_size_nt mem_bank_size_t | 01002de4 move.l #$abcdef01, (a2)<br>010035d0 move.l #$abcdef01, (a1) |
| edcba987 | ? | areg | 1 | mem_write_read_long | 01002e32 move.l #$edcba987, (a0) |
| fff0fff0 | NextBus slot space | areg | 2 | vid_init_color_1120x832 vid_init_color_832x624 | 0100ba44 move.l #$fff0fff0, $33c(a0)<br>0100bbc0 move.l #$fff0fff0, $33c(a0) |

## Plain immediates that look like addresses or 32-bit constants

Values used with andi/ori/cmpi/move to data registers or memory: masks, test patterns, magic numbers, and timing constants.  A region name is only a hint.

| value | region hint | uses | routines | instructions |
|---|---|---:|---|---|
| 01020000 | ROM | 1 | reset_int_mask_crc | 010003d8 move.l #$1020000, d3 |
| 01234567 | ROM | 2 | mem_burst_test_nt | 01003d50 move.l #$1234567, (a0)+<br>01003d7e cmpi.l #$1234567, (a0)+ |
| 01770000 | ROM | 1 | tmc_reset_config | 01000326 ori.l #$1770000, d0 |
| 01f40000 | ROM | 1 | tmc_reset_config | 010002ec ori.l #$1f40000, d0 |
| 01fffff6 | ROM | 2 | kms_console_init kms_read_key | 0100993c move.l #$1fffff6, -(a7)<br>0100a314 move.l #$1fffff6, -(a7) |
| 03e00000 | NCC cache tag RAM | 1 | post_cache_tag_test | 01006034 move.l #$3e00000, d0 |
| 03f00000 | NCC cache data RAM | 1 | ncc_cache_data_test | 01005f22 addi.l #$3f00000, d5 |
| 03ffffff | NCC cache data RAM | 2 | nbus_op_block_store nbus_op_jump | 0100b4d2 andi.l #$3ffffff, d2<br>0100b7a6 andi.l #$3ffffff, d3 |
| 04000000 | RAM bank 0 (Turbo: 32 MB stride) | 22 | kms_set_volume mem_build_regions mem_config_test_nt mem_config_test_t mem_print_bad_socket_t mem_report_error_t mem_test | 01000438 adda.l #$4000000, a6<br>01000456 adda.l #$4000000, a6<br>0100232e move.l #$4000000, d0 ... |
| 04002000 | RAM bank 0 (Turbo: 32 MB stride) | 1 | mem_config_test_t | 0100389e move.l #$4002000, -(a7) |
| 04008380 | RAM bank 0 (Turbo: 32 MB stride) | 1 | tmc_reset_config | 010002be move.l #$4008380, d0 |
| 04800000 | RAM bank 0 (Turbo: 32 MB stride) | 1 | od_complete | 0100f8c8 andi.l #$4800000, d0 |
| 04c11db7 | RAM bank 0 (Turbo: 32 MB stride) | 1 | crc32_calc_asm | 010041b0 eori.l #$4c11db7, d0 |
| 06000000 | RAM bank 1 | 1 | kms_set_volume | 010056ee move.l #$6000000, d1 |
| 08000000 | RAM bank 2 | 20 | enet_init mem_bmap_size_dram_4 mem_bmap_size_dram_6 mem_build_regions mem_config_test_t mem_print_bad_socket_t mem_repor | 010002e6 ori.l #$8000000, d0<br>01000320 ori.l #$8000000, d0<br>01000ab4 addi.l #$8000000, d3 ... |
| 09000000 | RAM bank 2 | 1 | dma_bytes_moved | 01011b28 cmpi.l #$9000000, $10(a1) |
| 092b4d6f | RAM bank 2 | 2 | mem_burst_test_nt | 01003d5c move.l #$92b4d6f, (a0)+<br>01003d96 cmpi.l #$92b4d6f, (a0)+ |
| 0b000000 | RAM bank 3 | 8 | mon_init vid_init_mono_1120x832 | 01001012 move.l #$b000000, d4<br>01001044 move.l #$b000000, d0<br>01001162 move.l #$b000000, d4 ... |
| 0c000000 | VRAM (Turbo; color 2 MB at $0C000000) | 17 | mon_init vid_init_color_1120x832 vid_init_color_832x624 vid_init_mono_1120x832 vid_vram_test | 0100101a move.l #$c000000, d4<br>0100104c move.l #$c000000, d0<br>0100116a move.l #$c000000, d4 ... |
| 0f000000 | VRAM MWF mirrors (non-Turbo mono only) | 3 | enet_rx_dma_start enet_rx_int | 0100963e andi.l #$f000000, d0<br>010096fe andi.l #$f000000, d1<br>01009842 andi.l #$f000000, d1 |
| 0fffffff | VRAM MWF mirrors (non-Turbo mono only) | 1 | vid_draw_panel | 01009c22 andi.l #$fffffff, d0 |
| 10000000 | RAM MWF mirrors (non-Turbo mono only) | 3 | bootp_request kms_read_key post_snd_out_test | 01005862 move.l #$10000000, d3<br>01007148 ori.l #$10000000, $3ae(a0)<br>0100a2d8 ori.l #$10000000, $3ae(a2) |
| 1000a825 | RAM MWF mirrors (non-Turbo mono only) | 1 | kms_send_reset | 0100987a move.l #$1000a825, -(a7) |
| 10412270 | RAM MWF mirrors (non-Turbo mono only) | 1 | tmc_reset_config | 0100038a move.l #$10412270, $220008c.l |
| 12345678 | RAM MWF mirrors (non-Turbo mono only) | 4 | mem_bank_size_nt mem_bank_size_t mem_write_read_long | 01002dfa cmpi.l #$12345678, d0<br>01002e2c move.l #$12345678, (a0)+<br>01002e3c cmpi.l #$12345678, -(a0) ... |
| 165a10d0 | RAM MWF mirrors (non-Turbo mono only) | 1 | tmc_reset_config | 01000380 move.l #$165a10d0, $2200088.l |
| 1b000000 | RAM MWF mirrors (non-Turbo mono only) | 1 | dma_stop | 0100eb9e andi.l #$1b000000, d0 |
| 20000000 |  | 2 | enet_write mem_bmap_size_dram_4 | 01000a7a move.l #$20000000, $20c001c.l<br>010094ba andi.l #$20000000, d0 |
| 2c000000 | color VRAM (non-Turbo color station) | 9 | vid_init_color_1120x832 vid_init_color_832x624 vid_vram_test | 01003b04 move.l #$2c000000, d0<br>0100ba6a move.l #$2c000000, d0<br>0100ba86 move.l #$2c000000, d0 ... |
| 30000000 |  | 2 | mem_bmap_size_dram_4 vid_draw_panel | 01000b62 move.l #$30000000, $20c001c.l<br>01009c2c andi.l #$30000000, d1 |
| 3fffffff |  | 1 | enet_read | 010091ba andi.l #$3fffffff, d0 |
| 40000000 |  | 10 | exc_dispatch kms_send_cmd_wait mem_bmap_size_dram mem_config_test_nt od_cmd_start reset_nonturbo040_bmap | 0100020c move.l #$40000000, $20c0034.l<br>01000218 move.l #$40000000, $20c0030.l<br>01000992 ori.l #$40000000, $20c0004.l ... |
| 4e655854 |  | 2 | boot_check_label disk_label_check | 0100edd0 cmpi.l #$4e655854, (a0)<br>01010224 cmpi.l #$4e655854, (a1) |
| 50000000 |  | 1 | mem_bmap_size_dram_3 | 01000a2c move.l #$50000000, $20c001c.l |
| 55505550 |  | 2 | vid_vram_test | 01003b1a move.l #$55505550, (a2)+<br>01003b2e move.l #$55505550, d3 |
| 55555555 |  | 11 | fpu_test_regs mem_bank_absent_t mem_dram_probe mem_report_error_nt mem_report_error_t ncc_cache_data_test vid_vram_probe | 01002cfe move.l #$55555555, (a3)+<br>01002d12 cmpi.l #$55555555, -$4(a6)<br>0100339e move.l #$55555555, (a3)+ ... |
| 60000000 |  | 1 | od_cmd_seek_low | 0100f678 ori.l #$60000000, $21c(a3) |
| 6302f118 |  | 1 | tmc_reset_config | 0100039a move.l #$6302f118, $2200088.l |
| 646c5632 |  | 2 | boot_check_label disk_label_check | 0100edd8 cmpi.l #$646c5632, (a0)<br>0101022c cmpi.l #$646c5632, (a1) |
| 646c5633 |  | 2 | boot_check_label disk_label_check | 0100edea cmpi.l #$646c5633, (a0)<br>0101023e cmpi.l #$646c5633, (a1) |
| 6fffffff |  | 3 | enet_write exc_dispatch post_enet_test | 01001aa0 andi.l #$6fffffff, d0<br>01004cde andi.l #$6fffffff, d0<br>010092ee andi.l #$6fffffff, d0 |
| 70000000 |  | 1 | mem_bmap_size_dram | 0100099c move.l #$70000000, $20c001c.l |
| 77777777 |  | 1 | fpu_test_regs | 01005d74 move.l #$77777777, d1 |
| 7fffffff |  | 1 | exc_dispatch | 01001a16 andi.l #$7fffffff, $200d000.l |
| 80000000 |  | 10 | enet_write exc_dispatch mem_bmap_size_dram_4 mem_config_test_nt mem_config_test_t mem_parity_probe_nt mem_parity_probe_n | 01000062 move.l #$80000000, $20c000c.l<br>01000af8 move.l #$80000000, $20c001c.l<br>01001c78 andi.l #$80000000, d0 ... |
| 80008000 |  | 2 | mem_pattern_test_nt mem_pattern_test_t | 01003148 move.l #$80008000, -(a7)<br>01003462 move.l #$80008000, -(a7) |
| 81a3c5e7 |  | 2 | mem_burst_test_nt | 01003d62 move.l #$81a3c5e7, (a0)+<br>01003da2 cmpi.l #$81a3c5e7, (a0)+ |
| 88888888 |  | 1 | fpu_test_regs | 01005d6c move.l #$88888888, d1 |
| 89abcdef |  | 4 | mem_bank_size_nt mem_bank_size_t mem_burst_test_nt | 01002df0 cmpi.l #$89abcdef, d0<br>010035dc cmpi.l #$89abcdef, d0<br>01003d56 move.l #$89abcdef, (a0)+ ... |
| 90000000 |  | 5 | enet_init enet_write exc_dispatch mem_bmap_size_dram_5 post_enet_test | 01000bc2 move.l #$90000000, $20c001c.l<br>01001a8e ori.l #$90000000, d0<br>01004ccc ori.l #$90000000, d0 ... |
| 99999999 |  | 1 | fpu_test_regs | 01005d64 move.l #$99999999, d1 |
| 9fffffff |  | 1 | od_cmd_dispatch | 0100f41a andi.l #$9fffffff, $21c(a3) |
| a0000000 |  | 1 | mem_bmap_size_dram_4 | 01000b08 move.l #$a0000000, $20c001c.l |
| a5000000 |  | 1 | nbus_probe_display_board | 0100ae94 cmpi.l #$a5000000, d0 |
| aaa0aaa0 |  | 2 | vid_vram_test | 01003b54 move.l #$aaa0aaa0, (a2)+<br>01003b68 move.l #$aaa0aaa0, d3 |
| aaaaaaaa |  | 10 | mem_bank_absent_t mem_dram_probe mem_report_error_nt mem_report_error_t ncc_cache_data_test vid_vram_probe | 01002d2a move.l #$aaaaaaaa, (a3)+<br>01002d3a cmpi.l #$aaaaaaaa, -$4(a6)<br>010033c2 move.l #$aaaaaaaa, (a3)+ ... |
| abcdef01 |  | 2 | mem_bank_size_nt mem_bank_size_t | 01002e04 cmpi.l #$abcdef01, d0<br>010035f0 cmpi.l #$abcdef01, d0 |
| b0000000 |  | 2 | mem_bmap_size_dram_4 mem_bmap_size_dram_6 | 01000aa8 cmpi.l #$b0000000, d3<br>01000c1c move.l #$b0000000, $20c001c.l |
| bfffffff |  | 1 | mem_config_test_nt | 0100311c andi.l #$bfffffff, d0 |
| c0000000 |  | 4 | nbus_probe_display_board reset_color_station_setup vid_draw_panel | 0100027a move.l #$c0000000, $20c000c.l<br>01009c36 andi.l #$c0000000, d1<br>0100ae5a andi.l #$c0000000, d0 ... |
| c7000000 |  | 1 | reset_bmap_cacr_setup | 0100004c move.l #$c7000000, $20c0004.l |
| d32b6d5b |  | 1 | post_cache_tag_test | 0100603c move.l #$d32b6d5b, d1 |
| db6db6db |  | 4 | mem_dram_probe mem_pattern_test_nt mem_pattern_test_t ncc_cache_data_test | 0100315a move.l #$db6db6db, d3<br>01003474 move.l #$db6db6db, d3<br>01003e4a move.l #$db6db6db, d1 ... |
| dfffffff |  | 2 | od_cmd_start | 0100f604 andi.l #$dfffffff, $21c(a3)<br>0100f656 andi.l #$dfffffff, $21c(a3) |
| e1000000 |  | 1 | reset_bmap_finish | 0100006c move.l #$e1000000, $20c0038.l |
| ef000000 |  | 2 | kms_console_init kms_read_key | 010098cc move.l #$ef000000, -(a7)<br>0100a35c move.l #$ef000000, -(a7) |
| efefffff |  | 1 | od_complete | 0100f8f6 andi.l #$efefffff, $21c(a2) |
| efffffff |  | 2 | boot_case_no_media bootp_request | 010065c4 andi.l #$efffffff, $3ae(a4)<br>01007174 andi.l #$efffffff, $3ae(a0) |
| f0000000 | NextBus slot space | 15 | nbus_op_block_store nbus_op_ldmem_imm nbus_op_ldmem_reg nbus_op_stmem_imm nbus_op_stmem_reg nbus_probe_display_board res | 0100007c andi.l #$f0000000, d0<br>01003c08 andi.l #$f0000000, d0<br>0100af4e cmpi.l #$f0000000, d0 ... |
| f0ffffb8 | NextBus slot space | 2 | nbus_probe_display_board vid_init_display | 0100aef0 ori.l #$f0ffffb8, d1<br>0100b0a6 ori.l #$f0ffffb8, d1 |
| f0ffffc0 | NextBus slot space | 2 | nbus_probe_display_board vid_init_display | 0100af02 ori.l #$f0ffffc0, d1<br>0100b0b8 ori.l #$f0ffffc0, d1 |
| f0ffffc8 | NextBus slot space | 2 | nbus_probe_display_board vid_init_display | 0100af1c ori.l #$f0ffffc8, d1<br>0100b0d2 ori.l #$f0ffffc8, d1 |
| f0ffffd0 | NextBus slot space | 2 | nbus_probe_display_board vid_init_display | 0100af32 ori.l #$f0ffffd0, d0<br>0100b0e8 ori.l #$f0ffffd0, d0 |
| f0ffffd8 | NextBus slot space | 2 | nbus_probe_display_board vid_init_display | 0100aebc ori.l #$f0ffffd8, d2<br>0100b094 ori.l #$f0ffffd8, d1 |
| f0ffffe0 | NextBus slot space | 1 | nbus_probe_display_board | 0100ae72 ori.l #$f0ffffe0, d2 |
| f0fffff0 | NextBus slot space | 2 | nbus_probe_display_board vid_console_init | 0100ad6c move.l #$f0fffff0, -(a7)<br>0100ae3e ori.l #$f0fffff0, d2 |
| f8000000 | NextBus slot space | 3 | mem_bmap_size_dram_4 | 01000b30 cmpi.l #$f8000000, d3<br>01000b3e cmpi.l #$f8000000, d3<br>01000b4c cmpi.l #$f8000000, d3 |
| fc000000 | NextBus slot space | 2 | mem_print_bad_socket_t mem_report_error_t | 010032f6 addi.l #$fc000000, d1<br>010033fa addi.l #$fc000000, d1 |
| feedface | NextBus slot space | 1 | boot_load_image_header | 01006950 cmpi.l #$feedface, (a0) |
| fefdffff | NextBus slot space | 1 | od_cmd_finish | 0100f702 andi.l #$fefdffff, $21c(a3) |
| ff000000 | NextBus slot space | 22 | nbus_op_block_store nbus_op_ldmem_imm nbus_op_ldmem_reg nbus_op_stmem_imm nbus_op_stmem_reg nbus_probe_display_board nbu | 0100ac20 andi.l #$ff000000, d1<br>0100ac28 andi.l #$ff000000, d0<br>0100ac34 andi.l #$ff000000, d0 ... |
| ff7fffff | NextBus slot space | 2 | od_cmd_after_eject od_cmd_resume | 0100f696 andi.l #$ff7fffff, $21c(a3)<br>0100f71c andi.l #$ff7fffff, $21c(a3) |
| ffdfffff | NextBus slot space | 1 | od_complete | 0100f812 andi.l #$ffdfffff, $21c(a2) |
| ffefffff | NextBus slot space | 1 | od_complete | 0100f8da andi.l #$ffefffff, $21c(a2) |
| fff00000 | NextBus slot space | 1 | vid_draw_panel | 01009bca andi.l #$fff00000, d0 |
| fff0fff0 | NextBus slot space | 1 | vid_vram_test | 01003ab0 move.l #$fff0fff0, d5 |
| fff7ffff | NextBus slot space | 1 | od_start_io | 0100f398 andi.l #$fff7ffff, $21c(a0) |
| fffebff7 | NextBus slot space | 1 | fc_start | 01010ecc andi.l #$fffebff7, d0 |
| fffeffff | NextBus slot space | 1 | od_complete | 0100f826 andi.l #$fffeffff, $21c(a2) |
| ffff0000 | NextBus slot space | 2 | dma_init fpu_test_regs_pattern | 01005da4 andi.l #$ffff0000, d6<br>0100e91c addi.l #$ffff0000, d1 |
| ffffa000 | NextBus slot space | 1 | enet_init | 01008ed0 addi.l #$ffffa000, d2 |
| ffffe000 | NextBus slot space | 3 | enet_init mem_config_test_t | 010037b4 addi.l #$ffffe000, d7<br>0100392c addi.l #$ffffe000, d7<br>01008ee4 addi.l #$ffffe000, d2 |
| ffffefd0 | NextBus slot space | 1 | mon_init | 010017a6 addi.l #$ffffefd0, d2 |
| fffffb72 | NextBus slot space | 1 | mon_init | 0100175c addi.l #$fffffb72, d2 |
| fffffbff | NextBus slot space | 3 | mem_nmi_parity_vec_t mem_parity_probe_t_done tmc_parity_init_range | 01003f10 andi.l #$fffffbff, $2200010.l<br>01003fb2 andi.l #$fffffbff, d0<br>0100408a andi.l #$fffffbff, $2200010.l |
| fffffc00 | NextBus slot space | 2 | boot_exec_blk0 mon_init | 01001774 addi.l #$fffffc00, d2<br>0100ee82 addi.l #$fffffc00, d2 |
| fffffcc0 | NextBus slot space | 2 | vid_init_color_1120x832 vid_init_mono_1120x832 | 0100bb50 addi.l #$fffffcc0, d0<br>0100c10a addi.l #$fffffcc0, d1 |
| fffffeff | NextBus slot space | 1 | kms_translate_key | 0100a464 addi.l #$fffffeff, d0 |
| fffffffc | NextBus slot space | 1 | tmc_reset_config | 010003b4 andi.l #$fffffffc, d0 |
| fffffffe | NextBus slot space | 4 | crc32_calc_asm led_blink_loop led_off vid_vram_probe_pass3 | 01003d3c andi.l #$fffffffe, d1<br>010040da andi.l #$fffffffe, $200d000(a0, invalid.w)<br>0100410c andi.l #$fffffffe, $200d000.l ... |
| ffffffff | NextBus slot space | 1 | mem_bmap_addr_scan | 01000880 eori.l #$ffffffff, d2 |
