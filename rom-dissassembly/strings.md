# Strings

271 NUL-terminated strings.  `refs` = code that names the address (absolute operands only; PC-relative and table references are not counted); `in routine` = the routine containing the first reference.

| address | refs | in routine | text |
|---|---|---|---|
| 01012c4e |  |  | `cacr` |
| 01012c5b |  |  | `intrstat` |
| 01012d4e |  |  | `softint1` |
| 01012d57 |  |  | `intrmask` |
| 01012d60 |  |  | `scr1` |
| 01012d89 |  |  | `ccms` |
| 01012d8e |  |  | `scr2` |
| 01012e12 |  |  | `ekgLED` |
| 01012ed5 |  |  | `softint1` |
| 01012f00 |  |  | `cspd` |
| 01012f72 |  |  | `ekgLED` |
| 01012f79 |  |  | `boot command` |
| 01012f86 |  |  | `DRAM tests` |
| 01012f91 |  |  | `perform power-on system test` |
| 01012fae |  |  | `\tsound out tests` |
| 01012fbf |  |  | `\tSCSI tests` |
| 01012fcb |  |  | `\tloop until keypress` |
| 01012fe0 |  |  | `\tverbose test mode` |
| 01012ff3 |  |  | `serial port A is alternate console` |
| 01013016 |  |  | `allow any ROM command even if password protected` |
| 01013047 |  |  | `allow boot from any device even if password protected` |
| 0101307d |  |  | `allow optical drive #0 eject even if password protected` |
| 010130b5 |  |  | `enable parity checking if parity memory is present` |
| 010130fb |  |  | `16MB of nibble mode` |
| 0101310f |  |  | `4MB of nibble mode` |
| 01013122 |  |  | `1MB of nibble mode` |
| 01013135 |  |  | `illegal` |
| 0101313d |  |  | `16MB of page mode` |
| 0101314f |  |  | `4MB of page mode` |
| 01013160 |  |  | `1MB of page mode (illegal)` |
| 0101317b |  |  | `16MB of parity nibble mode` |
| 01013196 |  |  | `4MB of parity nibble mode` |
| 010131b0 |  |  | `1MB of parity nibble mode` |
| 010131ca |  |  | `16MB of parity page mode` |
| 010131e3 |  |  | `4MB of parity page mode` |
| 010131fb |  |  | `1MB of parity page mode (illegal)` |
| 0101321d |  |  | `32MB of page mode` |
| 0101322f |  |  | `8MB of page mode` |
| 01013240 |  |  | `2MB of page mode` |
| 01013251 |  |  | `32MB of parity page mode` |
| 0101326a |  |  | `8MB of parity page mode` |
| 01013282 |  |  | `2MB of parity page mode` |
| 0101329d | 01000e6a | mon_show_test_panel | `Testing\nsystem ...` |
| 010132b0 | 010010e2 010012c2 | mon_init | `Main Memory Configuration Test Failed\n\n` |
| 010132d8 | 0100111e 010012fa | mon_init | `Main Memory Test Failed\n\n` |
| 010132f2 | 0100120c | mon_init | `VRAM` |
| 010132f7 | 01001222 | mon_init | `VRAM Memory Test Failed\n` |
| 01013310 | 01001368 | mon_init | `Secondary Cache ram Test Fail\n\n` |
| 01013330 | 0100139c | mon_init | `Secondary Tag ram Test Fail\n\n` |
| 0101334e | 010013c2 | mon_init | `CPU MC68040 ` |
| 0101335b | 01001466 | mon_init | `%d MHz, memory %d nS\n` |
| 01013371 | 01001486 | mon_init | `Backplane slot #%d\n` |
| 01013385 | 010014be | mon_init | `Ethernet address: %x:%x:%x:%x:%x:%x\n` |
| 010133aa | 010014d6 | mon_init | `Warning: non-volatile memory is uninitialized.\n` |
| 010133da | 010015b8 | mon_init | `Memory sockets %d-%d configured for %s SIMMs but have %s SIMMs installed.\n` |
| 01013425 | 010015e6 | mon_init | `Memory sockets %d and %d configured for %s SIMMs but have %s SIMMs installed.\n` |
| 01013474 | 01001610 01002100 | mon_init | `back` |
| 01013479 | 01001618 01002108 | mon_init | `front` |
| 0101347f | 0100162c | mon_init | `Memory sockets %d and %d (%s) configured for %s SIMMs but have %s SIMMs installed.\n` |
| 010134d3 | 01001698 | mon_init | `Memory size %dMB` |
| 010134e4 | 010016ae | mon_init | `, parity enabled` |
| 010134f7 | 01001726 | mon_init | `can't continue without some working memory\n` |
| 01013526 | 0100182a | mon_init | `System test failed.  Error code %x.\n\n` |
| 0101354c | 01001858 | mon_init | `\nSystem test passed.\n` |
| 0101356b | 01001c02 01006188 | exc_dispatch | `No default boot command.\n` |
| 01013587 | 01001cf8 | exc_dispatch | `\nparity error: status 0x%x, address 0x%x, data 0x%x\n` |
| 010135bc | 01001d5e | exc_nofault_bogus | `bogus stack frame\n` |
| 010135cf | 01001dac | exc_nofault_resume | `Exception #%d (0x%x) at pc 0x%x sp 0x%x\n` |
| 010135f8 | 01001dce | exc_nofault_resume | `faultaddr 0x%x\n` |
| 0101360e | 01001ef8 | mon_cmd_password | `New password: ` |
| 0101361d | 01001f42 | mon_cmd_password | `Retype new password: ` |
| 01013633 | 01001f88 | mon_cmd_password | `Mismatch - password unchanged\n` |
| 01013657 | 01002084 | mon_cmd_m | `Memory sockets %d-%d have %s SIMMs installed (0x%x-0x%x)\n` |
| 01013691 | 010020d2 | mon_cmd_m | `Memory sockets %d and %d have %s SIMMs installed (0x%x-0x%x)\n` |
| 010136cf | 0100211c | mon_cmd_m | `Memory sockets %d and %d (%s) have %s SIMMs installed (0x%x-0x%x)\n` |
| 01013712 | 010021ce | mon_cmd_e | `Old error code: %x\nLast error code: %x\n` |
| 0101373a | 01002264 | mon_cmd_fcode | `Function code %d (%s)\n` |
| 01013751 | 0100229e | mon_cmd_radix | `default input radix %d\n` |
| 0101376a |  |  | `uh?\n` |
| 0101376f | 010024c2 | mon_system_test_failed | `System\ntest\nfailed` |
| 01013782 | 01002530 | mon_password_check | `Password: ` |
| 0101378d | 0100257e | mon_password_check | `Sorry\n` |
| 01013794 | 010025c4 | mon_usage_error | `usage error, type "?" for help\n` |
| 010137cc | 01002852 | mon_param_bootcmd | `must be < %d chars long\n` |
| 010137ef | 01002a42 | mon_param_reset_bit | `There must be a disk inserted in drive #0 before you can set this option\n` |
| 01013853 | 01002c78 01003348 | mem_print_bad_sockets_nt | `\nDRAM error type %d\n` |
| 01013868 | 01002c86 | mem_print_bad_sockets_nt | `Check socket (0 is the first socket): ` |
| 01013893 | 01002ce6 01003386 | mem_report_error_nt | `\nMemory error at location: %x\n` |
| 010138b2 | 01002cf6 01003396 | mem_report_error_nt | `Value at time of failure: %x\n` |
| 010138d0 | 01002d5a 010033ea | mem_report_error_nt | `Coupling dependent memory fault!\n` |
| 010138f2 | 01002d78 | mem_report_error_nt | `One or more SIMM at memory bank %d is bad\n` |
| 0101391d | 01002d80 01003444 | mem_report_error_nt | `Note: bank 0 is the first bank\n` |
| 0101393d | 01002f7a | mem_config_test_nt | `Bank %d has mixed mode SIMM's\n` |
| 0101395c | 0100306c 01003848 | mem_config_test_nt | `All of the SIMMs must be parity SIMMs if you want parity to work.\n` |
| 0101399f | 01003358 | mem_print_bad_socket_t | `Check socket (0 is the first socket): %d\n\n` |
| 010139ca | 01003436 | mem_report_error_t | `One or both SIMMs in memory bank %d are bad\n` |
| 010139f7 | 010036d4 | mem_config_test_t | `Bank %d has mixed size SIMMs.\n` |
| 01013a16 | 01003c44 | vid_vram_test | `\nVRAM failure at 0x%x:  read 0x%08x, expected 0x%08x, bad bits %08x, IC U%d\n` |
| 01013a63 | 01003c6c | vid_vram_test | `VRAM failure at 0x%x:  read 0x%08x, expected 0x%08x, bad bits %08x, IC U%d\n` |
| 01013aaf | 01004a1a | post_scsi_dma_intr | `SCSI DMA intr?\n` |
| 01013abf | 010055f6 | post_snd_out_overrun_intr | `Sound Out Over Run Interrupt.\n` |
| 01013ade | 01005990 | post_snd_out_test | `\nSound Out DMA error!\n` |
| 01013af5 | 01005a88 | post_run_all | `Testing the FPU` |
| 01013b05 | 01005ab8 | post_ret_fpu | `, SCC` |
| 01013b0b | 01005ae8 | post_ret_scc | `, SCSI` |
| 01013b12 | 01005b0c | post_ret_scc | `, Enet` |
| 01013b19 | 01005b4a | post_ret_enet | `, ECC` |
| 01013b1f | 01005b74 | post_ret_ecc | `, RTC` |
| 01013b25 | 01005ba4 | post_ret_rtc | `, Timer` |
| 01013b2d | 01005bd4 | post_ret_timer | `, Event Counter` |
| 01013b3d | 01005c06 | post_ret_timer | `, Sound Out` |
| 01013b49 | 01005c40 | post_ret_timer | `\n\nStarting Extended Self Test...\n` |
| 01013b6b | 01005c4e | post_ret_timer | `Extended SCSI Test` |
| 01013b7e | 01005c7c | post_ret_ext_scsi | `\n\nPress and hold any key to exit self test` |
| 01013bab | 01005fde | ncc_cache_data_test | `\nCache RAM selftest failure\n` |
| 01013bc8 | 01005fee 010060b2 | ncc_cache_data_test | `Memory error at location: 0x%x\n` |
| 01013be8 | 01005ff8 | ncc_cache_data_test | `Value at time of failure: 0x%x\n` |
| 01013c08 | 01006004 010060c2 | ncc_cache_data_test | `Expected: 0x%x     Received: 0x%x\n` |
| 01013c2b | 010060a2 | post_cache_tag_test | `\nCache tag selftest failure.\n` |
| 01013c49 |  |  | `Loading\nfrom\ndisk ...` |
| 01013c5f |  |  | `Please\ninsert\ndisk` |
| 01013c72 |  |  | `Please\nflip\ndisk` |
| 01013c83 |  |  | `Bad\ndisk` |
| 01013c8c |  |  | `SCSI\nerror` |
| 01013c97 |  |  | `Loading\nfrom\nnetwork ...` |
| 01013cb0 |  |  | `Bad\nnetwork` |
| 01013cbc |  |  | `Loading\nfrom\nfloppy ...` |
| 01013cd4 |  |  | `Ethernet (try thin interface first)` |
| 01013cfb |  |  | `Ethernet (try twisted pair interface first)` |
| 01013d2a |  |  | `SCSI disk` |
| 01013d37 |  |  | `Optical disk` |
| 01013d44 |  |  | `Floppy disk` |
| 01013d50 | 010061b4 | boot_cmd | `Boot command: %s\n` |
| 01013d62 | 010061fc | boot_cmd | `Default boot device not found.\n` |
| 01013d8d | 010063de | boot_cmd_paren_check | `boot %s%s%s\n` |
| 01013d9a | 010065fc | boot_case_no_media | `diagnostics` |
| 01013da6 | 010066bc | boot_case_error | `Usage: b [device[(ctrl,unit,part)] [filename] [flags]]\n` |
| 01013dde | 010066c8 | boot_case_error | `boot devices:\n` |
| 01013df7 | 010069b2 | boot_load_image_header | `unknown binary format\n` |
| 01013e0e | 01006ab4 | tftp_load_kernel | `Booting %s from %s\n` |
| 01013e22 | 01006afa | tftp_load_kernel | `octet` |
| 01013e28 | 01006c0e | tftp_load_kernel | `\ntftp: %s\n` |
| 01013e49 | 01006dfa | tftp_load_kernel | `tftp: timeout\n` |
| 01013e58 | 01006ea8 | bootp_request | `Requesting BOOTP information` |
| 01013e75 | 01006ede | bootp_request | `from %s` |
| 01013e7d | 01006f2e | bootp_request | `[boot]\n` |
| 01013e85 | 01006f3a | bootp_request | `boot` |
| 01013e8f | 0100709c | bootp_request | ` [OK]\n` |
| 01013e96 | 010071d4 | bootp_request | ` [timeout]\n` |
| 01013ea2 | 0100770a | print_number | `0123456789abcdef` |
| 01013ebd | 01008da4 | enet_reg_read | `enreg_read failed \n` |
| 01013ed1 | 01008df4 | enet_reg_write | `enreg_write failed \n` |
| 01013eea | 0100937a 01009586 | enet_write | `en_write: tx not ready\n` |
| 01013f0b | 01009a58 | vid_draw_panel | `NeXT ROM Monitor %d.%d (v%d)` |
| 01013f28 | 0100a1e0 | kms_power_key_check | `\nreally power down? ` |
| 01013f3d | 0100ab90 | mon_boot_error | `Error during boot` |
| 01013f4f | 0100dbea | scsi_run_cmd | `Didn't complete` |
| 01013f5f | 0100dce0 | scsi_start | `scstart: bad state` |
| 01013f72 | 0100de1a | scsi_intr | `software error` |
| 01013f81 | 0100de2c | scsi_intr | `parity error` |
| 01013f8e | 0100de90 | scsi_intr_state6 | `selection failed` |
| 01013f9f | 0100deda | scsi_intr_dma_done | `bus error` |
| 01013fa9 | 0100deea | scsi_intr_status | `target aborted` |
| 01013fb8 | 0100df08 | scsi_intr_status | `fifo level` |
| 01013fc3 | 0100df26 | scsi_intr_msgin | `target aborted2` |
| 01013fd3 | 0100df4e | scsi_intr_msgin | `msgin fifo level` |
| 01013fe4 | 0100df74 | scsi_intr_bad_state | `scintr program error` |
| 01013ff9 | 0100dfda | scsi_phase_dispatch | `SCSI command phase` |
| 0101400c | 0100dfea 0100e064 | scsi_phase_data_out | `SCSI bad i/o direction` |
| 01014023 | 0100e106 | scsi_phase_msgout_err | `SCSI msgout phase` |
| 01014035 | 0100e134 | scsi_msgin_done | `scmsgin: no current sd` |
| 0101404c | 0100e148 | scsi_msgin_done | `SCSI unexpected msg:%d\n` |
| 01014064 | 0100e154 | scsi_msgin_done | `Unexpected msg` |
| 01014073 | 0100e164 | scsi_msgin_done | `scmsgin: no FUNCCMPLT` |
| 01014089 | 0100e196 | scsi_abort | `sc: %s\n` |
| 01014091 | 0100e26a | sd_open | `SCSI Bus Hung\n` |
| 010140a0 | 0100e272 | sd_open | `no SCSI disk\n` |
| 010140ae | 0100e286 | sd_open | `booting SCSI target %d, lun %d\n` |
| 010140ce | 0100e2c0 | sd_open | `dev blk len?\n` |
| 010140dc | 0100e47c | sd_read_capacity | `READ CAPACITY` |
| 010140ea | 0100e52c | sd_request_sense | `REQ SENSE` |
| 010140f4 | 0100e5bc | sd_start_unit_wait_ready | `waiting for drive to come ready` |
| 01014114 | 0100e68a | sd_read | `bad dev blk size %d\n` |
| 01014129 | 0100e708 | sd_read | `READ` |
| 0101412e | 0100e7d6 0100e88a | sd_command | `sdcmd bad state: %d\n` |
| 01014148 | 0100e83e | sd_print_error | `Selection timeout on target\n` |
| 01014165 | 0100e86c | sd_print_error | `Failed, sense key: 0x%x\n` |
| 0101417e | 0100e874 | sd_print_error | `Target busy\n` |
| 0101418b | 0100e892 | sd_print_error | `Target disconnected\n` |
| 010141a0 | 0100e8a0 | sd_print_error | `Driver refused command\n` |
| 010141b8 | 0100e8b6 | sd_print_error | `sdfail bad state: %d\n` |
| 010141ce | 0100ea78 | dma_cleanup | `dma_cleanup: negative resid` |
| 010141ea | 0100eaf6 | dma_start | `dma_start: bad DMA buffer alignment` |
| 0101420e | 0100ec90 | boot_fs_load | `Bad label\n` |
| 01014219 | 0100ecac | boot_fs_load | `No bootfile in label\n` |
| 0101422f | 0100ecde | boot_fs_load | `dev blk len %d, fs sect %d\n` |
| 0101424b | 0100ed16 | boot_fs_load | `Can't load blk0 boot\n` |
| 01014261 | 0100edf4 | boot_check_label | `Bad version 0x%x\n` |
| 01014273 | 0100ee16 | boot_check_label | `Bad blkno\n` |
| 0101427e | 0100ee36 | boot_check_label | `Bad cksum\n` |
| 01014289 | 0100ef38 | boot_exec_blk0 | `short read\n` |
| 01014295 |  |  | `uncorrectable ECC error` |
| 010142ad |  |  | `sector timeout` |
| 010142bc |  |  | `media upside down` |
| 010142ce |  |  | `no disk inserted` |
| 010142df |  |  | `PLL failed` |
| 010142ea |  |  | `retry` |
| 010142f0 |  |  | `restore` |
| 010142f8 |  |  | `re-spin` |
| 01014300 |  |  | `failed` |
| 01014307 | 0100f0b6 | od_ctrl_init | `no optical disk\n` |
| 01014318 | 0100f202 | od_volume_init | `no valid disk label found\n` |
| 01014333 | 0100f276 | od_open | `bad ctrl or unit number\n` |
| 0101434c | 0100fd30 | od_print_error | `read` |
| 01014351 | 0100fd40 | od_print_error | `write` |
| 01014357 | 0100fd50 | od_print_error | `erase` |
| 0101435d | 0100fd58 | od_print_error | `command` |
| 01014365 | 0100fd66 | od_print_error | `od%d%c: %s %s ` |
| 01014379 | 0100fd94 | od_print_error | `(error #%d)` |
| 0101438f | 01010414 | fd_probe_media | `fd: RECALIBRATE FAILED\n` |
| 010143a7 | 01010436 | fd_probe_media | `fd: CONTROLLER I/O ERROR\n` |
| 010143c1 | 0101052a | fd_probe_media | `RECALIBRATE FAILED\n` |
| 010143d5 | 0101061a | fd_open | `No Floppy Disk Drive\n` |
| 010143eb | 01010622 | fd_open | `No Floppy Disk Present\n` |
| 01014403 | 0101062a | fd_open | `Floppy Disk not Formatted\n` |
| 0101441e | 01010632 | fd_open | `Unknown Floppy Disk error (%d)\n` |
| 0101443e | 0101064e | fd_open | `Floppy Disk not Initialized\n` |
| 0101445b | 010108cc | fd_intr_ok | `fd_intr: BOGUS fvp->state` |
| 01014475 | 01010956 01010970 | fd_intr_error | `FATAL` |
| 0101447b | 01010900 | fd_intr_error | `RECALIBRATE` |
| 01014487 | 01010928 01010968 | fd_intr_error | `RETRY` |
| 01014493 |  |  | `rite` |
| 01014498 | 010109b8 | fd_print_error | `fd%d: Sector %d(d) cmd = %s; status = %d: %s\n` |
| 010144c6 | 01010fd0 | fc_start_type5 | `Bad Controller Phase` |
| 010144db | 01010fec | fc_start_type5 | `Controller hang` |
| 010144eb | 010110ee | fc_reset | `fc: Controller Reset: %s\n` |
| 01014505 | 01011440 | fc_specify | `fd: Bogus density (%d) in fc_specify()\n` |
| 0101452d | 010117ce | fc_send_cmd | `fc_send_cmd: Error sending command bytes  (%d)\n` |
| 0101455d | 0101192e | fc_cmd_result_phase | `fc_send_cmd: Error getting status bytes\n` |
| 01014586 | 01011b56 | dma_bytes_moved | `dma_bytes_moved: DMA buf overflow` |
| 01014aef |  |  | `!ddP<<FPd` |
| 01014cd8 | 01002c3c | mon_print_help | `NeXT ROM monitor commands:\n\tp  inspect/modify configuration parameters\n\ta [n]  open address register\n\tm  print memory configuration\n\td [n]  open data register\n\tr [regname]  open processor register\n\ts [systemreg]  open system register\n\te [lwb] [alist] [format]  examine memory location addr\n\tec  print recorded system error codes\n\tej [drive #]  eject optical disk (default = 0)\n\teo  (same as above)\n\tef [drive #]  eject floppy disk (default = 0)\n\tc  continue execution at last pc location\n\tb [device[(ctrl,unit,part)] [filename] [flags]]  boot from device\n\tS [fcode]  open function code (address space)\n\tR [radix]  set input radix\nNotes:\n\t[lwb] select long/word/byte length (default = long).\n\t[alist] is starting address or list of addresses to cyclically examine.\n\tExamine command, with no arguments, uses last [alist].\nCopyright (c) 1988-1990 NeXT Inc.\n\n` |
| 01015657 |  |  | `P+PO` |
| 01015671 |  |  | `PNQ:S:Q$` |
| 0101572f |  |  | `PM8(A` |
| 01015768 |  |  | `PIA)8` |
| 010157a1 |  |  | `EG)8` |
| 010157c6 |  |  | `)PNQ$` |
| 010158e9 |  |  | `PNQ:QF` |
| 010159ac |  |  | `JP=QLPK` |
| 010159f6 |  |  | `K F 4(IK` |
| 01015b57 |  |  | `:@PN` |
| 01015be3 |  |  | `QJP8)POPK` |
| 01015bf4 |  |  | `7OPN)NM:JF` |
| 01015c25 |  |  | `)PN7A` |
| 01015c75 |  |  | `;PNF` |
| 01015c91 |  |  | `:PNF` |
| 01016d3b |  |  | `rcN\Y$NTuJ!` |
| 01016eb9 |  |  | `+mMuV\z$V` |
| 01017341 |  |  | `UDDA` |
| 01017387 |  |  | `@@DDA` |
| 010175d6 |  |  | `UUUD` |
| 01017fef |  |  | `i##[c i 8iUkcD c""3Fc8` |
| 0101820e |  |  | `U !;mi'` |
| 01018939 |  |  | `vea&` |
| 0101a890 | 01007d74 01007d90 | parse_number | `0123456789abcdef` |
| 0101ae8c |  |  | `PP  ` |
| 0101aeae |  |  | `PP    ` |
| 0101b00c |  |  | `PP  ` |
| 0101b340 | 0100f1e0 010100d2 | od_volume_init | `Canon OMD-1` |
| 0101b3d4 | 01011148 010114ee | fc_reset | `Sony MPX-111N` |
