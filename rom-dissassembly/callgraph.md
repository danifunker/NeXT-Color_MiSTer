# Call graph

Direct bsr/jsr edges between routines (computed jumps and function pointers are not edges; see the `ptr` column of functions.md).

## Call tree from reset_entry

Depth-first, each routine expanded once (later occurrences are marked `(see above)`); jumps between routines (`bra`/`jmp`) are followed as well as calls.

- `0100001e` reset_entry
  - `01000042` reset_bmap_cacr_setup
    - `01000062` reset_bmap_finish
      - `01000092` reset_probe_ncc
        - `010000b0` reset_machine_dispatch
          - `0100017e` reset_cube030_setup
            - `010003cc` reset_int_mask_crc
              - `010003f0` reset_crc_stage2
                - `0100041e` reset_pick_stack
                  - `010004c2` reset_probe_vram_stack
                    - `010004d0` reset_mg_in_vram
                      - `01000556` reset_install_vectors
                        - `010005ae` exc_common_entry
                          - `010018d4` exc_dispatch
                            - `01000686` mg_get_ptr
                            - `01000696` cpu_set_vbr
                            - `010006ac` mon_call_on_stack
                              - `010006f4` mon_return_trap
                            - `01000ec6` mon_init
                              - `0100067a` mg_set_ptr
                              - `01000690` cpu_get_vbr
                              - `01000696` cpu_set_vbr (see above)
                              - `01000c9c` mg_init_machine
                              - `010022d6` mem_build_regions
                              - `01002462` mon_system_test_failed
                              - `01002e4c` mem_config_test_nt
                              - `01003224` mem_test_all_nt
                              - `0100361a` mem_config_test_t
                              - `010039bc` mem_test_all_t
                              - `01005a46` post_run_all
                              - `01005ea0` ncc_cache_data_test
                              - `01006018` post_cache_tag_test
                              - `01007480` con_putc_crlf
                              - `01007772` printf
                              - `0100785c` printf_log
                              - `01007e16` mem_cmp
                              - `01007ffc` mem_zero
                              - `01008108` str_ncmp
                              - `0100866c` nvram_write
                              - `0100a1a8` kms_power_key_check
                              - `0100c1b4` adb_init
                            - `0100187c` fd_pick_default_boot
                              - `010080a2` str_ncpy
                            - `01001d5e` exc_nofault_bogus
                              - `01001d72` exc_nofault_resume
                              - `01007772` printf
                            - `01001d72` exc_nofault_resume
                              - `01001dd8` mon_command_loop
                              - `010022cc` mon_cmd_continue
                            - `01001dd8` mon_command_loop
                              - `010022ba` mon_cmd_huh
                              - `010024f6` mon_password_check
                              - `01007772` printf
                              - `01007b5c` con_gets
                              - `01007ca8` str_skip_space
                            - `01004440` vid_draw_image
                              - `01000686` mg_get_ptr (see above)
                              - `01004512` vid_draw_rle_image
                              - `0100457a` vid_draw_raw_image
                              - `0100471c` vid_draw_tbl_rle_image
                              - `0100b2b2` vid_lock
                              - `0100b2f4` vid_unlock
                            - `0100610c` boot_cmd
                              - `01002426` mon_print_warning
                              - `01006300` boot_cmd_paren_check
                              - `0100662a` boot_case_error
                              - `01007772` printf
                              - `01007ca8` str_skip_space
                              - `01007ffc` mem_zero
                              - `010080a2` str_ncpy
                              - `010080f8` str_cpy
                              - `01008108` str_ncmp
                            - `01007772` printf
                              - `01007876` vprintf
                            - `01007e16` mem_cmp
                            - `010080c2` str_cat
                            - `010080d8` str_cmp
                            - `010080f8` str_cpy
                            - `01008108` str_ncmp
                            - `010083d4` rtc_int_clear
                              - `010082ca` rtc_power_int_handler
                              - `010086e8` rtc_write_reg
                              - `010087cc` rtc_read_reg
                            - `0100861c` nvram_read
                              - `0100743c` net_ip_checksum
                              - `010087cc` rtc_read_reg
                            - `01008964` scc_init
                              - `01000686` mg_get_ptr (see above)
                              - `01008936` delay_us
                            - `01009fde` mon_clear_nmi
                              - `01000686` mg_get_ptr (see above)
                            - `0100a1a8` kms_power_key_check
                              - `01000686` mg_get_ptr (see above)
                              - `01007772` printf (see above)
                              - `010082ca` rtc_power_int_handler
                              - `01008380` rtc_power_down
                              - `0100a3f2` kms_translate_key
                              - `0100a63c` vid_putc
                              - `0100d032` adb_kbd_getevent
                              - `0101027e` od_eject
                              - `01010700` fd_eject
                            - `0100a5fa` vid_clear_screen
                              - `01000686` mg_get_ptr (see above)
                              - `0100b2b2` vid_lock
                              - `0100b2f4` vid_unlock
                            - `0100b012` vid_post_init
                              - `0100abdc` nbus_rom_read_long
                              - `0100b38c` nbus_run_boardcode
                              - `0100b802` vid_enable_display
                            - `0100b04e` vid_init_display
                              - `01007ffc` mem_zero
                              - `0100abdc` nbus_rom_read_long
                              - `0100b85c` vid_driver_init
                            - `0101030e` od_reset
                              - `01000686` mg_get_ptr (see above)
                              - `01008936` delay_us
                        - `0100067a` mg_set_ptr
                        - `01000e2e` mon_show_test_panel
                          - `01000c9c` mg_init_machine
                            - `01000dbc` mg_init_type8_9
                              - `01007ffc` mem_zero
                              - `010080f8` str_cpy (see above)
                              - `0100861c` nvram_read (see above)
                            - `01007ffc` mem_zero
                          - `01004440` vid_draw_image (see above)
                          - `010077a4` vid_printf_at
                            - `01000686` mg_get_ptr (see above)
                            - `010043fc` vid_draw_image_onscreen
                              - `01000686` mg_get_ptr (see above)
                              - `01004440` vid_draw_image (see above)
                            - `01007876` vprintf
                              - `0100766e` print_char_sink
                              - `01007b24` vprintf_case_pct
                        - `01005cd2` nvram_check_or_rtc_ramtest
                          - `010040e8` led_blink_halt
                            - `010040ec` led_blink_loop
                          - `0100861c` nvram_read (see above)
                          - `010086e8` rtc_write_reg
                            - `01000686` mg_get_ptr (see above)
                            - `0100822c` delay_1us
                              - `01008936` delay_us
                          - `010087cc` rtc_read_reg
                            - `010087e8` rtc_read_reg_raw
                              - `01000686` mg_get_ptr (see above)
                              - `0100822c` delay_1us (see above)
                        - `0100ac8a` vid_console_init
                          - `01000c9c` mg_init_machine (see above)
                          - `010023f6` mon_probe_read_long
                          - `01008936` delay_us
                            - `0100889c` timer_read_us
                              - `01000686` mg_get_ptr (see above)
                            - `01008924` timer_elapsed_us
                              - `0100889c` timer_read_us (see above)
                          - `0100a5fa` vid_clear_screen (see above)
                          - `0100ae26` nbus_probe_display_board
                            - `010023f6` mon_probe_read_long (see above)
                            - `01007ffc` mem_zero (see above)
                            - `0100a5fa` vid_clear_screen (see above)
                            - `0100abdc` nbus_rom_read_long
                              - `01000686` mg_get_ptr (see above)
                            - `0100b012` vid_post_init (see above)
                            - `0100b04e` vid_init_display (see above)
                            - `0100b38c` nbus_run_boardcode
                              - `01000686` mg_get_ptr (see above)
                              - `0100b3b0` nbus_op_next
                              - `0100b7b0` nbus_op_return
                          - `0100b04e` vid_init_display (see above)
                          - `0100b7c0` vid_find_driver
                          - `0100b802` vid_enable_display
                            - `0100866c` nvram_write
                              - `0100743c` net_ip_checksum
                              - `01007ec8` mem_move
                              - `010080d8` str_cmp (see above)
                              - `0100861c` nvram_read (see above)
                              - `010086e8` rtc_write_reg (see above)
                          - `0100b85c` vid_driver_init
                            - `01007ffc` mem_zero (see above)
                          - `0100b8a6` vid_driver_setup_dac
                          - `0100c626` adb_probe_kbd_alt_video
                            - `01008936` delay_us (see above)
                            - `0100c458` adb_reset_bus
                            - `0100c4fa` adb_talk
                              - `0100c482` adb_send_cmd
                            - `0100c6a4` tmc_alt_timing_mono
                      - `0100067a` mg_set_ptr (see above)
                    - `01003ca4` vid_vram_probe
                      - `01003c84` vid_vram_probe_fill
                      - `01003ce2` vid_vram_probe_pass2
                        - `01003c84` vid_vram_probe_fill (see above)
                        - `01003cfc` vid_vram_probe_pass3
                          - `010040ec` led_blink_loop (see above)
                  - `01000508` reset_probe_dram_stack
                    - `01000514` reset_mg_in_dram
                      - `01000556` reset_install_vectors (see above)
                      - `0100067a` mg_set_ptr (see above)
                      - `01003a9c` vid_vram_test
                        - `01000686` mg_get_ptr (see above)
                        - `01000c9c` mg_init_machine (see above)
                        - `010025d4` mon_led_blink
                          - `01000686` mg_get_ptr (see above)
                        - `01007772` printf (see above)
                        - `0100785c` printf_log
                          - `01007876` vprintf (see above)
                        - `01007ffc` mem_zero (see above)
                    - `01003dfc` mem_dram_probe
                      - `01003dcc` mem_dram_probe_fill
                      - `01003e5c` mem_dram_probe_pass2
                        - `01003dcc` mem_dram_probe_fill (see above)
                        - `01003e76` mem_dram_probe_pass3
                          - `01003e9e` mem_dram_probe_next
                            - `01003dfc` mem_dram_probe (see above)
                            - `010040ec` led_blink_loop (see above)
                        - `01003e9e` mem_dram_probe_next (see above)
                      - `01003e9e` mem_dram_probe_next (see above)
                  - `010040ec` led_blink_loop (see above)
                - `010040ec` led_blink_loop (see above)
                - `0100418e` crc32_calc_asm
              - `0100418e` crc32_calc_asm (see above)
          - `010001f2` reset_nonturbo040_setup
            - `01000200` reset_nonturbo040_bmap
              - `010003cc` reset_int_mask_crc (see above)
          - `0100027a` reset_color_station_setup
            - `010003cc` reset_int_mask_crc (see above)
          - `010002a6` reset_turbo_setup
            - `010002b4` tmc_reset_config
              - `010003cc` reset_int_mask_crc (see above)
            - `01000c68` mmu_transparent_setup
          - `010040ec` led_blink_loop (see above)
    - `01000992` mem_bmap_size_dram
      - `010007f4` mem_bmap_addr_scan
      - `010009de` mem_bmap_size_dram_2
        - `010007f4` mem_bmap_addr_scan (see above)
        - `01000a1a` mem_bmap_size_dram_3
          - `010007f4` mem_bmap_addr_scan (see above)
          - `01000a6e` mem_bmap_size_dram_4
            - `010007f4` mem_bmap_addr_scan (see above)
            - `01000bae` mem_bmap_size_dram_5
              - `010007f4` mem_bmap_addr_scan (see above)
              - `01000c04` mem_bmap_size_dram_6
  - `01000c68` mmu_transparent_setup (see above)

## Edges

| routine | calls | called from |
|---|---|---|
| `0100001e` reset_entry |  | post_ret_ext_scsi |
| `01000042` reset_bmap_cacr_setup |  |  |
| `01000062` reset_bmap_finish |  |  |
| `01000092` reset_probe_ncc |  |  |
| `010000b0` reset_machine_dispatch |  |  |
| `0100017e` reset_cube030_setup |  |  |
| `010001f2` reset_nonturbo040_setup |  |  |
| `01000200` reset_nonturbo040_bmap |  |  |
| `0100027a` reset_color_station_setup |  |  |
| `010002a6` reset_turbo_setup |  |  |
| `010002b4` tmc_reset_config |  |  |
| `010003cc` reset_int_mask_crc |  |  |
| `010003f0` reset_crc_stage2 |  |  |
| `0100041e` reset_pick_stack |  |  |
| `010004c2` reset_probe_vram_stack |  |  |
| `010004d0` reset_mg_in_vram | mg_set_ptr |  |
| `01000508` reset_probe_dram_stack |  |  |
| `01000514` reset_mg_in_dram | mg_set_ptr vid_vram_test |  |
| `01000556` reset_install_vectors | mg_set_ptr mon_show_test_panel nvram_check_or_rtc_ramtest vid_console_init |  |
| `010005ae` exc_common_entry | exc_dispatch |  |
| `01000654` mon_reenter_704 |  |  |
| `01000660` mon_reenter_704_frame |  |  |
| `0100067a` mg_set_ptr |  | reset_mg_in_vram reset_mg_in_dram reset_install_vectors mon_init |
| `01000686` mg_get_ptr |  | exc_dispatch mon_probe_read_byte mon_probe_write_byte mon_print_warning mon_system_test_failed mon_password_check mon_led_blink mon_examine_memory mem_print_bad_socket_t mem_report_error_t mem_bank_size_t vid_vram_test vid_span_2bpp vid_span_8bpp vid_span_16bpp vid_span_32bpp vid_draw_image_onscreen vid_draw_image vid_draw_rle_image vid_draw_raw_image vid_draw_tbl_rle_image snd_out_clear_underrun_any post_snd_in_dma_reset post_scc_test post_enet_test post_ecc_test post_timer_test post_snd_out_dma_stop post_snd_out_test post_run_all boot_l3_isr boot_anim_step boot_anim_set vid_draw_char print_char_sink vid_printf_at parse_number mem_alloc con_getc con_try_getc con_putc rtc_power_int_handler rtc_write_reg rtc_read_reg_raw timer_read_us scc_init scc_poll_flow_control scc_getc scc_try_getc scc_putc enet_init enet_read enet_write enet_close enet_rx_int enet_rx_dma_start kms_console_init vid_text_reset vid_draw_panel vid_restore_panel mon_clear_nmi kms_poll_km_event kms_event_pending con_flow_control_poll vid_console_putc kms_power_key_check kms_read_key vid_console_getc kms_translate_key kms_send_cmd_0100a520 vid_clear_text_area vid_clear_screen vid_putc vid_cursor_toggle vid_clear_to_eol mon_alert_printf mon_alert_close nbus_rom_read_long vid_lock vid_unlock nbus_map_addr nbus_run_boardcode adb_init adb_intr adb_kbd_poll adb_kbd_raise_nmi adb_set_config adb_kbd_init adb_kbd_handler kbd_a_up_capslock kbd_a_down_capslock adb_kbd_getevent_unused kbd_b_up_capslock kbd_b_down_capslock adb_kbd_getevent kbd_c_up_capslock kbd_c_down_capslock kbd_c_event_done kbd_d_up_capslock kbd_d_down_capslock adb_mouse_init adb_kbd_present dma_init dma_start od_ctrl_init od_volume_init od_strategy od_cmd_dispatch od_issue od_drive_cmd od_cmd od_read_label od_eject od_reset od_query_status fd_eject fc_intr fc_send_cmd fd_wait_intr |
| `01000690` cpu_get_vbr |  | mon_init mem_config_test_nt mem_config_test_t post_timer_test post_snd_out_test boot_cmd_paren_check enet_init |
| `01000696` cpu_set_vbr |  | mon_init exc_dispatch |
| `010006a0` cpu_get_ipl |  | enet_init |
| `010006ac` mon_call_on_stack |  | exc_dispatch mon_cmd_boot |
| `010006f4` mon_return_trap |  |  |
| `010006fa` mon_return_trap_frame |  |  |
| `0100070e` cpu_moves_read_long |  |  |
| `01000728` cpu_fc_read_word |  |  |
| `01000742` cpu_moves_read_byte |  |  |
| `0100075e` cpu_moves_write_long |  |  |
| `0100077c` cpu_moves_write_word |  |  |
| `0100079a` cpu_moves_write_byte |  |  |
| `010007c6` bf_insert |  | vid_draw_char |
| `010007e2` bf_extract |  | vid_draw_char |
| `010007f4` mem_bmap_addr_scan |  |  |
| `010008e2` mon_enter_from_os |  |  |
| `01000930` mon_enter_from_os_2 |  |  |
| `01000946` mon_enter_from_os_restore |  |  |
| `01000992` mem_bmap_size_dram |  |  |
| `010009de` mem_bmap_size_dram_2 |  |  |
| `01000a1a` mem_bmap_size_dram_3 |  |  |
| `01000a6e` mem_bmap_size_dram_4 |  |  |
| `01000bae` mem_bmap_size_dram_5 |  |  |
| `01000c04` mem_bmap_size_dram_6 |  |  |
| `01000c68` mmu_transparent_setup |  |  |
| `01000c9c` mg_init_machine |  | mon_show_test_panel mon_init vid_vram_test vid_console_init |
| `01000d64` mg_init_type1 |  |  |
| `01000d6c` mg_init_type0_2 |  |  |
| `01000d7a` mg_init_type3 |  |  |
| `01000d86` mg_init_type6_7 |  |  |
| `01000d96` mg_init_type4_5 |  |  |
| `01000dac` mg_init_typeA_B |  |  |
| `01000dbc` mg_init_type8_9 | mem_zero str_cpy nvram_read |  |
| `01000e2e` mon_show_test_panel | mg_init_machine vid_draw_image vid_printf_at | reset_install_vectors |
| `01000ec6` mon_init | mg_set_ptr cpu_get_vbr cpu_set_vbr mg_init_machine mem_build_regions mon_system_test_failed mem_config_test_nt mem_test_all_nt mem_config_test_t mem_test_all_t post_run_all ncc_cache_data_test post_cache_tag_test con_putc_crlf printf printf_log mem_cmp mem_zero str_ncmp nvram_write kms_power_key_check adb_init | exc_dispatch |
| `0100187c` fd_pick_default_boot | str_ncpy | exc_dispatch |
| `010018d4` exc_dispatch | mg_get_ptr cpu_set_vbr mon_call_on_stack mon_init fd_pick_default_boot vid_draw_image boot_cmd printf mem_cmp str_cmp str_cpy str_ncmp rtc_int_clear nvram_read scc_init mon_clear_nmi kms_power_key_check vid_clear_screen vid_post_init vid_init_display od_reset | exc_common_entry |
| `01001d50` exc_nofault_skip6word |  |  |
| `01001d56` exc_nofault_skip_fmt7 |  |  |
| `01001d5e` exc_nofault_bogus | printf |  |
| `01001d72` exc_nofault_resume |  |  |
| `01001dd8` mon_command_loop | mon_password_check printf con_gets str_skip_space |  |
| `01001ef8` mon_cmd_password | con_gets mem_zero str_ncmp nvram_read nvram_write |  |
| `01001fd8` mon_cmd_boot | mon_call_on_stack |  |
| `01001ffe` mon_cmd_aregs |  |  |
| `01002012` mon_cmd_d |  |  |
| `01002026` mon_cmd_r |  |  |
| `0100203a` mon_cmd_m | printf |  |
| `0100213a` mon_cmd_p | mon_param_edit_table nvram_write |  |
| `01002168` mon_cmd_s |  |  |
| `0100218a` mon_cmd_regs_common | mon_param_edit_table |  |
| `0100219a` mon_cmd_e | mon_examine_memory od_eject fd_eject |  |
| `0100223a` mon_cmd_fcode | printf parse_number |  |
| `01002278` mon_cmd_radix | printf parse_number |  |
| `010022b0` mon_cmd_help | mon_print_help |  |
| `010022ba` mon_cmd_huh | printf |  |
| `010022cc` mon_cmd_continue |  |  |
| `010022d6` mem_build_regions |  | mon_init |
| `0100237a` mon_probe_read_byte | mg_get_ptr | enet_reg_read enet_reg_poll |
| `010023aa` mon_probe_read_byte_fail |  |  |
| `010023b8` mon_probe_write_byte | mg_get_ptr | enet_reg_write |
| `010023f6` mon_probe_read_long |  | vid_console_init nbus_probe_display_board |
| `01002426` mon_print_warning | mg_get_ptr printf | boot_cmd boot_case_error |
| `01002462` mon_system_test_failed | mg_get_ptr vid_draw_image vid_printf_at kms_power_key_check | mon_init |
| `010024f6` mon_password_check | mg_get_ptr printf con_gets mem_zero | mon_command_loop mon_param_edit_table mon_param_sysreg mon_param_bootcmd mon_param_pot_bit mon_param_parity mon_param_reset_bit |
| `010025c0` mon_usage_error | printf | mon_examine_memory |
| `010025d4` mon_led_blink | mg_get_ptr | vid_vram_test |
| `01002630` mon_param_edit_table | mon_password_check printf con_gets str_skip_space parse_number str_cmp | mon_cmd_p mon_cmd_regs_common |
| `0100274e` mon_param_sysreg | mon_password_check printf parse_number |  |
| `010027e2` mon_param_bootcmd | mon_password_check printf str_cpy str_len |  |
| `0100287c` mon_param_pot_bit | mon_password_check printf |  |
| `0100291a` mon_param_parity | mon_password_check printf |  |
| `010029aa` mon_param_reset_bit | mon_password_check printf od_query_status |  |
| `01002a68` mon_examine_memory | mg_get_ptr mon_usage_error con_gets str_skip_space parse_number | mon_cmd_e |
| `01002c38` mon_print_help | printf | mon_cmd_help |
| `01002c54` mem_print_bad_sockets_nt | printf_log | mem_report_error_nt |
| `01002cd2` mem_report_error_nt | mem_print_bad_sockets_nt | mem_config_test_nt mem_test_all_nt |
| `01002d92` mem_bank_present_nt |  | mem_config_test_nt |
| `01002dbe` mem_bank_size_nt |  | mem_config_test_nt |
| `01002e24` mem_write_read_long |  | mem_config_test_nt |
| `01002e4c` mem_config_test_nt | cpu_get_vbr mem_report_error_nt mem_bank_present_nt mem_bank_size_nt mem_write_read_long mem_burst_test_nt cache_get_cacr_push printf_log mem_zero | mon_init |
| `0100313c` mem_pattern_test_nt | cache_inval_set_cacr cache_get_cacr_push | mem_test_all_nt |
| `01003224` mem_test_all_nt | mem_report_error_nt mem_pattern_test_nt cache_inval_set_cacr led_on led_off | mon_init |
| `010032e0` mem_print_bad_socket_t | mg_get_ptr | mem_report_error_t |
| `0100336a` mem_report_error_t | mg_get_ptr mem_print_bad_socket_t printf_log | mem_config_test_t mem_test_all_t |
| `01003456` mem_pattern_test_t | cache_inval_set_cacr cache_get_cacr_push | mem_test_all_t |
| `0100353e` mem_bank_absent_t |  | mem_config_test_t |
| `01003598` mem_bank_size_t | mg_get_ptr | mem_config_test_t |
| `0100361a` mem_config_test_t | cpu_get_vbr mem_report_error_t mem_bank_absent_t mem_bank_size_t mem_parity_probe_nt mem_parity_probe_t tmc_parity_init_range cache_get_cacr_push printf_log mem_zero | mon_init |
| `010039bc` mem_test_all_t | mem_report_error_t mem_pattern_test_t cache_inval_set_cacr | mon_init |
| `01003a9c` vid_vram_test | mg_get_ptr mg_init_machine mon_led_blink printf printf_log mem_zero | reset_mg_in_dram |
| `01003c84` vid_vram_probe_fill |  |  |
| `01003ca4` vid_vram_probe |  |  |
| `01003ce2` vid_vram_probe_pass2 |  |  |
| `01003cfc` vid_vram_probe_pass3 |  |  |
| `01003d4a` mem_burst_test_nt |  | mem_config_test_nt |
| `01003dbe` mem_berr_parity_nt |  |  |
| `01003dcc` mem_dram_probe_fill |  |  |
| `01003dfc` mem_dram_probe |  |  |
| `01003e5c` mem_dram_probe_pass2 |  |  |
| `01003e76` mem_dram_probe_pass3 |  |  |
| `01003e9e` mem_dram_probe_next |  |  |
| `01003eb2` mem_parity_probe_nt |  | mem_config_test_t |
| `01003ece` mem_parity_probe_nt_done |  |  |
| `01003ee8` mem_parity_probe_t |  | mem_config_test_t |
| `01003f04` mem_parity_probe_t_done |  |  |
| `01003f1e` mem_parity_probe_body |  |  |
| `01003f94` mem_berr_parity_vec_nt |  |  |
| `01003fa2` mem_nmi_parity_vec_t |  |  |
| `01003fc2` mem_vectors_nt |  |  |
| `01004072` tmc_parity_init_range |  | mem_config_test_t |
| `010040a8` cache_push_data |  |  |
| `010040ac` cache_inval_set_cacr |  | mem_pattern_test_nt mem_test_all_nt mem_pattern_test_t mem_test_all_t |
| `010040bc` cache_get_cacr_push |  | mem_config_test_nt mem_pattern_test_nt mem_pattern_test_t mem_config_test_t |
| `010040c4` led_on |  | mem_test_all_nt |
| `010040d6` led_off |  | mem_test_all_nt |
| `010040e8` led_blink_halt |  | nvram_check_or_rtc_ramtest |
| `010040ec` led_blink_loop |  |  |
| `01004142` snd_out_clear_underrun |  | snd_out_clear_underrun_any |
| `01004156` snd_out_clear_underrun_wait |  | snd_out_clear_underrun_any |
| `0100418e` crc32_calc_asm |  |  |
| `010041e2` crc32_calc |  |  |
| `010041fe` crc32_calc_ret |  |  |
| `01004208` vid_span_2bpp | mg_get_ptr |  |
| `01004274` vid_span_8bpp | mg_get_ptr |  |
| `010042f4` vid_span_16bpp | mg_get_ptr |  |
| `01004378` vid_span_32bpp | mg_get_ptr |  |
| `010043fc` vid_draw_image_onscreen | mg_get_ptr vid_draw_image | vid_printf_at |
| `01004440` vid_draw_image | mg_get_ptr vid_draw_rle_image vid_draw_raw_image vid_draw_tbl_rle_image vid_lock vid_unlock | mon_show_test_panel exc_dispatch mon_system_test_failed vid_draw_image_onscreen boot_cmd_paren_check boot_anim_step |
| `01004512` vid_draw_rle_image | mg_get_ptr | vid_draw_image |
| `0100457a` vid_draw_raw_image | mg_get_ptr | vid_draw_image |
| `0100471c` vid_draw_tbl_rle_image | mg_get_ptr | vid_draw_image |
| `010047ac` post_delay_9us | delay_us | post_scc_test post_enet_test post_ecc_test |
| `010047be` snd_out_clear_underrun_any | mg_get_ptr snd_out_clear_underrun snd_out_clear_underrun_wait | post_snd_out_test |
| `010047e6` post_scsi_dma_isr | post_scsi_dma_intr |  |
| `0100480a` post_timer_isr | post_timer_ack |  |
| `0100481a` post_snd_out_isr | post_snd_out_dma_stop |  |
| `0100483e` post_fpu_test | fpu_test_regs fpu_test_formats fpu_test_arith | post_run_all |
| `01004872` post_snd_in_dma_reset | mg_get_ptr |  |
| `010048a6` post_scc_test | mg_get_ptr post_delay_9us | post_ret_fpu |
| `01004a16` post_scsi_dma_intr | printf_log | post_scsi_dma_isr |
| `01004a2a` post_scsi_test |  | post_ret_scc |
| `01004ada` post_ext_scsi_test | delay_us | post_ret_timer |
| `01004bf0` post_enet_test | mg_get_ptr post_delay_9us mem_alloc mem_cmp mem_move mem_zero delay_us enet_init enet_read enet_write enet_close | post_ret_scc |
| `01004f12` post_ecc_test | mg_get_ptr post_delay_9us mem_cmp | post_ret_enet |
| `010052d0` post_rtc_test | rtc_start_clock rtc_read_reg delay_us | post_ret_ecc |
| `01005338` post_timer_ack |  | post_timer_isr |
| `0100534e` post_timer_test | mg_get_ptr cpu_get_vbr delay_us | post_ret_rtc |
| `01005440` post_evcnt_test | delay_us | post_ret_timer |
| `0100553a` post_evcnt_measured | abs_l |  |
| `010055f2` post_snd_out_overrun_intr | printf_log |  |
| `01005606` kms_send_cmd | delay_us | post_snd_out_dma_stop post_snd_out_test |
| `01005634` post_snd_out_dma_stop | mg_get_ptr kms_send_cmd delay_us | post_snd_out_isr |
| `0100567e` kms_set_volume | delay_us kms_send_cmd_0100a520 | post_snd_out_test |
| `01005758` post_snd_out_test | mg_get_ptr cpu_get_vbr snd_out_clear_underrun_any kms_send_cmd kms_set_volume printf_log mem_zero delay_us |  |
| `01005a46` post_run_all | mg_get_ptr post_fpu_test printf kms_power_key_check | mon_init |
| `01005aa2` post_ret_fpu | post_scc_test printf kms_power_key_check |  |
| `01005ad2` post_ret_scc | post_scsi_test post_enet_test printf kms_power_key_check |  |
| `01005b26` post_ret_enet | post_ecc_test printf |  |
| `01005b5e` post_ret_ecc | post_rtc_test printf kms_power_key_check |  |
| `01005b8e` post_ret_rtc | post_timer_test printf kms_power_key_check |  |
| `01005bbe` post_ret_timer | post_ext_scsi_test post_evcnt_test printf kms_power_key_check |  |
| `01005c64` post_ret_ext_scsi | reset_entry printf con_try_getc delay_us |  |
| `01005cd2` nvram_check_or_rtc_ramtest | led_blink_halt nvram_read rtc_write_reg rtc_read_reg | reset_install_vectors |
| `01005d44` fpu_test_regs | fpu_test_regs_pattern | post_fpu_test |
| `01005d82` fpu_test_regs_pattern |  | fpu_test_regs |
| `01005dd2` fpu_test_formats |  | post_fpu_test |
| `01005e1c` fpu_test_arith |  | post_fpu_test |
| `01005ea0` ncc_cache_data_test |  | mon_init |
| `01006018` post_cache_tag_test |  | mon_init |
| `010060d6` post_cache_clear |  |  |
| `0100610c` boot_cmd | mon_print_warning printf str_skip_space mem_zero str_ncpy str_cpy str_ncmp | exc_dispatch |
| `01006300` boot_cmd_paren_check | cpu_get_vbr vid_draw_image boot_anim_set printf sprintf str_skip_space str_ncpy str_ncmp str_len |  |
| `01006560` boot_case_ok |  |  |
| `01006566` boot_case_flip_disk | boot_anim_set |  |
| `0100657a` boot_case_insert_disk | boot_anim_set |  |
| `0100658c` boot_case_no_media | str_cmp delay_us |  |
| `0100660c` boot_cmd_diag_check_tail |  |  |
| `01006612` boot_cmd_reload_default | str_cpy |  |
| `0100662a` boot_case_error | mon_print_warning boot_anim_set printf str_skip_space delay_us kms_power_key_check od_eject |  |
| `0100670a` boot_l3_isr | mg_get_ptr boot_anim_step | boot_l3_isr_entry |
| `010067e0` boot_l3_isr_tmc_tail | boot_anim_step |  |
| `0100680c` boot_anim_step | mg_get_ptr vid_draw_image vid_printf_at kms_power_key_check | boot_l3_isr boot_l3_isr_tmc_tail |
| `010068ba` boot_l3_isr_entry_link |  |  |
| `010068be` boot_l3_isr_entry | boot_l3_isr |  |
| `010068d2` boot_anim_set | mg_get_ptr | boot_cmd_paren_check boot_case_flip_disk boot_case_insert_disk boot_case_error |
| `01006914` boot_load_image_header | printf mem_move | tftp_load_kernel boot_exec_blk0 |
| `010069cc` enet_boot_open | mem_alloc mem_move |  |
| `01006a2e` enet_boot_close |  |  |
| `01006a44` tftp_load_kernel | boot_load_image_header bootp_request net_send_ip net_poll_recv printf sprintf mem_move str_cpy timer_read_us timer_read_ms |  |
| `01006e12` bootp_request | net_send_ip net_poll_recv printf con_gets mem_cmp mem_move mem_zero str_index str_ncpy str_cpy str_len timer_read_us timer_read_ms delay_us mon_alert_printf mon_alert_close | tftp_load_kernel |
| `010071ec` net_arp_reply |  | net_poll_recv |
| `010072a8` net_send_ip | net_ip_checksum | tftp_load_kernel bootp_request |
| `01007354` net_poll_recv | net_arp_reply mem_cmp | tftp_load_kernel bootp_request |
| `0100743c` net_ip_checksum |  | net_send_ip nvram_read nvram_write boot_check_label disk_label_check |
| `01007480` con_putc_crlf | con_putc | mon_init print_char_sink con_gets |
| `010074b2` vid_draw_char | mg_get_ptr bf_insert bf_extract vid_lock vid_unlock | print_char_sink |
| `0100766e` print_char_sink | mg_get_ptr con_putc_crlf vid_draw_char | print_number vprintf vprintf_case_c vprintf_case_b vprintf_case_s |
| `010076d2` print_number | print_char_sink | vprintf_case_oct vprintf_case_b |
| `01007772` printf | vprintf | mon_init exc_dispatch exc_nofault_bogus mon_command_loop mon_cmd_m mon_cmd_fcode mon_cmd_radix mon_cmd_huh mon_print_warning mon_password_check mon_usage_error mon_param_edit_table mon_param_sysreg mon_param_bootcmd mon_param_pot_bit mon_param_parity mon_param_reset_bit mon_print_help vid_vram_test post_run_all post_ret_fpu post_ret_scc post_ret_enet post_ret_ecc post_ret_rtc post_ret_timer post_ret_ext_scsi boot_cmd boot_cmd_paren_check boot_case_error boot_load_image_header tftp_load_kernel bootp_request con_gets enet_reg_read enet_reg_write enet_read enet_write enet_rx_int enet_rx_dma_start kms_power_key_check mon_alert_printf scsi_msgin_done scsi_abort sd_open sd_start_unit_wait_ready sd_read sd_command sd_print_error boot_fs_load boot_check_label boot_exec_blk0 od_ctrl_init od_volume_init od_open od_print_error fd_probe_media fd_open fd_intr_ok fd_print_error fc_reset fc_specify fc_send_cmd fc_cmd_result_phase dma_bytes_moved |
| `0100778a` sprintf | vprintf | boot_cmd_paren_check tftp_load_kernel vid_draw_panel boot_exec_blk0 |
| `010077a4` vid_printf_at | mg_get_ptr vid_draw_image_onscreen vprintf | mon_show_test_panel mon_system_test_failed boot_anim_step |
| `0100785c` printf_log | vprintf | mon_init mem_print_bad_sockets_nt mem_config_test_nt mem_report_error_t mem_config_test_t vid_vram_test post_scsi_dma_intr post_snd_out_overrun_intr post_snd_out_test |
| `01007876` vprintf | print_char_sink | printf sprintf vid_printf_at printf_log |
| `010078d6` vprintf_case_zero |  |  |
| `010078da` vprintf_case_width |  |  |
| `010078e0` vprintf_case_hex |  |  |
| `010078e4` vprintf_case_dec |  |  |
| `010078e8` vprintf_case_oct | print_number |  |
| `01007904` vprintf_case_c | print_char_sink |  |
| `01007926` vprintf_case_b | print_char_sink print_number |  |
| `01007b06` vprintf_case_s | print_char_sink |  |
| `01007b24` vprintf_case_pct |  |  |
| `01007b38` print_line |  | dma_cleanup dma_start |
| `01007b5c` con_gets | con_putc_crlf printf con_getc | mon_command_loop mon_cmd_password mon_password_check mon_param_edit_table mon_examine_memory bootp_request |
| `01007ca8` str_skip_space |  | mon_command_loop mon_param_edit_table mon_examine_memory boot_cmd boot_cmd_paren_check boot_case_error parse_number |
| `01007cd8` parse_number | mg_get_ptr str_skip_space str_index str_ncmp | mon_cmd_fcode mon_cmd_radix mon_param_edit_table mon_param_sysreg mon_examine_memory |
| `01007dd6` mem_alloc | mg_get_ptr mem_zero | post_enet_test enet_boot_open enet_init scsi_init sd_open boot_fs_open fd_open |
| `01007e0c` abs_l |  | post_evcnt_measured scc_calc_baud_tc |
| `01007e16` mem_cmp |  | mon_init exc_dispatch post_enet_test post_ecc_test bootp_request net_poll_recv enet_init |
| `01007ec8` mem_move |  | post_enet_test boot_load_image_header enet_boot_open tftp_load_kernel bootp_request nvram_write enet_init enet_read enet_write dma_setup_chain dma_cleanup fd_raw_cmd |
| `01007f66` loc_01007f66 |  |  |
| `01007ff2` loc_01007ff2 |  |  |
| `01007ffc` mem_zero |  | mg_init_type8_9 mon_init mon_cmd_password mon_password_check mem_config_test_nt mem_config_test_t vid_vram_test post_enet_test post_snd_out_test boot_cmd bootp_request mem_alloc nbus_probe_display_board vid_init_display vid_driver_init sd_inquiry sd_read_capacity sd_request_sense sd_start_unit_wait_ready sd_read boot_read_label od_ctrl_init od_volume_init od_read_label fd_build_rw_cmd fd_probe_read fd_sense_media fd_simple_cmd fd_vol_init fc_configure fc_specify fc_eject |
| `0100807c` str_index |  | bootp_request parse_number |
| `010080a2` str_ncpy |  | fd_pick_default_boot boot_cmd boot_cmd_paren_check bootp_request |
| `010080c2` str_cat |  |  |
| `010080d8` str_cmp |  | exc_dispatch mon_param_edit_table boot_case_no_media nvram_write enet_init |
| `010080f8` str_cpy |  | mg_init_type8_9 exc_dispatch mon_param_bootcmd boot_cmd boot_cmd_reload_default tftp_load_kernel bootp_request |
| `01008108` str_ncmp |  | mon_init exc_dispatch mon_cmd_password boot_cmd boot_cmd_paren_check parse_number |
| `01008130` str_len |  | mon_param_bootcmd boot_cmd_paren_check bootp_request vid_draw_panel |
| `01008140` con_getc | mg_get_ptr scc_getc vid_console_getc | con_gets |
| `01008184` con_try_getc | mg_get_ptr scc_try_getc kms_event_pending | post_ret_ext_scsi |
| `010081c8` con_putc | mg_get_ptr scc_putc vid_console_putc | con_putc_crlf |
| `0100822c` delay_1us | delay_us | rtc_write_reg rtc_read_reg_raw |
| `0100823e` rtc_wait_tick | rtc_read_reg delay_us | rtc_power_down |
| `0100828c` rtc_modify_reg | rtc_write_reg rtc_read_reg | rtc_power_int_handler rtc_power_down rtc_start_clock |
| `010082ca` rtc_power_int_handler | mg_get_ptr rtc_modify_reg rtc_read_reg | rtc_int_clear kms_console_init kms_power_key_check |
| `01008380` rtc_power_down | rtc_wait_tick rtc_modify_reg rtc_read_reg delay_us | kms_power_key_check |
| `010083d4` rtc_int_clear | rtc_power_int_handler rtc_write_reg rtc_read_reg | exc_dispatch rtc_start_clock |
| `01008400` rtc_start_clock | rtc_modify_reg rtc_int_clear rtc_write_reg rtc_read_reg | post_rtc_test |
| `01008440` time_tm_to_secs |  | rtc_get_time |
| `010084d6` rtc_get_time | time_tm_to_secs rtc_read_regs rtc_read_reg |  |
| `010085ec` bcd_to_bin |  |  |
| `0100861c` nvram_read | net_ip_checksum rtc_read_reg | mg_init_type8_9 exc_dispatch mon_cmd_password nvram_check_or_rtc_ramtest nvram_write kms_key_brightness |
| `0100866c` nvram_write | net_ip_checksum mem_move str_cmp nvram_read rtc_write_reg | mon_init mon_cmd_password mon_cmd_p kms_key_brightness vid_enable_display |
| `010086e8` rtc_write_reg | mg_get_ptr delay_1us | nvram_check_or_rtc_ramtest rtc_modify_reg rtc_int_clear rtc_start_clock nvram_write |
| `01008790` rtc_read_regs | rtc_read_reg | rtc_get_time |
| `010087cc` rtc_read_reg | rtc_read_reg_raw | post_rtc_test nvram_check_or_rtc_ramtest rtc_wait_tick rtc_modify_reg rtc_power_int_handler rtc_power_down rtc_int_clear rtc_start_clock rtc_get_time nvram_read rtc_read_regs |
| `010087e8` rtc_read_reg_raw | mg_get_ptr delay_1us | rtc_read_reg |
| `0100889c` timer_read_us | mg_get_ptr | tftp_load_kernel bootp_request timer_read_ms timer_elapsed_us delay_us |
| `0100890e` timer_read_ms | timer_read_us | tftp_load_kernel bootp_request |
| `01008924` timer_elapsed_us | timer_read_us | delay_us |
| `01008936` delay_us | timer_read_us timer_elapsed_us | post_delay_9us post_ext_scsi_test post_enet_test post_rtc_test post_timer_test post_evcnt_test kms_send_cmd post_snd_out_dma_stop kms_set_volume post_snd_out_test post_ret_ext_scsi boot_case_no_media boot_case_error bootp_request delay_1us rtc_wait_tick rtc_power_down scc_init scc_init_channel enet_reg_poll enet_init enet_write kms_send_reset kms_console_init kms_send_cmd_0100a520 vid_console_init adb_kbd_poll adb_kbd_raise_nmi adb_probe_kbd_alt_video scsi_init scsi_run_cmd scsi_start scsi_intr sd_request_sense sd_start_unit_wait_ready sd_command od_drive_query od_reset fc_reset fc_dma_reset fd_wait_intr |
| `01008964` scc_init | mg_get_ptr delay_us | exc_dispatch scc_getc scc_putc |
| `010089cc` scc_init_channel | delay_us scc_calc_baud_tc |  |
| `01008b30` scc_calc_baud_tc | abs_l | scc_init_channel |
| `01008bce` scc_getc_raw |  | scc_poll_flow_control scc_getc |
| `01008be8` scc_putc_raw |  | scc_putc |
| `01008c04` scc_rx_ready |  | scc_poll_flow_control |
| `01008c1a` scc_poll_flow_control | mg_get_ptr scc_getc_raw scc_rx_ready | scc_putc |
| `01008c72` scc_getc | mg_get_ptr scc_init scc_getc_raw | con_getc |
| `01008cd6` scc_try_getc | mg_get_ptr | con_try_getc |
| `01008cf4` scc_putc | mg_get_ptr scc_init scc_putc_raw scc_poll_flow_control | con_putc |
| `01008d68` scc_stub_ret0 |  |  |
| `01008d74` enet_reg_read | mon_probe_read_byte printf | enet_rx_int |
| `01008dc0` enet_reg_write | mon_probe_write_byte printf | enet_init enet_rx_int enet_rx_dma_start |
| `01008e0a` enet_reg_poll | mon_probe_read_byte delay_us | enet_write |
| `01008e56` enet_nop |  |  |
| `01008e5e` enet_init | mg_get_ptr cpu_get_vbr cpu_get_ipl mem_alloc mem_cmp mem_move str_cmp delay_us enet_reg_write enet_rx_dma_start | post_enet_test |
| `010090fe` enet_isr_dead_prologue |  |  |
| `01009102` enet_rx_isr | enet_rx_int |  |
| `01009116` enet_read | mg_get_ptr printf mem_move | post_enet_test |
| `0100928a` enet_write | mg_get_ptr printf mem_move delay_us enet_reg_poll | post_enet_test |
| `010095b2` enet_close | mg_get_ptr | post_enet_test |
| `010095f0` enet_rx_int | mg_get_ptr printf enet_reg_read enet_reg_write enet_rx_dma_start | enet_rx_isr |
| `010096be` enet_rx_dma_start | mg_get_ptr printf enet_reg_write | enet_init enet_rx_int |
| `01009860` kms_send_reset | delay_us | kbd_a_event_done kbd_b_event_done kbd_c_event_done kbd_d_event_done |
| `010098a4` kms_console_init | mg_get_ptr rtc_power_int_handler delay_us vid_text_reset kms_send_cmd_wait kms_send_cmd_0100a520 vid_cursor_toggle | vid_console_putc |
| `010099e6` vid_text_reset | mg_get_ptr | kms_console_init vid_draw_panel |
| `01009a2c` vid_draw_panel | mg_get_ptr sprintf str_len vid_text_reset vid_putc vid_cursor_toggle vid_lock | vid_console_putc mon_alert_printf |
| `01009e9a` vid_restore_panel | mg_get_ptr vid_unlock | mon_alert_close |
| `01009fde` mon_clear_nmi | mg_get_ptr | exc_dispatch |
| `0100a00e` kms_poll_km_event | mg_get_ptr | con_flow_control_poll |
| `0100a06c` kms_event_pending | mg_get_ptr adb_kbd_getevent | con_try_getc |
| `0100a0ac` con_flow_control_poll | mg_get_ptr kms_poll_km_event kms_read_key | vid_console_putc |
| `0100a118` vid_console_putc | mg_get_ptr kms_console_init vid_draw_panel con_flow_control_poll vid_putc | con_putc |
| `0100a1a8` kms_power_key_check | mg_get_ptr printf rtc_power_int_handler rtc_power_down kms_translate_key vid_putc adb_kbd_getevent od_eject fd_eject | mon_init exc_dispatch mon_system_test_failed post_run_all post_ret_fpu post_ret_scc post_ret_ecc post_ret_rtc post_ret_timer boot_case_error boot_anim_step kms_read_key scsi_run_cmd scsi_intr sd_open sd_start_unit_wait_ready od_issue od_drive_cmd od_cmd |
| `0100a2ba` kms_read_key | mg_get_ptr kms_power_key_check kms_translate_key kms_send_cmd_wait kms_send_cmd_0100a520 adb_kbd_getevent | con_flow_control_poll vid_console_getc |
| `0100a3a6` vid_console_getc | mg_get_ptr kms_read_key | con_getc |
| `0100a3f2` kms_translate_key | mg_get_ptr | kms_power_key_check kms_read_key |
| `0100a47c` kms_key_brightness | nvram_read nvram_write vid_driver_set_brightness |  |
| `0100a4da` kms_send_cmd_wait | kms_send_cmd_0100a520 | kms_console_init kms_read_key |
| `0100a520` kms_send_cmd_0100a520 | mg_get_ptr delay_us | kms_set_volume kms_console_init kms_read_key kms_send_cmd_wait |
| `0100a56c` vid_clear_text_area | mg_get_ptr vid_lock vid_unlock | vid_putc_ff |
| `0100a5fa` vid_clear_screen | mg_get_ptr vid_lock vid_unlock | exc_dispatch vid_console_init nbus_probe_display_board |
| `0100a63c` vid_putc | mg_get_ptr vid_cursor_toggle vid_lock | vid_draw_panel vid_console_putc kms_power_key_check vid_putc_tab |
| `0100a678` vid_putc_cr | vid_cursor_toggle |  |
| `0100a69c` vid_putc_lf |  |  |
| `0100a6a4` vid_putc_bs |  |  |
| `0100a6b4` vid_putc_tab | vid_putc vid_cursor_toggle |  |
| `0100a6f2` vid_putc_ff | vid_clear_text_area |  |
| `0100a704` vid_putc_bel |  |  |
| `0100a71a` vid_putc_glyph |  |  |
| `0100a8b2` vid_putc_advance |  |  |
| `0100a94c` vid_scroll_copy_31 |  |  |
| `0100a94e` vid_scroll_copy_30 |  |  |
| `0100a950` vid_scroll_copy_29 |  |  |
| `0100a952` vid_scroll_copy_28 |  |  |
| `0100a954` vid_scroll_copy_27 |  |  |
| `0100a956` vid_scroll_copy_26 |  |  |
| `0100a958` vid_scroll_copy_25 |  |  |
| `0100a95a` vid_scroll_copy_24 |  |  |
| `0100a95c` vid_scroll_copy_23 |  |  |
| `0100a95e` vid_scroll_copy_22 |  |  |
| `0100a960` vid_scroll_copy_21 |  |  |
| `0100a962` vid_scroll_copy_20 |  |  |
| `0100a964` vid_scroll_copy_19 |  |  |
| `0100a966` vid_scroll_copy_18 |  |  |
| `0100a968` vid_scroll_copy_17 |  |  |
| `0100a96a` vid_scroll_copy_16 |  |  |
| `0100a96c` vid_scroll_copy_15 |  |  |
| `0100a96e` vid_scroll_copy_14 |  |  |
| `0100a970` vid_scroll_copy_13 |  |  |
| `0100a972` vid_scroll_copy_12 |  |  |
| `0100a974` vid_scroll_copy_11 |  |  |
| `0100a976` vid_scroll_copy_10 |  |  |
| `0100a978` vid_scroll_copy_9 |  |  |
| `0100a97a` vid_scroll_copy_8 |  |  |
| `0100a97c` vid_scroll_copy_7 |  |  |
| `0100a97e` vid_scroll_copy_6 |  |  |
| `0100a980` vid_scroll_copy_5 |  |  |
| `0100a982` vid_scroll_copy_4 |  |  |
| `0100a984` vid_scroll_copy_3 |  |  |
| `0100a986` vid_scroll_copy_2 |  |  |
| `0100a988` vid_scroll_copy_1 |  |  |
| `0100a98a` vid_scroll_copy_0 | vid_cursor_toggle vid_clear_to_eol vid_unlock |  |
| `0100a9ce` vid_cursor_toggle | mg_get_ptr vid_lock vid_unlock | kms_console_init vid_draw_panel vid_putc vid_putc_cr vid_putc_tab vid_scroll_copy_0 |
| `0100aa76` vid_clear_to_eol | mg_get_ptr vid_lock vid_unlock | vid_scroll_copy_0 |
| `0100ab1e` mon_alert_printf | mg_get_ptr printf vid_draw_panel | bootp_request mon_boot_error |
| `0100ab7c` mon_boot_error | mon_alert_printf |  |
| `0100aba4` mon_alert_close | mg_get_ptr vid_restore_panel | bootp_request |
| `0100abdc` nbus_rom_read_long | mg_get_ptr | nbus_probe_display_board vid_post_init vid_init_display |
| `0100ac8a` vid_console_init | mg_init_machine mon_probe_read_long delay_us vid_clear_screen nbus_probe_display_board vid_init_display vid_find_driver vid_enable_display vid_driver_init vid_driver_setup_dac adb_probe_kbd_alt_video | reset_install_vectors |
| `0100ae26` nbus_probe_display_board | mon_probe_read_long mem_zero vid_clear_screen nbus_rom_read_long vid_post_init vid_init_display nbus_run_boardcode | vid_console_init |
| `0100b012` vid_post_init | nbus_rom_read_long nbus_run_boardcode vid_enable_display | exc_dispatch nbus_probe_display_board |
| `0100b04e` vid_init_display | mem_zero nbus_rom_read_long vid_driver_init | exc_dispatch vid_console_init nbus_probe_display_board |
| `0100b2b2` vid_lock | mg_get_ptr nbus_run_boardcode vid_driver_enter | vid_draw_image vid_draw_char vid_draw_panel vid_clear_text_area vid_clear_screen vid_putc vid_cursor_toggle vid_clear_to_eol |
| `0100b2f4` vid_unlock | mg_get_ptr nbus_run_boardcode vid_driver_exit | vid_draw_image vid_draw_char vid_restore_panel vid_clear_text_area vid_clear_screen vid_scroll_copy_0 vid_cursor_toggle vid_clear_to_eol |
| `0100b338` nbus_map_addr | mg_get_ptr | nbus_op_ldmem_reg nbus_op_stmem_reg nbus_op_block_store |
| `0100b38c` nbus_run_boardcode | mg_get_ptr | nbus_probe_display_board vid_post_init vid_lock vid_unlock |
| `0100b3b0` nbus_op_next |  |  |
| `0100b3ee` nbus_op_ldi |  |  |
| `0100b3fe` nbus_op_ldmem_imm |  |  |
| `0100b41e` nbus_op_ldmem_reg | nbus_map_addr |  |
| `0100b468` nbus_op_stmem_imm |  |  |
| `0100b488` nbus_op_stmem_reg | nbus_map_addr |  |
| `0100b4d2` nbus_op_block_store | nbus_map_addr |  |
| `0100b528` nbus_op_addi |  |  |
| `0100b54a` nbus_op_add |  |  |
| `0100b576` nbus_op_subi |  |  |
| `0100b598` nbus_op_rsubi |  |  |
| `0100b5ba` nbus_op_sub |  |  |
| `0100b5e6` nbus_op_andi |  |  |
| `0100b608` nbus_op_and |  |  |
| `0100b634` nbus_op_ori |  |  |
| `0100b656` nbus_op_or |  |  |
| `0100b682` nbus_op_xori |  |  |
| `0100b6a4` nbus_op_xor |  |  |
| `0100b6d2` nbus_op_shl |  |  |
| `0100b6fc` nbus_op_asr |  |  |
| `0100b726` nbus_op_mov |  |  |
| `0100b744` nbus_op_test |  |  |
| `0100b776` nbus_op_bgt |  |  |
| `0100b77e` nbus_op_blt |  |  |
| `0100b786` nbus_op_beq |  |  |
| `0100b78e` nbus_op_ble |  |  |
| `0100b796` nbus_op_bge |  |  |
| `0100b79e` nbus_op_bne |  |  |
| `0100b7a4` nbus_op_jump |  |  |
| `0100b7b0` nbus_op_return |  |  |
| `0100b7c0` vid_find_driver |  | vid_console_init |
| `0100b802` vid_enable_display | nvram_write | vid_console_init vid_post_init |
| `0100b85c` vid_driver_init | mem_zero | vid_console_init vid_init_display |
| `0100b8a6` vid_driver_setup_dac |  | vid_console_init |
| `0100b8d8` vid_driver_enter |  | vid_lock |
| `0100b90a` vid_driver_exit |  | vid_unlock |
| `0100b93c` vid_driver_set_brightness |  | kms_key_brightness |
| `0100b972` vid_probe_color_1120 |  |  |
| `0100b994` vid_probe_scr2_vidmode |  |  |
| `0100b99e` vid_probe_yes |  |  |
| `0100b9a2` vid_probe_no |  |  |
| `0100b9a8` vid_probe_color_832 |  |  |
| `0100b9e6` vid_init_color_1120x832 |  |  |
| `0100bb8e` vid_init_color_832x624 |  |  |
| `0100bc78` dac_init_bt463 |  |  |
| `0100be7c` vid_color_enable | dac_set_brightness_palette |  |
| `0100bebe` dac_set_brightness_palette |  | vid_color_enable |
| `0100bf72` vid_probe_mono |  |  |
| `0100bf94` vid_probe_mono_no |  |  |
| `0100bf98` vid_probe_mono_yes |  |  |
| `0100bf9e` vid_init_mono_1120x832 |  |  |
| `0100c146` vid2_nop_m2 |  |  |
| `0100c14e` vid2_enable |  |  |
| `0100c18a` vid2_set_brightness |  |  |
| `0100c1aa` vid_nop |  |  |
| `0100c1b4` adb_init | mg_get_ptr adb_reset_bus adb_send_cmd adb_talk adb_kbd_init adb_mouse_init | mon_init |
| `0100c2c2` adb_intr | mg_get_ptr adb_send_cmd |  |
| `0100c398` adb_kbd_poll | mg_get_ptr delay_us adb_send_cmd | kbd_b_event_done kbd_c_event_done |
| `0100c458` adb_reset_bus |  | adb_init adb_kbd_raise_nmi adb_probe_kbd_alt_video |
| `0100c482` adb_send_cmd |  | adb_init adb_intr adb_kbd_poll adb_talk adb_listen |
| `0100c4fa` adb_talk | adb_send_cmd | adb_init adb_probe_kbd_alt_video |
| `0100c572` adb_listen | adb_send_cmd | adb_kbd_handler kbd_a_down_capslock adb_kbd_getevent_unused kbd_b_down_capslock adb_kbd_getevent kbd_c_down_capslock kbd_c_event_done kbd_d_down_capslock |
| `0100c5a6` adb_kbd_raise_nmi | mg_get_ptr delay_us adb_reset_bus | kbd_a_event_done kbd_b_event_done kbd_d_event_done |
| `0100c5e0` adb_set_config | mg_get_ptr |  |
| `0100c626` adb_probe_kbd_alt_video | delay_us adb_reset_bus adb_talk | vid_console_init |
| `0100c68a` tmc_alt_timing_color |  |  |
| `0100c6a4` tmc_alt_timing_mono |  |  |
| `0100c6c4` adb_kbd_init | mg_get_ptr | adb_init |
| `0100c788` adb_kbd_handler | mg_get_ptr adb_listen |  |
| `0100c958` kbd_a_up_ctrl_l |  |  |
| `0100c962` kbd_a_up_ctrl_r |  |  |
| `0100c96c` kbd_a_up_cmd |  |  |
| `0100c986` kbd_a_up_shift_l |  |  |
| `0100c99e` kbd_a_up_shift_r |  |  |
| `0100c9a8` kbd_a_up_alt_l |  |  |
| `0100c9ce` kbd_a_up_alt_r |  |  |
| `0100c9e6` kbd_a_up_capslock | mg_get_ptr |  |
| `0100ca3e` kbd_a_up_help |  |  |
| `0100ca82` kbd_a_down_ctrl_l |  |  |
| `0100ca8a` kbd_a_down_ctrl_r |  |  |
| `0100caac` kbd_a_down_cmd |  |  |
| `0100cac6` kbd_a_down_shift_l |  |  |
| `0100cade` kbd_a_down_shift_r |  |  |
| `0100cae8` kbd_a_down_alt_l |  |  |
| `0100cb06` kbd_a_down_alt_r |  |  |
| `0100cb14` kbd_a_down_capslock | mg_get_ptr adb_listen |  |
| `0100cb74` kbd_a_down_help |  |  |
| `0100cb8e` kbd_a_event_done | kms_send_reset adb_kbd_raise_nmi |  |
| `0100cc06` adb_kbd_getevent_unused | mg_get_ptr adb_listen |  |
| `0100cd68` kbd_b_up_ctrl_l |  |  |
| `0100cd72` kbd_b_up_ctrl_r |  |  |
| `0100cd7c` kbd_b_up_cmd |  |  |
| `0100cd96` kbd_b_up_shift_l |  |  |
| `0100cdae` kbd_b_up_shift_r |  |  |
| `0100cdb8` kbd_b_up_alt_l |  |  |
| `0100cdde` kbd_b_up_alt_r |  |  |
| `0100cdf6` kbd_b_up_capslock | mg_get_ptr |  |
| `0100ce4e` kbd_b_up_help |  |  |
| `0100ce92` kbd_b_down_ctrl_l |  |  |
| `0100ce9a` kbd_b_down_ctrl_r |  |  |
| `0100cebc` kbd_b_down_cmd |  |  |
| `0100ced6` kbd_b_down_shift_l |  |  |
| `0100ceee` kbd_b_down_shift_r |  |  |
| `0100cef8` kbd_b_down_alt_l |  |  |
| `0100cf16` kbd_b_down_alt_r |  |  |
| `0100cf24` kbd_b_down_capslock | mg_get_ptr adb_listen |  |
| `0100cf84` kbd_b_down_help |  |  |
| `0100cf9e` kbd_b_event_done | kms_send_reset adb_kbd_poll adb_kbd_raise_nmi |  |
| `0100d032` adb_kbd_getevent | mg_get_ptr adb_listen | kms_event_pending kms_power_key_check kms_read_key |
| `0100d194` kbd_c_up_ctrl_l |  |  |
| `0100d19e` kbd_c_up_ctrl_r |  |  |
| `0100d1a8` kbd_c_up_cmd |  |  |
| `0100d1c2` kbd_c_up_shift_l |  |  |
| `0100d1da` kbd_c_up_shift_r |  |  |
| `0100d1e4` kbd_c_up_alt_l |  |  |
| `0100d20a` kbd_c_up_alt_r |  |  |
| `0100d222` kbd_c_up_capslock | mg_get_ptr |  |
| `0100d27a` kbd_c_up_help |  |  |
| `0100d2be` kbd_c_down_ctrl_l |  |  |
| `0100d2c6` kbd_c_down_ctrl_r |  |  |
| `0100d2e8` kbd_c_down_cmd |  |  |
| `0100d302` kbd_c_down_shift_l |  |  |
| `0100d31a` kbd_c_down_shift_r |  |  |
| `0100d324` kbd_c_down_alt_l |  |  |
| `0100d342` kbd_c_down_alt_r |  |  |
| `0100d350` kbd_c_down_capslock | mg_get_ptr adb_listen |  |
| `0100d3b0` kbd_c_down_help |  |  |
| `0100d3ca` kbd_c_event_done | mg_get_ptr kms_send_reset adb_kbd_poll adb_listen |  |
| `0100d5ee` kbd_d_up_ctrl_l |  |  |
| `0100d5f8` kbd_d_up_ctrl_r |  |  |
| `0100d602` kbd_d_up_cmd |  |  |
| `0100d61c` kbd_d_up_shift_l |  |  |
| `0100d634` kbd_d_up_shift_r |  |  |
| `0100d63e` kbd_d_up_alt_l |  |  |
| `0100d664` kbd_d_up_alt_r |  |  |
| `0100d67c` kbd_d_up_capslock | mg_get_ptr |  |
| `0100d6d4` kbd_d_up_help |  |  |
| `0100d718` kbd_d_down_ctrl_l |  |  |
| `0100d720` kbd_d_down_ctrl_r |  |  |
| `0100d742` kbd_d_down_cmd |  |  |
| `0100d75c` kbd_d_down_shift_l |  |  |
| `0100d774` kbd_d_down_shift_r |  |  |
| `0100d77e` kbd_d_down_alt_l |  |  |
| `0100d79c` kbd_d_down_alt_r |  |  |
| `0100d7aa` kbd_d_down_capslock | mg_get_ptr adb_listen |  |
| `0100d80a` kbd_d_down_help |  |  |
| `0100d824` kbd_d_event_done | kms_send_reset adb_kbd_raise_nmi |  |
| `0100d8a6` adb_mouse_init | mg_get_ptr | adb_init |
| `0100d986` adb_nop |  |  |
| `0100d98e` adb_kbd_present | mg_get_ptr |  |
| `0100d9aa` adb_dev_handler_stub |  |  |
| `0100d9b4` scsi_init | mem_alloc delay_us dma_init | scsi_abort sd_open |
| `0100db8e` scsi_run_cmd | delay_us kms_power_key_check scsi_start scsi_intr scsi_abort | sd_request_sense sd_command |
| `0100dc44` scsi_start | delay_us scsi_abort | scsi_run_cmd |
| `0100dd4e` scsi_intr | delay_us kms_power_key_check | scsi_run_cmd |
| `0100de50` scsi_intr_selected |  |  |
| `0100de86` scsi_intr_state6 |  |  |
| `0100de9a` scsi_intr_dma_done | dma_cleanup |  |
| `0100dee2` scsi_intr_status |  |  |
| `0100df1e` scsi_intr_msgin | scsi_msgin_done scsi_abort |  |
| `0100df5e` scsi_intr_complete |  |  |
| `0100df74` scsi_intr_bad_state | scsi_phase_dispatch scsi_abort |  |
| `0100df9e` scsi_phase_dispatch |  | scsi_intr_bad_state |
| `0100dfe4` scsi_phase_data_out | dma_setup_chain dma_start |  |
| `0100e05e` scsi_phase_datain | dma_setup_chain dma_start |  |
| `0100e0e6` scsi_phase_status |  |  |
| `0100e0f4` scsi_phase_msgin |  |  |
| `0100e106` scsi_phase_msgout_err |  |  |
| `0100e10c` scsi_phase_error | scsi_abort |  |
| `0100e11e` scsi_msgin_done | printf scsi_abort | scsi_intr_msgin |
| `0100e188` scsi_abort | printf scsi_init dma_stop | scsi_run_cmd scsi_start scsi_intr_msgin scsi_intr_bad_state scsi_phase_error scsi_msgin_done |
| `0100e1ec` sd_open | printf mem_alloc kms_power_key_check scsi_init sd_close sd_find_target sd_read_capacity sd_start_unit_wait_ready |  |
| `0100e2f0` sd_close |  | sd_open |
| `0100e2f8` sd_find_target | sd_inquiry | sd_open |
| `0100e356` sd_inquiry | mem_zero sd_command | sd_find_target |
| `0100e40a` sd_read_capacity | mem_zero sd_command sd_print_error | sd_open |
| `0100e49a` sd_request_sense | mem_zero delay_us scsi_run_cmd sd_print_error | sd_command |
| `0100e548` sd_start_unit_wait_ready | printf mem_zero delay_us kms_power_key_check sd_command | sd_open |
| `0100e646` sd_read | printf mem_zero sd_command sd_print_error |  |
| `0100e726` sd_write_stub |  |  |
| `0100e72e` sd_label_blkno |  |  |
| `0100e750` sd_command | printf delay_us scsi_run_cmd sd_request_sense | sd_inquiry sd_read_capacity sd_start_unit_wait_ready sd_read |
| `0100e7ee` sd_print_error | printf | sd_read_capacity sd_request_sense sd_read |
| `0100e8cc` dma_init | mg_get_ptr | scsi_init od_ctrl_init fc_init |
| `0100e94a` dma_setup_chain | mem_move | scsi_phase_data_out scsi_phase_datain od_issue fc_send_cmd fc_dma_reset |
| `0100ea5a` dma_cleanup | print_line mem_move dma_stop | scsi_intr_dma_done fc_cmd_result_phase |
| `0100eacc` dma_start | mg_get_ptr print_line | scsi_phase_data_out scsi_phase_datain od_issue fc_send_cmd fc_dma_reset |
| `0100eb90` dma_stop |  | scsi_abort dma_cleanup od_complete fc_send_cmd_exit fc_dma_reset |
| `0100ebc4` boot_fs_open | mem_alloc |  |
| `0100ec4e` boot_fs_load | printf boot_read_label boot_exec_blk0 |  |
| `0100ed2e` boot_read_label | mem_zero boot_check_label boot_fs_seek boot_fs_read | boot_fs_load |
| `0100edc4` boot_check_label | net_ip_checksum printf | boot_read_label |
| `0100ee54` boot_exec_blk0 | boot_load_image_header printf sprintf boot_fs_seek boot_fs_read | boot_fs_load |
| `0100ef50` boot_fs_seek |  | boot_read_label boot_exec_blk0 |
| `0100ef66` boot_fs_read |  | boot_read_label boot_exec_blk0 |
| `0100f044` boot_fs_close |  |  |
| `0100f060` od_ctrl_init | mg_get_ptr printf mem_zero dma_init | od_open |
| `0100f166` od_volume_init | mg_get_ptr printf mem_zero od_read_label | od_open |
| `0100f22e` od_label_blkno |  |  |
| `0100f244` od_open | printf od_ctrl_init od_volume_init | od_eject od_query_status |
| `0100f2c0` od_close |  |  |
| `0100f2c8` od_read | od_cmd |  |
| `0100f2fe` od_write_stub |  |  |
| `0100f306` od_strategy | mg_get_ptr od_start_io | od_cmd |
| `0100f35a` od_start_io | od_cmd_dispatch | od_strategy |
| `0100f3e0` od_cmd_dispatch | mg_get_ptr | od_start_io od_cmd_next_chunk od_complete |
| `0100f43a` od_cmd_start | od_issue od_drive_cmd od_drive_query |  |
| `0100f66c` od_cmd_seek_low |  |  |
| `0100f696` od_cmd_resume |  |  |
| `0100f6ac` od_cmd_fail_ret |  |  |
| `0100f6b2` od_cmd_check_motor | od_complete od_drive_cmd od_drive_query |  |
| `0100f6fa` od_cmd_finish |  |  |
| `0100f716` od_cmd_after_eject |  |  |
| `0100f734` od_cmd_next_chunk | od_cmd_dispatch |  |
| `0100f778` od_cmd_error_finish | od_print_error |  |
| `0100f796` od_cmd_xfer | od_complete od_issue |  |
| `0100f7dc` od_complete | dma_stop od_cmd_dispatch od_drive_cmd od_print_error od_read_drive_status | od_cmd_check_motor od_cmd_xfer |
| `0100fadc` od_issue | mg_get_ptr kms_power_key_check dma_setup_chain dma_start od_drive_cmd | od_cmd_start od_cmd_xfer |
| `0100fc00` od_drive_cmd | mg_get_ptr kms_power_key_check | od_cmd_start od_cmd_check_motor od_complete od_issue od_read_drive_status od_drive_query |
| `0100fcec` od_print_error | printf | od_cmd_error_finish od_complete |
| `0100fdc6` od_read_drive_status | od_drive_cmd od_drive_query | od_complete |
| `0100ff6a` od_drive_query | delay_us od_drive_cmd | od_cmd_start od_cmd_check_motor od_read_drive_status od_query_status |
| `01010002` stub_rts |  |  |
| `01010004` od_cmd | mg_get_ptr kms_power_key_check od_strategy | od_read od_read_label od_eject |
| `010100aa` od_read_label | mg_get_ptr mem_zero od_cmd disk_label_check | od_volume_init |
| `01010218` disk_label_check | net_ip_checksum | od_read_label |
| `0101027e` od_eject | mg_get_ptr od_open od_cmd | mon_cmd_e boot_case_error kms_power_key_check |
| `0101030e` od_reset | mg_get_ptr delay_us | exc_dispatch |
| `0101034c` od_query_status | mg_get_ptr od_open od_drive_query | mon_param_reset_bit |
| `010103d0` fd_probe_media | printf fd_probe_read fd_sense_media fd_recalibrate fd_simple_cmd fd_set_density fd_set_geometry | fd_open |
| `01010562` fd_open | printf mem_alloc fd_probe_media fd_close fd_vol_init fc_init | fd_eject |
| `01010680` fd_close |  | fd_open |
| `01010688` fd_read | fd_setup_io |  |
| `010106d6` fd_write_nop |  |  |
| `010106de` fd_round_to_sectors |  |  |
| `01010700` fd_eject | mg_get_ptr fd_open fd_simple_cmd | mon_cmd_e kms_power_key_check |
| `0101075a` fd_raw_cmd | mem_move fd_run_io | fd_probe_read fd_sense_media fd_recalibrate fd_simple_cmd |
| `010107bc` fd_run_io | fd_start_transfer fc_start | fd_raw_cmd fd_setup_io |
| `0101080e` fd_intr |  | fc_start_type5 |
| `0101089e` fd_intr_ok | printf |  |
| `010108e2` fd_intr_error | fd_print_error fd_start_transfer fd_build_recal_cmd |  |
| `01010970` fd_intr_fatal | fd_print_error |  |
| `01010988` fd_print_error | printf | fd_intr_error fd_intr_fatal |
| `010109c8` fd_start_transfer | fd_build_rw_cmd fd_lba_to_chs | fd_run_io fd_intr_error |
| `01010a62` fd_build_rw_cmd | mem_zero fd_lba_to_chs | fd_start_transfer fd_probe_read |
| `01010b4a` fd_setup_io | fd_run_io | fd_read |
| `01010b92` fd_probe_read | mem_zero fd_raw_cmd fd_build_rw_cmd | fd_probe_media |
| `01010be8` fd_sense_media | mem_zero fd_raw_cmd | fd_probe_media |
| `01010c26` fd_recalibrate | fd_raw_cmd fd_build_recal_cmd | fd_probe_media |
| `01010c54` fd_simple_cmd | mem_zero fd_raw_cmd | fd_probe_media fd_eject |
| `01010c92` fd_build_recal_cmd |  | fd_intr_error fd_recalibrate |
| `01010ce0` fd_lba_to_chs |  | fd_start_transfer fd_build_rw_cmd |
| `01010d36` fd_vol_init | mem_zero | fd_open |
| `01010d70` fd_set_density |  | fd_probe_media |
| `01010dba` fd_set_geometry |  | fd_probe_media |
| `01010e14` fc_init | dma_init fc_reset | fd_open |
| `01010e96` fc_start | fc_reset | fd_run_io |
| `01010f3a` fc_start_type1 | fc_do_command |  |
| `01010f48` fc_start_type2 | fc_eject |  |
| `01010f58` fc_start_type3 | fc_motor_on |  |
| `01010f62` fc_start_type4 | fc_motor_off |  |
| `01010f76` fc_start_type5 | fd_intr fc_reset fc_read_media_status |  |
| `0101100e` fc_intr | mg_get_ptr fc_send_byte | fd_wait_intr |
| `010110d8` fc_reset | printf delay_us fc_configure fc_specify | fc_init fc_start fc_start_type5 |
| `01011182` fc_send_byte | fc_wait_rqm | fc_intr fc_send_cmd |
| `010111b0` fc_get_byte | fc_wait_rqm | fc_cmd_result_phase |
| `010111dc` fc_wait_rqm |  | fc_send_byte fc_get_byte |
| `01011230` fc_ctrl_set |  | fc_eject |
| `0101124e` fc_ctrl_clr |  | fc_eject |
| `0101126e` fc_read_media_status |  | fc_start_type5 |
| `010112ba` fc_configure | mem_zero fc_send_cmd | fc_reset fc_do_command |
| `0101130e` fc_specify | printf mem_zero fc_send_cmd | fc_reset fc_do_command |
| `0101148c` fc_do_command | fc_configure fc_specify | fc_start_type1 |
| `01011536` fc_cmd_motor_on | fc_motor_on |  |
| `01011554` fc_cmd_send | fc_send_cmd |  |
| `0101156c` fc_eject | mem_zero fc_ctrl_set fc_ctrl_clr fc_build_seek_cmd fc_motor_on fc_motor_off fc_send_cmd fd_wait_intr | fc_start_type2 |
| `01011616` fc_build_seek_cmd |  | fc_eject |
| `01011670` fc_motor_on | fd_wait_intr | fc_start_type3 fc_cmd_motor_on fc_eject |
| `010116ac` fc_motor_off |  | fc_start_type4 fc_eject |
| `010116d2` fc_send_cmd | mg_get_ptr printf dma_setup_chain dma_start fc_send_byte fc_dma_reset | fc_configure fc_specify fc_cmd_send fc_eject |
| `01011864` fc_cmd_wait_intr | fd_wait_intr |  |
| `0101187e` fc_cmd_result_phase | printf dma_cleanup fc_get_byte fc_dma_reset dma_bytes_moved |  |
| `010119e8` fc_check_rw_result |  |  |
| `01011a24` fc_check_seek_result |  |  |
| `01011a44` fc_check_recal_result |  |  |
| `01011a60` fc_send_cmd_exit | dma_stop |  |
| `01011a82` fc_dma_reset | delay_us dma_setup_chain dma_start dma_stop | fc_send_cmd fc_cmd_result_phase |
| `01011ae8` dma_bytes_moved | printf | fc_cmd_result_phase |
| `01011b6c` fd_wait_intr | mg_get_ptr delay_us fc_intr | fc_eject fc_motor_on fc_cmd_wait_intr |
