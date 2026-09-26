# Subroutines

664 routines reached by the descent.  `callers` counts bsr/jsr sites; `ptr` = entries in ROM pointer tables; `seed` = how the routine was first reached (reset, ptr = pointer table, prologue = `link a6` after `rts`, known = named entry).

| address | label | size | seed | callers | ptr | calls | strings referenced | devices touched | note |
|---|---|---:|---|---:|---:|---:|---|---|---|
| 0100001e | reset_entry | 36 | reset | 1 | 3 | 0 |  | BMAP chip (non-Turbo) | reset vector target (ROM offset 4) |
| 01000042 | reset_bmap_cacr_setup | 32 | known | 0 | 1 | 0 |  | BMAP chip (non-Turbo) | non-Turbo only: cacr=$8000, BMAP+4=$C7000000, then BMAP DRAM sizing loc_01000992 (a5=cont) |
| 01000062 | reset_bmap_finish | 48 | known | 0 | 1 | 0 |  | BMAP chip (non-Turbo), System Control Register 1, System Control Register 2 | non-Turbo: BMAP+$C=$80000000, +$38=$E1000000, +0=slot id, SCR2\|=$800; falls into NCC probe |
| 01000092 | reset_probe_ncc | 30 |  | 0 | 1 | 0 |  | NCC | bus-error target on Turbo (no BMAP): vbr=table2, write NCC+0=0; d2=$2000 if NCC present |
| 010000b0 | reset_machine_dispatch | 206 |  | 0 | 1 | 0 |  | System Control Register 1, Turbo Memory Controller | isp=SCR1(\|d2), re-read $02200000 when type==4, msp=type; branch per machine type |
| 0100017e | reset_cube030_setup | 116 |  | 0 | 0 | 0 |  | Channel Ethernet Receive, System Control Register 2, device space mirror of $020 | type 0: cacr=$19, SCR2\|=$1800, AT&T enet init bytes from dat_01014af8 -> $02106010..14 |
| 010001f2 | reset_nonturbo040_setup | 14 |  | 0 | 0 | 0 |  |  | types 1,2: BMAP $30/$34=$40000000 if cpu speed field==0, enet init bytes -> $02106010 |
| 01000200 | reset_nonturbo040_bmap | 122 |  | 0 | 7 | 0 |  | BMAP chip (non-Turbo), Channel Ethernet Receive, device space mirror of $0200601 | part of reset_nonturbo040_setup (jump-table target) |
| 0100027a | reset_color_station_setup | 44 |  | 0 | 0 | 0 |  | BMAP chip (non-Turbo), System Control Register 2, device space mirror of $020181 | type 3: BMAP+$C=$C0000000, $02118190=$0A, $02118180=0, SCR2\|=$80 |
| 010002a6 | reset_turbo_setup | 14 |  | 0 | 0 | 0 |  |  | types 4-B: cinva, MMU transparent (loc_01000c68), then tmc_reset_config |
| 010002b4 | tmc_reset_config | 280 | known | 0 | 1 | 0 |  | System Control Register 2, Turbo Memory Controller | TURBO: cacr=$8000; TMC ctrl $02200010 from SCR1 speed bits; ADB mask/config=0; TMC H/V timing |
| 010003cc | reset_int_mask_crc | 36 |  | 0 | 0 | 0 |  | Interrupt Status and Mask Registers | int mask $02007800=0; CRC-32 of ROM body then header (loc_0100418e); error code in a0 |
| 010003f0 | reset_crc_stage2 | 46 | known | 0 | 1 | 0 |  |  | compare body CRC with header +$1A (err 1), then CRC bytes 0..21 |
| 0100041e | reset_pick_stack | 164 | known | 0 | 1 | 0 |  | device space | compare header CRC (err 2); choose VRAM stack (mono) or DRAM bank probe (colour types 3,5,7,9,B) |
| 010004c2 | reset_probe_vram_stack | 14 |  | 0 | 0 | 0 |  |  | mono: a7=VRAM base, probe 256 KB via loc_01003ca4 (err 3), cont sub_010004d0 |
| 010004d0 | reset_mg_in_vram | 56 | known | 0 | 1 | 1 |  | System Control Register 1 | mono: mg at VRAM+$3F800, vbr=mg+$400, mg_sid, mg_machine_type, set mg ptr |
| 01000508 | reset_probe_dram_stack | 12 |  | 0 | 0 | 0 |  |  | colour: loc_01003dfc finds first working 32 MB bank (err 5), cont sub_01000514 with a0=bank |
| 01000514 | reset_mg_in_dram | 66 | known | 0 | 1 | 2 |  | System Control Register 1 | colour/TURBO COLOR: mg at bank+$800, vbr=mg+$400, mg_sid/type, set mg ptr, sub_01003a9c(0) |
| 01000556 | reset_install_vectors | 88 |  | 0 | 1 | 4 |  |  | d2=sub_01005cd2() (nvram TEST_DRAM), all 256 vectors=exc_common_entry, sub_0100ac8a, test panel, push $700 frame |
| 010005ae | exc_common_entry | 166 |  | 0 | 43 | 1 |  |  | every vector: save d0-d7/a0-a7,usp,sfc,dfc,vbr,cacr in $84-byte frame, sr=$2700, cacr=$8000, call exc_dispatch, rte |
| 01000654 | mon_reenter_704 | 12 | known | 0 | 2 | 0 |  |  | called on the new monitor stack: MMU transparent then sub_01000660 |
| 01000660 | mon_reenter_704_frame | 26 | known | 0 | 1 | 0 |  |  | vbr=arg, push fake frame vector $704 (PC=$04000000) and enter exc_common_entry |
| 0100067a | mg_set_ptr | 12 |  | 5 | 3 | 0 |  |  | store arg (mg pointer) at vbr+4 (unused vector slot 1) |
| 01000686 | mg_get_ptr | 10 |  | 123 | 2 | 0 |  |  | return mg pointer from vbr+4 |
| 01000690 | cpu_get_vbr | 6 |  | 9 | 0 | 0 |  |  | d0 = vbr |
| 01000696 | cpu_set_vbr | 10 |  | 2 | 2 | 0 |  |  | vbr = arg |
| 010006a0 | cpu_get_ipl | 12 |  | 1 | 0 | 0 |  |  | d0 = (sr>>8)&7 |
| 010006ac | mon_call_on_stack | 72 |  | 3 | 0 | 0 |  |  | switch a7 to arg0, copy 15 longs of args, jsr arg1 (used for kernel entry and $704 re-entry) |
| 010006f4 | mon_return_trap | 6 |  | 0 | 2 | 0 |  |  | return address given to booted program: pushes fake vector $600 frame, enters exc_common_entry |
| 010006fa | mon_return_trap_frame | 20 |  | 0 | 1 | 0 |  |  | second half of mon_return_trap |
| 0100070e | cpu_moves_read_long | 26 | known | 0 | 2 | 0 |  |  | moves.l (addr) with sfc=arg2 |
| 01000728 | cpu_fc_read_word | 26 | known | 0 | 1 | 0 |  |  | read word from addr with sfc=arg2 (plain move.w, not moves) |
| 01000742 | cpu_moves_read_byte | 28 | known | 0 | 1 | 0 |  |  | moves.b (addr) with sfc=arg2 |
| 0100075e | cpu_moves_write_long | 30 | known | 0 | 2 | 0 |  |  | moves.l val,(addr) with dfc=arg2 |
| 0100077c | cpu_moves_write_word | 30 | known | 0 | 1 | 0 |  |  | moves.w val,(addr) with dfc=arg2 |
| 0100079a | cpu_moves_write_byte | 30 | known | 0 | 1 | 0 |  |  | moves.b val,(addr) with dfc=arg2 |
| 010007c6 | bf_insert | 28 |  | 1 | 0 | 0 |  |  | bfins d0,(a0){1:2} helper (args: value, addr, ...) |
| 010007e2 | bf_extract | 18 |  | 1 | 0 | 0 |  |  | bfextu (a0){0:1} helper |
| 010007f4 | mem_bmap_addr_scan | 238 |  | 0 | 5 | 0 |  |  | pre-stack helper: find address bits where BMAP probe (a6/a7) matches d2 pattern; result d0/d1, jmp (a4) |
| 010008e2 | mon_enter_from_os | 78 | known | 0 | 1 | 0 |  | BMAP chip (non-Turbo) | mg+$3AA callback: save sp,tc,cacr,itt/dtt at vbr+$100.., MMU transparent, then sub_01000930 |
| 01000930 | mon_enter_from_os_2 | 22 | known | 0 | 1 | 0 |  |  | cacr=$8000, re-run BMAP DRAM sizing (non-Turbo) with cont sub_01000946 |
| 01000946 | mon_enter_from_os_restore | 76 | known | 0 | 1 | 0 |  | BMAP chip (non-Turbo) | restore tc/itt/dtt/cacr/sp saved at vbr+$100.., pop BMAP+4, rts to OS caller |
| 01000992 | mem_bmap_size_dram | 76 |  | 0 | 2 | 0 |  | BMAP chip (non-Turbo) | NON-TURBO: BMAP register programming and DRAM bank sizing using move16 probes (a5=cont) |
| 010009de | mem_bmap_size_dram_2 | 60 | known | 0 | 1 | 0 |  | BMAP chip (non-Turbo) | stage 2 of mem_bmap_size_dram |
| 01000a1a | mem_bmap_size_dram_3 | 84 | known | 0 | 1 | 0 |  | BMAP chip (non-Turbo) | stage 3: choose BMAP+$1C mode, scan banks writing BMAP+$18 |
| 01000a6e | mem_bmap_size_dram_4 | 320 | known | 0 | 1 | 0 |  | BMAP chip (non-Turbo), System Control Register 1 | stage 4: bank walk with BMAP+$18/$20/$14 probes, finish with jmp (a5) |
| 01000bae | mem_bmap_size_dram_5 | 86 | known | 0 | 1 | 0 |  | BMAP chip (non-Turbo) | stage 5 (alternate sizing path, BMAP+$1C=$90000000) |
| 01000c04 | mem_bmap_size_dram_6 | 36 | known | 0 | 1 | 0 |  | BMAP chip (non-Turbo) | stage 6: BMAP+$18 final, BMAP+$1C=$B0000000, jmp (a5) |
| 01000c68 | mmu_transparent_setup | 50 |  | 0 | 4 | 0 |  | System Control Register 1 | tc=0, itt1/dtt1=$00FFC000 (all, cacheable), itt0/dtt0=$0200C040 (device, serialized), tc=$C000, jmp (a0) |
| 01000c9c | mg_init_machine | 200 |  | 4 | 0 | 0 |  | BMAP chip (non-Turbo), System Control Register 1, Turbo Memory Controller | zero km/addr, fmt='l', radix 16, sid, dmachip=$139 for types 0-2, BMAP/NCC ptrs per type, nvram read or default |
| 01000d64 | mg_init_type1 | 8 | known | 0 | 1 | 0 |  |  | type 1 (station mono): is_station=1, simm_type=0 |
| 01000d6c | mg_init_type0_2 | 14 | known | 0 | 2 | 0 |  |  | types 0,2 (cubes): is_station=0, simm_type=0, sockets=0 |
| 01000d7a | mg_init_type3 | 12 | known | 0 | 1 | 0 |  |  | type 3 (colour station): is_station=1, simm_type=1, sockets=2 |
| 01000d86 | mg_init_type6_7 | 16 | known | 0 | 2 | 0 |  | NCC | types 6,7: NCC $02210000 + tag RAM $03E00000 pointers, then as types 4,5 |
| 01000d96 | mg_init_type4_5 | 22 |  | 0 | 2 | 0 |  |  | TURBO STATION (4,5): is_station=1, simm_type=1, sockets=2, mg_sid=0 |
| 01000dac | mg_init_typeA_B | 16 | known | 0 | 2 | 0 |  | NCC | types A,B: NCC pointers then as types 8,9 |
| 01000dbc | mg_init_type8_9 | 114 |  | 0 | 2 | 3 |  |  | types 8,9 (Turbo cube): is_station=0, simm_type=1, sockets=2 |
| 01000e2e | mon_show_test_panel | 152 |  | 1 | 1 | 3 | "Testing\nsystem ..." |  | if nvram POT&$11: mg_init_machine, draw panel + 'Testing system ...'; returns $80 (mg_flags) else 0 |
| 01000ec6 | mon_init | 2486 |  | 2 | 0 | 22 | "Main Memory Configuration Test F"; "Main Memory Test Failed\n\n"; "VRAM" | Interrupt Status and Mask Registers, NCC, System Control Register 1, Turbo Memor | C init: int reg ptrs, callbacks, DRAM sizing/tests, NCC, banner, nvram SIMM check, relocate mg, ADB init, POST |
| 0100187c | fd_pick_default_boot | 88 |  | 1 | 0 | 1 |  | Floppy Controller (Intel 82077AA), Floppy External Control | if bootcmd=='FD': select 82077, DOR=0 then $14; status bit2 (no drive) -> 'en' else 'fd' |
| 010018d4 | exc_dispatch | 1148 |  | 1 | 0 | 21 | "No default boot command.\n"; "\nparity error: status 0x%x, add" | System Control Register 2, Turbo Memory Controller, device space mirror of $0200 | C exception/monitor dispatcher: $700 first init, $704 device init+boot, $7C NMI/parity, $B4 trap13, else print |
| 01001d50 | exc_nofault_skip6word | 6 | known | 0 | 2 | 0 |  |  | nofault resume: sp += 4 for 6-word frames (format 2,3) |
| 01001d56 | exc_nofault_skip_fmt7 | 8 | known | 0 | 1 | 0 |  |  | nofault resume: sp += $34 for format 7 (bus error) frames |
| 01001d5e | exc_nofault_bogus | 20 |  | 0 | 3 | 1 | "bogus stack frame\n" |  | prints 'bogus stack frame' for frame formats 4-6 |
| 01001d72 | exc_nofault_resume | 102 |  | 0 | 2 | 0 | "Exception #%d (0x%x) at pc 0x%x "; "faultaddr 0x%x\n" |  | PC = mg_nofault, clear it, return (rte resumes in handler) |
| 01001dd8 | mon_command_loop | 288 |  | 0 | 0 | 4 |  |  | 'NeXT> ' prompt: read line, password gate (nvram byte2 bits 2-5 == 6), dispatch via table dat_01011c40 |
| 01001ef8 | mon_cmd_password | 224 | known | 0 | 1 | 5 | "New password:"; "Retype new password:"; "Mismatch - password unchanged\n" |  | 'P': read/retype 16-char password, store 6 bytes xor $4E at nvram+4, set mode 6, write nvram |
| 01001fd8 | mon_cmd_boot | 38 | known | 0 | 1 | 1 |  |  | 'b': boot_arg=rest of line, boot_how=2, re-enter via mon_reenter_704 on monitor stack |
| 01001ffe | mon_cmd_aregs | 20 | known | 0 | 1 | 0 |  |  | 'a': address-register display/modify (continues at loc_0100218a) |
| 01002012 | mon_cmd_d | 20 | known | 0 | 1 | 0 |  |  | 'd [n]': edit saved d0-d7 in the exception frame via param table sub_010145c8, prefix 'd' |
| 01002026 | mon_cmd_r | 20 | known | 0 | 1 | 0 |  |  | 'r [reg]': edit saved processor regs (pc, sr, usp...) via table sub_01014730 |
| 0100203a | mon_cmd_m | 256 | known | 0 | 1 | 1 | "Memory sockets %d-%d have %s SIM"; "Memory sockets %d and %d have %s"; "back" |  | 'm': print memory configuration from mg_simm[4] + mg_region[4]; 4-socket or SIMM-pair wording by mg+$3ba |
| 0100213a | mon_cmd_p | 46 | known | 0 | 1 | 2 |  |  | 'p': edit NVRAM parameters (table sub_010148c0, base mg_nvram); writes NVRAM back if changed |
| 01002168 | mon_cmd_s | 34 | known | 0 | 1 | 0 |  |  | 's [sysreg]': edit intrstat/intrmask/scr1/scr2; table 010147f8 if non-Turbo else 0101485c |
| 0100218a | mon_cmd_regs_common | 16 |  | 0 | 0 | 1 |  |  | shared tail of a/d/r commands: mon_param_edit_table(args, table, frame, prefix) |
| 0100219a | mon_cmd_e | 160 | known | 0 | 1 | 3 | "Old error code: %x\nLast error c" |  | 'e': ec=print NVRAM error codes 15/16, ef/ej/eo=eject, else examine memory with fcode d3 |
| 0100223a | mon_cmd_fcode | 62 | known | 0 | 1 | 2 | "Function code %d (%s)\n" |  | 'S [fcode]': set monitor function code d3 (0..7), prints 'Function code %d (%s)' |
| 01002278 | mon_cmd_radix | 56 | known | 0 | 1 | 2 | "default input radix %d\n" |  | 'R [radix]': set mg+$192 default input radix (byte), prints it |
| 010022b0 | mon_cmd_help | 10 | known | 0 | 2 | 1 |  |  | '?'/'h': print the monitor help text |
| 010022ba | mon_cmd_huh | 18 |  | 0 | 39 | 1 |  |  | unknown command: prints 'Huh?' |
| 010022cc | mon_cmd_continue | 10 |  | 0 | 1 | 0 |  |  | 'c': restore d2-d6/a2-a5, unlk, rts = continue at last pc |
| 010022d6 | mem_build_regions | 164 |  | 1 | 0 | 0 |  | device space | fill mg_region[4] {base,size} at mg+$c8 from mg_simm codes; stride 16/8/32 MB, size table by class |
| 0100237a | mon_probe_read_byte | 48 |  | 2 | 0 | 1 |  |  | *dst=*src byte with bus-error catch via mg+$1a4; returns 1 ok, 0 on bus error |
| 010023aa | mon_probe_read_byte_fail | 14 |  | 0 | 1 | 0 |  |  | bus-error continuation of mon_probe_read_byte: clear mg+$1a4, return 0 |
| 010023b8 | mon_probe_write_byte | 62 |  | 1 | 0 | 1 |  |  | *dst=val byte with bus-error catch via mg+$1a4; returns 1 ok, 0 on bus error |
| 010023f6 | mon_probe_read_long | 48 |  | 3 | 0 | 0 |  |  | (mg, addr): read long with bus-error catch; 1 ok, 0 on bus error or mg==0 |
| 01002426 | mon_print_warning | 60 |  | 3 | 0 | 2 |  |  | set mg+$170 bit3/clear bit0 (once) then printf(str) |
| 01002462 | mon_system_test_failed | 148 |  | 7 | 0 | 4 | "System\ntest\nfailed" |  | draw icons + 'System test failed' text; if arg!=0 loop forever in power-key handler |
| 010024f6 | mon_password_check | 202 |  | 7 | 0 | 4 | "Password:"; "Sorry\n" |  | (force): ask 'Password: ' if NVRAM pw field==6 and not authenticated; 1=allowed, 0='Sorry' |
| 010025c0 | mon_usage_error | 20 |  | 1 | 0 | 1 | "usage error, type "?" for help\n" |  | print usage error message |
| 010025d4 | mon_led_blink | 90 |  | 1 | 0 | 1 |  | System Control Register 2 | (n): blink SCR2 LED (bit0 of $0200D000) n times, 1M-iteration delay per phase |
| 01002630 | mon_param_edit_table | 286 |  | 2 | 0 | 6 |  |  | (line, table, base, prefix): interactive show/modify loop over 20-byte param entries; ret 1 if changed |
| 0100274e | mon_param_sysreg | 148 | known | 0 | 10 | 3 |  | System Control Register 1, Turbo Memory Controller | param handler: %b print / hex store of a system register; SCR1 redirected to TMC $02200000 on Turbo |
| 010027e2 | mon_param_bootcmd | 154 | known | 0 | 1 | 4 | "must be < %d chars long\n" |  | param handler for boot command string at nvram+$12, max 12 chars, '.' clears |
| 0100287c | mon_param_pot_bit | 158 | known | 0 | 6 | 2 |  |  | param handler: yes/no bit in NVRAM byte 14 (POT byte), mask = entry+4 |
| 0100291a | mon_param_parity | 144 | known | 0 | 1 | 2 |  |  | param handler: yes/no bit2 of NVRAM byte 17 (USE_PARITY_MEM) |
| 010029aa | mon_param_reset_bit | 190 | known | 0 | 4 | 3 | "There must be a disk inserted in" |  | param handler: yes/no bit in NVRAM long 0 (ni_reset); eject bit needs disk in drive 0 |
| 01002a68 | mon_examine_memory | 462 |  | 1 | 0 | 5 |  |  | 'e [lwb] [alist] [fmt]': cyclic examine/modify up to 8 addrs via moves with fcode; list at mg+$1aa |
| 01002c38 | mon_print_help | 26 |  | 1 | 0 | 1 | "NeXT ROM monitor commands:\n\tp " |  | printf('%s', help text at $01014cd8) |
| 01002c54 | mem_print_bad_sockets_nt | 126 |  | 1 | 0 | 1 | "\nDRAM error type %d\n"; "Check socket (0 is the first soc" |  | (addr, pattern, &val, type): 'DRAM error type %d' + socket list bank*4+3-lane (non-Turbo) |
| 01002cd2 | mem_report_error_nt | 192 |  | 2 | 0 | 1 | "\nMemory error at location: %x\n"; "Value at time of failure: %x\n"; "Coupling dependent memory fault!" |  | (addr): print memory error, retest 55/AA, name bad sockets or 'Coupling dependent memory fault' |
| 01002d92 | mem_bank_present_nt | 44 |  | 1 | 0 | 0 |  |  | (base): clear 8 longs, read each twice; 1 if all read 0 (RAM present) |
| 01002dbe | mem_bank_size_nt | 102 |  | 1 | 0 | 0 |  |  | (base): alias test at +4MB/+1MB; returns SIMM code 5=16MB,6=4MB,7=1MB page mode, 0=bad |
| 01002e24 | mem_write_read_long | 40 |  | 3 | 0 | 0 |  |  | (addr): write 12345678/EDCBA987, cpusha, 1 if first long reads back |
| 01002e4c | mem_config_test_nt | 752 |  | 1 | 0 | 9 | "Bank %d has mixed mode SIMM's\n"; "All of the SIMMs must be parity " | System Control Register 1, System Control Register 2, device space mirror of $02 | non-Turbo DRAM sizing: SCR2 bits 16+i/20+i per bank, fills mg_simm, BMAP parity probe; 0/1/2 |
| 0100313c | mem_pattern_test_nt | 232 |  | 1 | 0 | 2 |  |  | (base,size): 3 passes of DB6DB6DB,0,0 triple fill+verify, then 4 byte lanes; ret bad addr or 0 |
| 01003224 | mem_test_all_nt | 186 |  | 1 | 0 | 5 |  | device space | non-Turbo full DRAM test: LED on, caches off, mem_pattern_test_nt per bank, report errors |
| 010032e0 | mem_print_bad_socket_t | 138 |  | 1 | 0 | 1 | "\nDRAM error type %d\n"; "Check socket (0 is the first soc" | device space | (addr,type): 'DRAM error type %d', 'Check socket %d' = bank*2 + (addr&4?1:0) |
| 0100336a | mem_report_error_t | 236 |  | 3 | 0 | 3 | "\nMemory error at location: %x\n"; "Value at time of failure: %x\n"; "Coupling dependent memory fault!" | device space | (addr): print memory error, retest 55/AA, socket or 'One or both SIMMs in memory bank %d are bad' |
| 01003456 | mem_pattern_test_t | 232 |  | 1 | 0 | 2 |  |  | (base,size): same as mem_pattern_test_nt but 8 byte lanes (SIMM pair); ret bad addr or 0 |
| 0100353e | mem_bank_absent_t | 90 |  | 1 | 0 | 0 |  |  | (base): write 55555555,AAAAAAAA x3 to 16 bytes; returns 1 if readback differs (bank empty) |
| 01003598 | mem_bank_size_t | 130 |  | 2 | 0 | 1 |  |  | (addr): alias test at +8MB/+2MB; code 1=32MB pair,2=8MB,3=2MB (type3: 2=8MB_C), 0=bad |
| 0100361a | mem_config_test_t | 930 |  | 1 | 0 | 10 | "Bank %d has mixed size SIMMs.\n"; "All of the SIMMs must be parity " | Turbo Memory Controller, device space, device space mirror of $02018190 = Serial | Turbo DRAM sizing per bank (32MB stride, +0/+4 pair), parity probe, TMC ctrl bits 10/3; ret 0/1/2 |
| 010039bc | mem_test_all_t | 224 |  | 1 | 0 | 3 |  | device space | Turbo full DRAM test: caches off, mem_pattern_test_t per bank (skips stack page), report errors |
| 01003a9c | vid_vram_test | 488 |  | 1 | 1 | 6 | "\nVRAM failure at 0x%x:  read 0x"; "VRAM failure at 0x%x:  read 0x%0" |  | (quiet): test 2MB VRAM ($0C000000 Turbo/$2C000000 type3) mask FFF0FFF0; blinks LED, prints failure |
| 01003c84 | vid_vram_probe_fill | 32 |  | 0 | 0 | 0 |  |  | pre-stack helper: fill [a2,a3) with d1, verify, d0=bad addr or 0, jmp (a4) |
| 01003ca4 | vid_vram_probe | 62 |  | 0 | 0 | 0 |  | System Control Register 2 | reset: LED on, cacr=$8000, test 256KB at a0 with AA/55/incrementing; fail -> LED code 3 halt |
| 01003ce2 | vid_vram_probe_pass2 | 26 | known | 0 | 1 | 0 |  |  | continuation: 55555555 pass |
| 01003cfc | vid_vram_probe_pass3 | 78 | known | 0 | 1 | 0 |  | System Control Register 2 | continuation: incrementing-long pass, then restore cacr, LED off, jmp (a6) |
| 01003d4a | mem_burst_test_nt | 116 |  | 2 | 0 | 0 |  |  | (base): 4-long pattern, caches on ($80008000), line-fill readback; 1 ok; leaves cacr=$8000 |
| 01003dbe | mem_berr_parity_nt | 14 | known | 0 | 1 | 0 |  | BMAP chip (non-Turbo) | temp bus-error vector for non-Turbo parity probe: BMAP+8=0, rte |
| 01003dcc | mem_dram_probe_fill | 48 |  | 0 | 0 | 0 |  |  | pre-stack helper: fill [a2,a3) with d1 (dbra), verify, jmp (a4) |
| 01003dfc | mem_dram_probe | 96 |  | 0 | 0 | 0 |  |  | reset (colour types): find first bank whose first 8KB passes 55/AA, DB6DB6DB, ~, incr; a0=bank, jmp (a7) |
| 01003e5c | mem_dram_probe_pass2 | 26 | known | 0 | 1 | 0 |  |  | continuation: inverted pattern pass |
| 01003e76 | mem_dram_probe_pass3 | 40 | known | 0 | 1 | 0 |  |  | continuation: incrementing pass; success -> jmp (a7) |
| 01003e9e | mem_dram_probe_next | 20 |  | 0 | 0 | 0 |  |  | advance a0 by stride d3 until a6; none works -> LED code 5 halt |
| 01003eb2 | mem_parity_probe_nt | 28 |  | 1 | 0 | 0 |  | BMAP chip (non-Turbo) | (base): BMAP+8=$80000000 (parity on), write patterns, result = BMAP+8 bit31 still set |
| 01003ece | mem_parity_probe_nt_done | 26 | known | 0 | 1 | 0 |  | BMAP chip (non-Turbo) | tail: d0 = BMAP+8 & $80000000, BMAP+8 = 0, restore a2, rts |
| 01003ee8 | mem_parity_probe_t | 28 |  | 1 | 0 | 0 |  | Turbo Memory Controller | (base): TMC ctrl \|= $400 (parity on), write patterns; unlabeled entry called from $01003806 |
| 01003f04 | mem_parity_probe_t_done | 26 | known | 0 | 1 | 0 |  | Turbo Memory Controller | tail: d0 = TMC ctrl & $400 (0 if NMI handler cleared it), then clear bit 10, rts |
| 01003f1e | mem_parity_probe_body | 118 |  | 0 | 2 | 0 |  |  | write 16B of 0, 16B of 01010101, 32 bytes with odd-parity byte pattern, read back, jmp (a2) |
| 01003f94 | mem_berr_parity_vec_nt | 14 | known | 0 | 1 | 0 |  | BMAP chip (non-Turbo) | vector 2 of temp table mem_vectors_nt: BMAP+8=0, rte |
| 01003fa2 | mem_nmi_parity_vec_t | 32 | known | 0 | 1 | 0 |  | Turbo Memory Controller | vector 31 (level-7 NMI) of mem_vectors_t: TMC $02200004=0, TMC ctrl &= ~$400, rte |
| 01003fc2 | mem_vectors_nt | 174 | known | 0 | 1 | 0 |  |  | DATA: 12-entry vector table (all $010005ae, entry 2 = mem_berr_parity_vec_nt) used as VBR by type 3 |
| 01004072 | tmc_parity_init_range | 54 |  | 1 | 0 | 0 |  | Turbo Memory Controller | rewrite longs a0..a1 with TMC ctrl bit10 set per word; leaves bit10 set. Turbo only. args: start,end |
| 010040a8 | cache_push_data | 4 | known | 0 | 2 | 0 |  |  | cpusha dc: push dirty data cache lines |
| 010040ac | cache_inval_set_cacr | 16 |  | 10 | 0 | 0 |  |  | cinva both caches, set CACR from arg; returns old CACR in d0 |
| 010040bc | cache_get_cacr_push | 8 |  | 9 | 0 | 0 |  |  | d0 = CACR, then cpusha dc |
| 010040c4 | led_on | 18 |  | 1 | 0 | 0 |  | System Control Register 2 | SCR2 \|= 1 (SCR2_LED) via displacement arg (normally 0) |
| 010040d6 | led_off | 18 |  | 1 | 0 | 0 |  | System Control Register 2 | SCR2 &= ~1 (SCR2_LED) via displacement arg (normally 0) |
| 010040e8 | led_blink_halt | 4 |  | 1 | 0 | 0 |  |  | C entry: blink LED $4(a7) times, long pause, repeat forever (never returns) |
| 010040ec | led_blink_loop | 86 |  | 0 | 2 | 0 |  | System Control Register 2 | asm entry, a0 = blink count: SCR2 LED on/off n times, pause, loop forever |
| 01004142 | snd_out_clear_underrun | 20 | known | 1 | 0 | 0 |  | Monitor/Soundbox (Keyboard, Mouse, Sound) | KMS_Ctrl_Snd \|= $20 (SNDOUT_DMA_UNDERRUN) with ints off; Turbo version |
| 01004156 | snd_out_clear_underrun_wait | 56 | known | 1 | 0 | 0 |  | Monitor/Soundbox (Keyboard, Mouse, Sound) | wait KMS TX bit6 while SNDOUT enabled, then KMS_Ctrl_Snd \|= $20; non-Turbo |
| 0100418e | crc32_calc_asm | 84 |  | 0 | 0 | 0 |  | System Control Register 2 | CRC-32 poly $04C11DB7 of d3 bytes at a1, LED on during calc, result d0, jmp (a0) |
| 010041e2 | crc32_calc | 28 | known | 0 | 0 | 0 |  |  | C wrapper: crc32(buf $8(a6), len $c(a6)); continuation at $010041fe, d0 = CRC |
| 010041fe | crc32_calc_ret | 8 | known | 0 | 1 | 0 |  |  | continuation of crc32_calc: restore regs, unlk, rts |
| 01004208 | vid_span_2bpp | 108 | known | 0 | 1 | 1 |  |  | expand run of 2bpp pixels (byte val, count) into 2bpp framebuffer via mg+$33c lut |
| 01004274 | vid_span_8bpp | 128 | known | 0 | 1 | 1 |  |  | expand run of 2bpp pixels into 8bpp framebuffer (byte per pixel) via mg+$33c lut |
| 010042f4 | vid_span_16bpp | 132 | known | 0 | 1 | 1 |  |  | expand run of 2bpp pixels into 16bpp framebuffer (word per pixel) via mg+$33c lut |
| 01004378 | vid_span_32bpp | 132 | known | 0 | 1 | 1 |  |  | expand run of 2bpp pixels into 32bpp framebuffer (long per pixel) via mg+$33c lut |
| 010043fc | vid_draw_image_onscreen | 68 |  | 1 | 0 | 2 |  |  | ints off, mg+$368 := mg+$374 (visible fb), vid_draw_image(x,y,img), restore |
| 01004440 | vid_draw_image | 210 |  | 9 | 0 | 6 |  |  | draw NeXT image struct (type 'B' RLE,'U' raw,'S' table-RLE) at x,y; picks span fn by depth |
| 01004512 | vid_draw_rle_image | 104 |  | 1 | 0 | 1 |  |  | type 'B': (value,count) byte pairs per row, calls span fn |
| 0100457a | vid_draw_raw_image | 418 |  | 1 | 0 | 1 |  |  | type 'U': packed 2bpp rows expanded per depth; raw copy if mg+$348 == -1 |
| 0100471c | vid_draw_tbl_rle_image | 144 |  | 1 | 0 | 1 |  |  | type 'S': n (value,count) table then index bytes per row |
| 010047ac | post_delay_9us | 18 |  | 7 | 7 | 1 |  |  | delay(9) wrapper used between register accesses in tests |
| 010047be | snd_out_clear_underrun_any | 40 | known | 4 | 0 | 3 |  |  | non-Turbo (mg+$194==$139): snd_out_clear_underrun_wait else snd_out_clear_underrun |
| 010047e6 | post_scsi_dma_isr | 20 | known | 0 | 0 | 1 |  |  | ISR frame: save regs, post_scsi_dma_intr, rte (unused in POST: SCSI DMA int) |
| 0100480a | post_timer_isr | 16 | known | 0 | 1 | 1 |  |  | level-6 autovector ISR frame used by post_timer_test: calls post_timer_ack |
| 0100481a | post_snd_out_isr | 16 | known | 0 | 1 | 1 |  |  | level-6 autovector ISR frame used by sound test: calls post_snd_out_dma_stop |
| 0100483e | post_fpu_test | 52 |  | 1 | 0 | 3 |  |  | run fpu_test_regs(1), fpu_test_formats(2), fpu_test_arith(3); d0 = failing sub-test or 0 |
| 01004872 | post_snd_in_dma_reset | 52 | known | 0 | 1 | 1 |  | DMA Controller (Motorola) (writes MUST be 32-bit) | ISR body: sound-in DMA CSR $020000c0 = RESET\|INITBUF(non-Turbo)/BUFRESET(Turbo) |
| 010048a6 | post_scc_test | 368 |  | 1 | 0 | 2 |  | device space mirror of $02018000 = Serial Communication Controller (AMD Z8530H), | Z8530 loopback via $02118000: WR9 reset, 20-byte init table, tx/rx $40 both channels; d0 1-7 |
| 01004a16 | post_scsi_dma_intr | 20 |  | 1 | 1 | 1 | "SCSI DMA intr?\n" |  | printf "SCSI DMA intr?\n" |
| 01004a2a | post_scsi_test | 176 |  | 1 | 0 | 0 |  | device space mirror of $02014000 = SCSI Controller (NCR53C90A), device space mir | ESP reset via ESP_DMA_CTRL $02114020, chip reset, FIFO 0..4 write/read check; d0 1-3 |
| 01004ada | post_ext_scsi_test | 278 |  | 1 | 0 | 1 |  | device space mirror of $02014000 = SCSI Controller (NCR53C90A), device space mir | ESP FIFO flush, transfer count $5555/$AAAA, config reg 0..255, illegal cmd INTR_ILL; d0 4-8 |
| 01004bf0 | post_enet_test | 802 |  | 1 | 0 | 11 |  | device space mirror of $02006004 = Network Adapter (AT&T 7213), device space mir | AT&T7213 loopback: drain rx, send/recv 1500B self-addr, filter test, broadcast; d0 1-7 |
| 01004f12 | post_ecc_test | 958 |  | 1 | 0 | 3 |  | DMA Controller (Motorola) (writes MUST be 32-bit), Ethernet Saved Limit, device  | MO drive (OSP $02112000) ECC encode/corrupt/correct via disk DMA $02000050; cubes only; d0 1-6 |
| 010052d0 | post_rtc_test | 104 |  | 1 | 0 | 3 |  |  | wait up to 1.1 s for RTC seconds reg ($20 old chip / $23 new) to change; d0 1 on timeout |
| 01005338 | post_timer_ack | 22 |  | 1 | 1 | 0 |  | device space mirror of $02016004 = Internal Hardclock | timer ISR body: read hardclock CSR $02116004, write 0 (disable) |
| 0100534e | post_timer_test | 242 |  | 1 | 0 | 3 |  | System Control Register 2, device space mirror of $02016000 = Internal Hardclock | hardclock counter write/latch/readback 0..$FFFF then 1000us periodic int must fire; d0 2,3 |
| 01005440 | post_evcnt_test | 250 |  | 1 | 0 | 1 |  | device space mirror of $0201a000 = Event Counter, device space mirror of $0201a0 | event counter $0211A000 must tick, delay(1000) in 899..1100us, 100 deltas within 3; d0 1-3 |
| 0100553a | post_evcnt_measured | 184 |  | 0 | 0 | 1 |  |  | event counter test: measured delay(1000) in d0 (us) |
| 010055f2 | post_snd_out_overrun_intr | 20 | known | 0 | 1 | 1 | "Sound Out Over Run Interrupt.\n" |  | printf "Sound Out Over Run Interrupt.\n" |
| 01005606 | kms_send_cmd | 46 |  | 6 | 0 | 1 |  | Monitor/Soundbox (Keyboard, Mouse, Sound) | wait KMS TX bit4 clear, KMS_Ctrl_Cmd $0200E003 = cmd, KMS_Data $0200E004 = data, delay 200us |
| 01005634 | post_snd_out_dma_stop | 74 |  | 1 | 1 | 3 |  | DMA Controller (Motorola) (writes MUST be 32-bit) | ISR body: sound-out DMA CSR $02000040 = RESET(+INITBUF/BUFRESET), KMS cmd 7 (snd out off) |
| 0100567e | kms_set_volume | 218 | known | 4 | 0 | 2 |  | device space | bit-bang volume chip via KMS CTRLOUT ($C4): 11 bits, chan sel $40/$80, 6-bit volume |
| 01005758 | post_snd_out_test | 750 | known | 0 | 2 | 8 | "\nSound Out DMA error!\n" | Channel Sound out, DMA Controller (Motorola) (writes MUST be 32-bit), Monitor/So | play 8KB buffer (arg 1 silence / 0 sine) via sound-out DMA $02004040; d0 1 DMA err, 2 not done |
| 01005a46 | post_run_all | 92 |  | 1 | 0 | 4 | "Testing the FPU" |  | POST master: FPU,SCC,SCSI,Enet,ECC(cubes),RTC,Timer,EvCnt,[SoundOut],[ExtSCSI]; d0 error code |
| 01005aa2 | post_ret_fpu | 48 |  | 0 | 0 | 3 | ", SCC" |  | POST master: FPU test returned (d0); error code $40\|n |
| 01005ad2 | post_ret_scc | 84 |  | 0 | 0 | 4 | ", SCSI"; ", Enet" |  | POST master: SCC test returned (d0); error code $50\|n |
| 01005b26 | post_ret_enet | 56 |  | 0 | 0 | 2 | ", ECC" |  | POST master: Enet test returned (d0); error code $70\|n |
| 01005b5e | post_ret_ecc | 48 |  | 0 | 0 | 3 | ", RTC" |  | POST master: ECC test returned (d0); error code $80\|n |
| 01005b8e | post_ret_rtc | 48 |  | 0 | 0 | 3 | ", Timer" |  | POST master: RTC test returned (d0); error code $90\|n |
| 01005bbe | post_ret_timer | 166 |  | 0 | 0 | 4 | ", Event Counter"; ", Sound Out"; "\n\nStarting Extended Self Test." |  | POST master: Timer test returned (d0); error code $C0\|n; then EvCnt $D0\|n, SoundOut $E0\|n |
| 01005c64 | post_ret_ext_scsi | 110 |  | 0 | 0 | 4 | "\n\nPress and hold any key to ex" |  | POST master: Ext SCSI (and SCSI) returned (d0); error code $60\|n; loop-mode key wait |
| 01005cd2 | nvram_check_or_rtc_ramtest | 112 |  | 1 | 0 | 4 |  |  | read NVRAM: ok -> d0 = POT byte & $10 (TEST_DRAM); bad -> walking-1 RTC RAM test, LED 4 blinks, d0=1 |
| 01005d44 | fpu_test_regs | 62 |  | 1 | 0 | 1 |  |  | fmovem 8 patterns x 256 rotations through fp0-fp7, compare; d0 != 0 on error |
| 01005d82 | fpu_test_regs_pattern | 80 |  | 8 | 0 | 0 |  |  | inner: push 8 x (d1,d2,d3), fmovem in/out, compare 256 shifted variants |
| 01005dd2 | fpu_test_formats | 74 |  | 1 | 0 | 0 |  |  | fmove.l/.s/.d/.x round trips of 1024 ints from $8000; d0 != 0 on error |
| 01005e1c | fpu_test_arith | 130 |  | 1 | 0 | 0 |  |  | fadd/fsub/fmul/fdiv/fsqrt/fcmp + fsave/frestore 1024 times; d0 != 0 on error |
| 01005ea0 | ncc_cache_data_test | 376 |  | 1 | 0 | 0 | "\nCache RAM selftest failure\n"; "Memory error at location: 0x%x\n"; "Value at time of failure: 0x%x\n" | NCC | Nitro NCC: size from NCC bits4:3, test $03F00000 data RAM AA/55/pattern; d0 = fail addr or 0 |
| 01006018 | post_cache_tag_test | 190 |  | 1 | 0 | 0 | "\nCache tag selftest failure.\n"; "Memory error at location: 0x%x\n"; "Expected: 0x%x     Received: 0x%" | NCC | NCC cache tag RAM walking-pattern test (16 rotations of $D32B6D5B), prints failure; ret 0 ok / addr |
| 010060d6 | post_cache_clear | 54 | known | 0 | 0 | 0 |  | NCC | zero NCC cache tag RAM $03E00000 and data RAM $03F00000 (size from NCC reg bits 4:3); no caller found |
| 0100610c | boot_cmd | 500 |  | 1 | 0 | 7 | "No default boot command.\n"; "Boot command: %s\n"; "Default boot device not found.\n" | DMA Controller (Motorola) (writes MUST be 32-bit) | parse 'b [dev(ctrl,unit,part)] [file] [flags]' (default from NVRAM), run device open/load, ret entry pc |
| 01006300 | boot_cmd_paren_check | 608 |  | 0 | 1 | 9 | "boot %s%s%s\n" | Turbo Memory Controller, device space mirror of $02018180 = Serial Interface Clo | NOT a routine: middle of boot_cmd (bne after cmpi ')'); false pointer at $01007894 |
| 01006560 | boot_case_ok | 6 | known | 0 | 1 | 0 |  |  | boot_cmd switch case 0: device opened, select 'Loading from ...' animation ($10 of dev entry) |
| 01006566 | boot_case_flip_disk | 20 | known | 0 | 1 | 1 |  |  | boot_cmd switch case 2: animation $13 of dev entry (od: 'Please flip disk') |
| 0100657a | boot_case_insert_disk | 18 | known | 0 | 1 | 1 |  |  | boot_cmd switch case 3: animation $12 of dev entry (od: 'Please insert disk') |
| 0100658c | boot_case_no_media | 128 | known | 0 | 1 | 2 | "diagnostics" |  | boot_cmd switch case 1: optical drive absent -> replace boot command by 'en' and restart |
| 0100660c | boot_cmd_diag_check_tail | 6 |  | 0 | 2 | 0 |  |  | NOT a routine: tail of boot_cmd after strcmp(file,'diagnostics'); false pointer hits |
| 01006612 | boot_cmd_reload_default | 24 |  | 0 | 1 | 1 |  |  | NOT a routine: boot_cmd path that reloads NVRAM boot command and restarts the parse |
| 0100662a | boot_case_error | 224 |  | 0 | 1 | 7 | "Usage: b [device[(ctrl,unit,part"; "boot devices:\n" | Turbo Memory Controller, device space mirror of $02018180 = Serial Interface Clo | boot_cmd switch case 4/default: 'Bad disk/network' animation, od eject, wait 3 s, retry open |
| 0100670a | boot_l3_isr | 214 | known | 1 | 1 | 2 |  | DMA Controller (Motorola) (writes MUST be 32-bit), device space mirror of $02018 | level-3 ISR body: SCSI intr -> mg+$302 hook; video frame intr -> ack (per mg+$3BE) and animate |
| 010067e0 | boot_l3_isr_tmc_tail | 44 |  | 0 | 1 | 1 |  | Turbo Memory Controller | NOT a routine: Turbo branch of boot_l3_isr: TMC $02200080 := $05000000, animate, := $06000000 |
| 0100680c | boot_anim_step | 174 |  | 3 | 2 | 4 |  |  | advance boot panel animation: draw text/icon of table entry mg+$2FA, count down mg+$2FE, poll keyboard |
| 010068ba | boot_l3_isr_entry_link | 4 | known | 0 | 0 | 0 |  |  | unused link.w prologue in front of boot_l3_isr_entry (compiler artifact) |
| 010068be | boot_l3_isr_entry | 16 |  | 0 | 1 | 1 |  |  | vector $6C (level-3 autovector) wrapper: save d0-d1/a0-a1, jsr boot_l3_isr, rte |
| 010068d2 | boot_anim_set | 66 |  | 4 | 0 | 1 |  |  | select animation sequence n (entry $0101A354+10n) into mg+$2FA/$2FE and install boot_anim_step at mg+$30E |
| 01006914 | boot_load_image_header | 182 | known | 2 | 0 | 2 | "unknown binary format\n" |  | parse a.out $0107 or Mach-O FEEDFACE/MH_PRELOAD header in buf, copy first chunk, ret bytes left |
| 010069cc | enet_boot_open | 98 | known | 0 | 1 | 2 |  |  | en ops[0]: alloc $73C-byte netboot state (dev+$20), server MAC=broadcast, enet_init; ret 0 ok / 4 |
| 01006a2e | enet_boot_close | 22 | known | 0 | 1 | 0 |  |  | en ops[1]: call netif devops[1] (enet shutdown) |
| 01006a44 | tftp_load_kernel | 974 | known | 0 | 1 | 10 | "Booting %s from %s\n"; "octet"; "\ntftp: %s\n" |  | en ops[2]: BOOTP then TFTP RRQ (octet) of the boot file, load via image header, ret entry pc |
| 01006e12 | bootp_request | 986 |  | 1 | 0 | 16 | "Requesting BOOTP information"; "from %s"; "[boot]\n" |  | broadcast BOOTP request (ports 68->67, vendor 'NeXT'), retry w/ backoff, handle NeXT login prompt |
| 010071ec | net_arp_reply | 188 |  | 1 | 0 | 0 |  |  | answer an ARP request for our IP: swap addresses, op=2, send through netif devops[3] |
| 010072a8 | net_send_ip | 172 |  | 3 | 0 | 1 |  |  | build ethernet+IP header (type $800, dst MAC state+$22, src state+$1C), checksum, pad to 60, send |
| 01007354 | net_poll_recv | 232 |  | 4 | 0 | 2 |  |  | netif read into state buffer; answer ARP; ret frame length if IP frame addressed to us else 0 |
| 0100743c | net_ip_checksum | 66 |  | 5 | 0 | 0 |  |  | 16-bit ones-complement sum over len bytes (IP/UDP checksum, caller inverts) |
| 01007480 | con_putc_crlf | 50 |  | 7 | 0 | 1 |  |  | putc with CR inserted before LF (console) |
| 010074b2 | vid_draw_char | 444 |  | 1 | 0 | 5 |  |  | draw glyph c from font metrics $0101A4D0+6c at cursor mg+$1CE/$1D2 (bpp mg+$324); LF = newline |
| 0100766e | print_char_sink | 100 |  | 13 | 0 | 3 |  |  | printf output: dest 0 console, 1 screen text, 2 log buffer mg+$320 (or console), else string ptr |
| 010076d2 | print_number | 160 | known | 3 | 0 | 1 | "0123456789abcdef" |  | print unsigned/signed number in base with zero-pad/width to sink; args val,base,zero,width,sink |
| 01007772 | printf | 24 |  | 112 | 11 | 1 |  |  | printf(fmt,...) to the console (vprintf dest 0) |
| 0100778a | sprintf | 26 |  | 6 | 0 | 1 |  |  | sprintf(buf,fmt,...) (vprintf with dest = buf) |
| 010077a4 | vid_printf_at | 184 |  | 3 | 0 | 3 |  |  | clear boot panel text area (opt) and print fmt at screen x,y (dest 1, sets mg+$1CE/$1D2) |
| 0100785c | printf_log | 26 |  | 20 | 8 | 1 |  |  | printf(fmt,...) to dest 2: verbose log buffer mg+$320, or console when mg+$170 bit3 set |
| 01007876 | vprintf | 96 |  | 4 | 0 | 1 |  |  | format engine: %% %0 %1-9 %D %d %u %O %o %X %x %c %l %s %b(BSD bit names); args fmt,dest,argp |
| 010078d6 | vprintf_case_zero | 4 | known | 0 | 1 | 0 |  |  | vprintf case %0: set zero-pad flag |
| 010078da | vprintf_case_width | 6 | known | 0 | 9 | 0 |  |  | vprintf case %1..%9: accumulate field width |
| 010078e0 | vprintf_case_hex | 4 | known | 0 | 2 | 0 |  |  | vprintf case %x/%X: base 16 |
| 010078e4 | vprintf_case_dec | 4 | known | 0 | 3 | 0 |  |  | vprintf case %d/%D/%u: base 10 |
| 010078e8 | vprintf_case_oct | 28 | known | 0 | 2 | 1 |  |  | vprintf case %o/%O: base 8 |
| 01007904 | vprintf_case_c | 34 | known | 0 | 1 | 1 |  |  | vprintf case %c: prints the 4 bytes of the long, high to low, non-zero 7-bit chars |
| 01007926 | vprintf_case_b | 480 | known | 0 | 1 | 2 |  |  | vprintf case %b: value + BSD-style bit/field description string (base byte, <BIT,..>) |
| 01007b06 | vprintf_case_s | 30 | known | 0 | 1 | 1 |  |  | vprintf case %s |
| 01007b24 | vprintf_case_pct | 20 | known | 0 | 1 | 0 |  |  | vprintf case %% |
| 01007b38 | print_line | 34 |  | 2 | 0 | 0 |  |  | printf(s) followed by newline |
| 01007b5c | con_gets | 330 |  | 7 | 0 | 3 |  |  | read a line (buf,size,echo): ^H/DEL erase, ^U kill, ^W word erase, CR/LF end; ret len+1, -1 on $FF |
| 01007ca8 | str_skip_space | 48 |  | 11 | 0 | 0 |  |  | skip spaces, tabs, CR, LF; ret pointer to first other char |
| 01007cd8 | parse_number | 254 |  | 6 | 1 | 4 | "0123456789abcdef"; "0123456789abcdef" |  | parse [-][~](0t\|0x)digits[.digits..] into *out (dotted = byte-packed); base 0 = mg+$192; ret ptr/0 |
| 01007dd6 | mem_alloc | 52 |  | 11 | 2 | 2 |  |  | mg_alloc(n): mg+$EC (alloc_brk) -= n, bzero, ret pointer (installed at mg+$2EA) |
| 01007e0c | abs_l | 10 |  | 2 | 0 | 0 |  |  | abs(long); missed by the descent ($01007e06..$01007e15 mis-decoded as a string) |
| 01007e16 | mem_cmp | 178 |  | 9 | 1 | 0 |  |  | bcmp(a,b,n): ret 0 equal, 1 different (long-wise when aligned) |
| 01007ec8 | mem_move | 38 |  | 20 | 4 | 0 |  |  | bcopy(src,dst,n) with overlap handling (byte loops; the long fast path at +$26 is dead code) |
| 01007f66 | loc_01007f66 | 22 | jump-only | 0 | 0 | 0 |  |  |  |
| 01007ff2 | loc_01007ff2 | 10 | jump-only | 0 | 0 | 0 |  |  |  |
| 01007ffc | mem_zero | 128 |  | 39 | 3 | 0 |  |  | bzero(p,n): byte-align then long clears |
| 0100807c | str_index | 38 |  | 2 | 0 | 0 |  |  | index(s,c): ptr to first c in s (c==0 -> ptr to terminator), 0 if absent |
| 010080a2 | str_ncpy | 32 |  | 4 | 0 | 0 |  |  | strncpy(dst,src,n); zero-pads; returns dst |
| 010080c2 | str_cat | 22 | known | 0 | 1 | 0 |  |  | strcat(dst,src); returns dst |
| 010080d8 | str_cmp | 32 |  | 5 | 0 | 0 |  |  | strcmp(a,b); returns a[i]-b[i] or 0 |
| 010080f8 | str_cpy | 16 |  | 9 | 0 | 0 |  |  | strcpy(dst,src); returns dst |
| 01008108 | str_ncmp | 40 |  | 7 | 0 | 0 |  |  | strncmp(a,b,n) |
| 01008130 | str_len | 14 |  | 4 | 0 | 0 |  |  | strlen(s) |
| 01008140 | con_getc | 68 |  | 1 | 1 | 3 |  |  | mg_getc: read char from console selected by mg+$318 (0 kbd,1 SCC A,2 SCC B) |
| 01008184 | con_try_getc | 68 |  | 1 | 1 | 3 |  |  | mg_try_getc: non-blocking 'key pressed?' on console mg+$318; returns 1/0 |
| 010081c8 | con_putc | 100 |  | 2 | 1 | 3 |  |  | mg_putc(c): write char to console mg+$31C (0 screen,1 SCC A,2 SCC B) |
| 0100822c | delay_1us | 18 |  | 3 | 4 | 1 |  |  | delay_us(1); bit-bang half-clock spacing for the RTC |
| 0100823e | rtc_wait_tick | 78 |  | 1 | 0 | 2 |  |  | poll RTC seconds byte (reg $20 old / $23 new chip) until it changes |
| 0100828c | rtc_modify_reg | 62 |  | 6 | 0 | 2 |  |  | rtc_modify(reg,mask,val): read reg, clear mask bits, or (val&mask), write |
| 010082ca | rtc_power_int_handler | 182 |  | 5 | 0 | 3 |  |  | while INT_POWER($02007000 bit2): read status $30, ack LBAT/alarm/pdown; ret 1 if pdown |
| 01008380 | rtc_power_down | 80 |  | 1 | 0 | 4 |  |  | wait tick, delay 850ms, set POWERDOWN bit in reg $31 (new) / $32 (old); spin forever |
| 010083d4 | rtc_int_clear | 44 |  | 2 | 0 | 3 |  |  | old chip: write intctrl $32=0; then rtc_power_int_handler |
| 01008400 | rtc_start_clock | 64 |  | 1 | 0 | 4 |  |  | rtc_int_clear; new chip: reg $31 \|= $80 START; old chip: reg $31 = $B0 |
| 01008440 | time_tm_to_secs | 150 | known | 1 | 0 | 0 |  |  | convert {sec,min,hour,mday,mon,year} to seconds since 1970 (table dat_0101a8a2) |
| 010084d6 | rtc_get_time | 278 | known | 0 | 0 | 3 |  |  | returns unix seconds: 0 if FIRSTUP; new chip 32-bit counter $20..$23; old chip BCD regs |
| 010085ec | bcd_to_bin | 48 | known | 0 | 1 | 0 |  |  | BCD byte -> binary |
| 0100861c | nvram_read | 80 |  | 6 | 0 | 2 |  |  | read RTC RAM regs 0..31 into buf, verify checksum word at +$1E; returns 0 ok / -1 |
| 0100866c | nvram_write | 124 |  | 6 | 0 | 5 |  |  | compute checksum, write 32 RTC RAM regs ($80\|i), read back and compare; 0 ok / -1 |
| 010086e8 | rtc_write_reg | 168 |  | 5 | 0 | 2 |  | System Control Register 2 | rtc_write(reg,val): bit-bang addr\|$80 then val, MSB first, via SCR2 RTCE/RTCLK/RTDATA |
| 01008790 | rtc_read_regs | 60 |  | 2 | 0 | 1 |  |  | read n consecutive RTC regs starting at reg into buf |
| 010087cc | rtc_read_reg | 28 |  | 18 | 0 | 1 |  |  | rtc_read(reg) -> unsigned byte (wrapper of rtc_read_reg_raw) |
| 010087e8 | rtc_read_reg_raw | 178 |  | 1 | 0 | 2 |  | System Control Register 2 | bit-bang: send 8 addr bits, clock in 8 data bits from SCR2 bit $400 |
| 0100889c | timer_read_us | 114 |  | 5 | 0 | 1 |  | device space mirror of $0201a000 = Event Counter, device space mirror of $0201a0 | read 20-bit us counter $0211A000..3, extend to 32 bits with mg+$2F6 wrap tracking |
| 0100890e | timer_read_ms | 22 |  | 3 | 3 | 1 |  |  | timer_read_us()/1000 |
| 01008924 | timer_elapsed_us | 18 |  | 1 | 0 | 1 |  |  | timer_read_us() - t0 |
| 01008936 | delay_us | 46 |  | 51 | 8 | 2 |  |  | busy-wait n microseconds on the event counter (n+1 ticks) |
| 01008964 | scc_init | 104 |  | 3 | 0 | 2 |  | device space mirror of $02018000 = Serial Communication Controller (AMD Z8530H), | WR9=$C0 hw reset, then scc_init_channel(A,9600), (B,9600); clears mg+4 bits 4,5 |
| 010089cc | scc_init_channel | 356 | known | 0 | 1 | 2 |  |  | program WR9,11,0,4,3,5,14,12,13,14,3,5 for 8N1 x16 BRG at baud (arg2) |
| 01008b30 | scc_calc_baud_tc | 158 |  | 1 | 0 | 1 |  | device space mirror of $02018004 = Serial Interface Clock | SCC clock reg $02118004=$0A; pick PCLK 3.6864M or RTxC 4M, return TC\|$20000 if PCLK |
| 01008bce | scc_getc_raw | 26 |  | 2 | 0 | 0 |  |  | wait RR0 bit0 (Rx char available) then read data reg ctrl+2 |
| 01008be8 | scc_putc_raw | 28 |  | 1 | 0 | 0 |  |  | wait RR0 bit2 (Tx buffer empty) then write data reg ctrl+2 |
| 01008c04 | scc_rx_ready | 22 |  | 1 | 0 | 0 |  |  | return RR0 & 1 |
| 01008c1a | scc_poll_flow_control | 88 |  | 1 | 0 | 3 |  |  | if rx char: XOFF($13) sets mg+4 bit5, XON($11) clears it, other sets bit4 |
| 01008c72 | scc_getc | 100 |  | 1 | 1 | 3 |  | device space mirror of $02018000 = Serial Communication Controller (AMD Z8530H), | init SCC if mg+4 bit6 clear; read char (skip XON/XOFF), clear bit4, return c&$7F |
| 01008cd6 | scc_try_getc | 30 |  | 1 | 0 | 1 |  |  | return mg+4 bit4 (char seen while polling) and clear it |
| 01008cf4 | scc_putc | 116 |  | 1 | 1 | 4 |  | device space mirror of $02018000 = Serial Communication Controller (AMD Z8530H), | init if needed; honour XOFF; add even parity (table $0101A8BC); scc_putc_raw |
| 01008d68 | scc_stub_ret0 | 10 | known | 0 | 2 | 0 |  |  | empty SCC ops entry, returns 0 (slots 0,1 of table $0101A944) |
| 01008d74 | enet_reg_read | 76 | known | 1 | 1 | 2 | "enreg_read failed \n" |  | bus-error-safe byte read, 15 retries; prints 'enreg_read failed' |
| 01008dc0 | enet_reg_write | 74 |  | 4 | 2 | 2 | "enreg_write failed \n" |  | bus-error-safe byte write, 15 retries; prints 'enreg_write failed' |
| 01008e0a | enet_reg_poll | 76 |  | 2 | 0 | 2 |  |  | bus-error-safe read, up to 10 tries 1ms apart; returns 1 ok / 0 fail |
| 01008e56 | enet_nop | 8 | known | 0 | 1 | 0 |  |  | empty netif op (slot 4 of table $0101A95C) |
| 01008e5e | enet_init | 672 |  | 1 | 1 | 10 |  | DMA Controller (Motorola) (writes MUST be 32-bit), device space mirror of $02006 | netif init: alloc state, carve 33x8KB buffers, reset chip, MAC, masks, RX DMA, vec 30 |
| 010090fe | enet_isr_dead_prologue | 4 | known | 0 | 0 | 0 |  |  | stray link a6 before enet_rx_isr; not a real routine |
| 01009102 | enet_rx_isr | 16 |  | 0 | 1 | 1 |  |  | autovector 30 (level 6) stub: save d0-d1/a0-a1, call enet_rx_int, rte |
| 01009116 | enet_read | 372 |  | 4 | 1 | 3 |  |  | netif read(buf,max): pop next received ring entry, Turbo +1 byte realign, return len |
| 0100928a | enet_write | 808 |  | 3 | 1 | 5 | "en_write: tx not ready\n"; "en_write: tx not ready\n" |  | netif write(buf,len,tpcheck): TX DMA one packet, wait ready/complete, TP fallback |
| 010095b2 | enet_close | 62 |  | 7 | 1 | 1 |  |  | TX/RX DMA CSR = DMA_RESET, control reg $02106006 = $80 (chip reset) |
| 010095f0 | enet_rx_int | 206 |  | 1 | 1 | 5 |  | Ethernet Saved Limit | RX DMA interrupt: record CSR/status/saved limit ($02004050) in ring, restart DMA |
| 010096be | enet_rx_dma_start | 418 |  | 2 | 0 | 3 |  |  | chain next 8KB buffer into RX DMA (next/limit/start/stop), CSR cmd, RX mode on |
| 01009860 | kms_send_reset | 68 |  | 4 | 0 | 1 |  | Monitor/Soundbox (Keyboard, Mouse, Sound) | SR=$2700, $0200E002\|=1, KMS cmd $C6 data $1000A825 (magic reset) then $C6/0 |
| 010098a4 | kms_console_init | 322 |  | 1 | 0 | 7 |  |  | probe keyboard via $C5/$EF000000; no kbd + NVRAM altcons -> console=SCC A; text init |
| 010099e6 | vid_text_reset | 70 |  | 2 | 0 | 1 |  |  | reset text window: colours, cursor col/row=0, mg+$166=&mg+$16C, clear $16A.., $1CE |
| 01009a2c | vid_draw_panel | 1134 |  | 2 | 0 | 7 | "NeXT ROM Monitor %d.%d (v%d)" |  | draw ROM monitor alert panel (title, w chars, h lines) in 1/2/8/16/32bpp, save under $158 |
| 01009e9a | vid_restore_panel | 324 |  | 1 | 0 | 2 |  |  | copy saved pixels from mg+$158 back to the framebuffer, clear $158, cursor on |
| 01009fde | mon_clear_nmi | 48 |  | 1 | 0 | 1 |  | Monitor/Soundbox (Keyboard, Mouse, Sound), Turbo Memory Controller | ack NMI: $0200E001 \|= $10 (NMI_RECEIVED), Turbo: clear TMC NMI reg $02200020 |
| 0100a00e | kms_poll_km_event | 94 |  | 1 | 0 | 1 |  | Monitor/Soundbox (Keyboard, Mouse, Sound) | poll KMS $0200E000: if KM data received (bit22/21) latch $0200E008 in mg+$144, set mg_flags bit1; ret 1 |
| 0100a06c | kms_event_pending | 64 |  | 1 | 0 | 2 |  |  | ret 1 if a KM event is latched (mg_flags bit1, cleared) or dequeued from the int queue when mg+$3E5 bit0 |
| 0100a0ac | con_flow_control_poll | 108 |  | 1 | 0 | 3 |  |  | poll keyboard during output: ^S sets mg+$170 bit2 (pause), ^Q clears it, other key sets mg_flags bit0 |
| 0100a118 | vid_console_putc | 144 |  | 1 | 0 | 5 |  |  | graphics-console putc: init KMS/console if needed, honour ^S/^Q, LF->CRLF, vid_putc |
| 0100a1a8 | kms_power_key_check | 274 |  | 24 | 0 | 9 | "\nreally power down?" | Monitor/Soundbox (Keyboard, Mouse, Sound) | if INT_POWER pending: ask 'really power down?' and power off on y; else dequeue+translate key (int mode) |
| 0100a2ba | kms_read_key | 236 |  | 2 | 0 | 6 |  | Monitor/Soundbox (Keyboard, Mouse, Sound) | read one key: int-queue mode or polled (KMPOLL cmd $C6 data $01FFFFF6, KMREG $C5 $EF000000 on no-response) |
| 0100a3a6 | vid_console_getc | 76 |  | 1 | 0 | 2 |  |  | console getc: loop kms_read_key until a real char, CR->LF |
| 0100a3f2 | kms_translate_key | 138 |  | 3 | 0 | 1 |  |  | KM event -> ASCII via keymap $0101A978 (shift/ctrl); $101/$107 = brightness down/up; $100 = none |
| 0100a47c | kms_key_brightness | 94 | known | 0 | 2 | 3 |  |  | brightness key: NVRAM bits 19:14 +/-1 (0..$3D), nvram write, driver op +$18 (palette rescale) |
| 0100a4da | kms_send_cmd_wait | 70 |  | 4 | 0 | 1 |  | Monitor/Soundbox (Keyboard, Mouse, Sound) | kms_send_cmd then wait <=100000 polls for $0200E001 bit6 KM_RECEIVED; ret $40000000 on timeout |
| 0100a520 | kms_send_cmd_0100a520 | 76 |  | 5 | 2 | 2 |  | Monitor/Soundbox (Keyboard, Mouse, Sound) | enable KMS ($0200E002 \|= 2, once, mg+$170 bit7), write cmd byte $0200E003 and data long $0200E004, 100us |
| 0100a56c | vid_clear_text_area | 142 | known | 1 | 0 | 3 |  |  | fill the text window (rows mg+$150..+$156, cols $152..+$154, 8x12 cells) with bg pixel mg+$160 |
| 0100a5fa | vid_clear_screen | 66 |  | 4 | 0 | 3 |  |  | fill whole frame buffer (mg+$368, $328*$334 bytes) with mg+$344 (dark grey $55505550 / mono $AAAAAAAA) |
| 0100a63c | vid_putc | 60 |  | 5 | 0 | 3 |  |  | draw char at cursor (mg+$14C col,$14E row) 8x12 font $0101AC00, 2/8/16/32 bpp paths, scroll at bottom |
| 0100a678 | vid_putc_cr | 36 | known | 0 | 1 | 1 |  |  | vid_putc case CR: col=0 (draws cursor first if mg+$170 bit8 clear) |
| 0100a69c | vid_putc_lf | 8 | known | 0 | 1 | 0 |  |  | vid_putc case LF: row++ |
| 0100a6a4 | vid_putc_bs | 16 | known | 0 | 1 | 0 |  |  | vid_putc case BS: col-- if >0 |
| 0100a6b4 | vid_putc_tab | 62 | known | 0 | 1 | 2 |  |  | vid_putc case TAB: spaces to next multiple of 8 |
| 0100a6f2 | vid_putc_ff | 18 | known | 0 | 1 | 1 |  |  | vid_putc case FF: cursor home + vid_clear_text_area |
| 0100a704 | vid_putc_bel | 22 | known | 0 | 1 | 0 |  |  | vid_putc case BEL: sub_01005758(1) then (0) = beep on/off |
| 0100a71a | vid_putc_glyph | 408 |  | 0 | 1 | 0 |  |  | vid_putc printable path: 12 font rows, pixels-per-long switch (16=2bpp,4=8bpp,2=16bpp,1=32bpp) |
| 0100a8b2 | vid_putc_advance | 154 |  | 0 | 0 | 0 |  |  | vid_putc epilogue: wrap col/row, scroll one text line (12 scanlines) when row>=rows |
| 0100a94c | vid_scroll_copy_31 | 2 | known | 0 | 1 | 0 |  |  | scroll copy entry: copies 31 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a94e | vid_scroll_copy_30 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 30 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a950 | vid_scroll_copy_29 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 29 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a952 | vid_scroll_copy_28 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 28 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a954 | vid_scroll_copy_27 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 27 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a956 | vid_scroll_copy_26 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 26 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a958 | vid_scroll_copy_25 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 25 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a95a | vid_scroll_copy_24 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 24 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a95c | vid_scroll_copy_23 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 23 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a95e | vid_scroll_copy_22 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 22 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a960 | vid_scroll_copy_21 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 21 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a962 | vid_scroll_copy_20 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 20 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a964 | vid_scroll_copy_19 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 19 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a966 | vid_scroll_copy_18 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 18 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a968 | vid_scroll_copy_17 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 17 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a96a | vid_scroll_copy_16 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 16 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a96c | vid_scroll_copy_15 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 15 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a96e | vid_scroll_copy_14 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 14 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a970 | vid_scroll_copy_13 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 13 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a972 | vid_scroll_copy_12 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 12 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a974 | vid_scroll_copy_11 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 11 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a976 | vid_scroll_copy_10 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 10 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a978 | vid_scroll_copy_9 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 9 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a97a | vid_scroll_copy_8 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 8 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a97c | vid_scroll_copy_7 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 7 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a97e | vid_scroll_copy_6 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 6 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a980 | vid_scroll_copy_5 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 5 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a982 | vid_scroll_copy_4 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 4 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a984 | vid_scroll_copy_3 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 3 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a986 | vid_scroll_copy_2 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 2 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a988 | vid_scroll_copy_1 | 2 |  | 0 | 1 | 0 |  |  | scroll copy entry: copies 1 longs then falls into the 32-long loop (Duff's device in vid_putc) |
| 0100a98a | vid_scroll_copy_0 | 68 |  | 0 | 1 | 3 |  |  | Duff-device tail of the scroll copy (entry for 0 longs; loops 32 longs per pass) |
| 0100a9ce | vid_cursor_toggle | 168 |  | 7 | 0 | 3 |  |  | invert the 8x12 cell at the cursor (not.l / not.w per pixel-long) if col>=0 |
| 0100aa76 | vid_clear_to_eol | 168 |  | 1 | 0 | 3 |  |  | fill from cursor col to end of the current text row (12 scanlines) with bg mg+$160/$162 |
| 0100ab1e | mon_alert_printf | 94 |  | 2 | 0 | 3 |  |  | open the console/alert window (sub_01009a2c(x,y,title)) if mg+$170 bit3 clear, set bit5, printf(fmt,...) |
| 0100ab7c | mon_boot_error | 40 | known | 0 | 1 | 1 | "Error during boot" |  | mg+$2E2 slot: mon_alert_printf(0,0,'Error during boot', fmt, a,b,c) |
| 0100aba4 | mon_alert_close | 56 |  | 2 | 0 | 2 |  |  | if mg+$170 bit5: sub_01009e9a (close window), mg_flags \|= 8, clear bit5 |
| 0100abdc | nbus_rom_read_long | 174 |  | 5 | 3 | 1 |  |  | read long #n of the slot board config ROM (mg+$35C) honouring byte-lane width mg+$34E (1/4/8) |
| 0100ac8a | vid_console_init | 412 |  | 1 | 1 | 11 |  | GPIO Register, NBIC (non-Turbo cube), System Control Register 2, Turbo Memory Co | boot display select: probe on-board drivers, init+DAC+clear, NextBus slot scan on cubes, NVRAM console slot |
| 0100ae26 | nbus_probe_display_board | 492 |  | 1 | 0 | 7 |  |  | probe slot n: NBIC id $F0FFFFF0, magic $A5 at $F0FFFFE0, run board ROM display code; ret 1 if display |
| 0100b012 | vid_post_init | 60 |  | 2 | 0 | 3 |  |  | slot board: run board 'enable' code (ROM long 2*idx+3); on-board: vid_enable_display |
| 0100b04e | vid_init_display | 612 |  | 3 | 0 | 3 |  |  | (mg,slot,idx): on-board -> vid_driver_init; else build display struct mg+$324 from board ROM |
| 0100b2b2 | vid_lock | 66 |  | 8 | 0 | 3 |  |  | ++mg+$3A0; on first level: on-board driver op +$10 (nop for built-in displays) or run board code mg+$350 |
| 0100b2f4 | vid_unlock | 68 |  | 8 | 0 | 3 |  |  | --mg+$3A0; at zero: on-board driver op +$14 (cpusha for colour, nop for mono) or run board code mg+$354 |
| 0100b338 | nbus_map_addr | 84 | known | 3 | 0 | 1 |  |  | map a NextBus board address through the 6 windows mg+$358+12*i {bus,cpu,size} |
| 0100b38c | nbus_run_boardcode | 36 |  | 4 | 0 | 1 |  |  | interpreter for NeXTbus board ROM display code (8 regs, opcode bits 31:26, 0x2A ops); ret r0 |
| 0100b3b0 | nbus_op_next | 62 |  | 0 | 13 | 0 |  |  | nbus_run_boardcode fetch/dispatch loop |
| 0100b3ee | nbus_op_ldi | 16 | known | 0 | 1 | 0 |  |  | op $20: r[d] = imm |
| 0100b3fe | nbus_op_ldmem_imm | 32 | known | 0 | 1 | 0 |  |  | op $21: r[d] = *map(imm \| slot) |
| 0100b41e | nbus_op_ldmem_reg | 74 | known | 0 | 1 | 1 |  |  | op $01: r[d] = *map(r[s] \| slot) |
| 0100b468 | nbus_op_stmem_imm | 32 | known | 0 | 1 | 0 |  |  | op $22: *map(imm \| slot) = r[s] |
| 0100b488 | nbus_op_stmem_reg | 74 | known | 0 | 1 | 1 |  |  | op $02: *map(r[s] \| slot) = r[t] |
| 0100b4d2 | nbus_op_block_store | 86 | known | 0 | 1 | 1 |  |  | op $03: n = ins&$3FFFFFF pairs (value, addr): *map(addr\|slot) = value |
| 0100b528 | nbus_op_addi | 34 | known | 0 | 1 | 0 |  |  | op $24: r[d] = r[s] + imm |
| 0100b54a | nbus_op_add | 44 | known | 0 | 1 | 0 |  |  | op $04: r[d] = r[s] + r[t] |
| 0100b576 | nbus_op_subi | 34 | known | 0 | 1 | 0 |  |  | op $25: r[d] = r[s] - imm |
| 0100b598 | nbus_op_rsubi | 34 | known | 0 | 1 | 0 |  |  | op $26: r[d] = imm - r[s] |
| 0100b5ba | nbus_op_sub | 44 | known | 0 | 1 | 0 |  |  | op $05: r[d] = r[s] - r[t] |
| 0100b5e6 | nbus_op_andi | 34 | known | 0 | 1 | 0 |  |  | op $27: r[d] = r[s] & imm |
| 0100b608 | nbus_op_and | 44 | known | 0 | 1 | 0 |  |  | op $07: r[d] = r[s] & r[t] |
| 0100b634 | nbus_op_ori | 34 | known | 0 | 1 | 0 |  |  | op $28: r[d] = r[s] \| imm |
| 0100b656 | nbus_op_or | 44 | known | 0 | 1 | 0 |  |  | op $08: r[d] = r[s] \| r[t] |
| 0100b682 | nbus_op_xori | 34 | known | 0 | 1 | 0 |  |  | op $29: r[d] = r[s] ^ imm |
| 0100b6a4 | nbus_op_xor | 46 | known | 0 | 1 | 0 |  |  | op $09: r[d] = r[s] ^ r[t] |
| 0100b6d2 | nbus_op_shl | 42 | known | 0 | 1 | 0 |  |  | op $0A: r[d] = r[s] << (ins>>16 & 31) |
| 0100b6fc | nbus_op_asr | 42 | known | 0 | 1 | 0 |  |  | op $0B: r[d] = r[s] >> (ins>>16 & 31) arithmetic |
| 0100b726 | nbus_op_mov | 30 | known | 0 | 1 | 0 |  |  | op $0C: r[d] = r[s] |
| 0100b744 | nbus_op_test | 50 | known | 0 | 1 | 0 |  |  | op $06: set zero/pos/neg flags (a3/a5/a4) from r[s] |
| 0100b776 | nbus_op_bgt | 8 | known | 0 | 1 | 0 |  |  | op $0E: jump to ins&$3FFFFFF if pos |
| 0100b77e | nbus_op_blt | 8 | known | 0 | 1 | 0 |  |  | op $0F: jump if neg |
| 0100b786 | nbus_op_beq | 8 | known | 0 | 1 | 0 |  |  | op $10: jump if zero |
| 0100b78e | nbus_op_ble | 8 | known | 0 | 1 | 0 |  |  | op $11: jump if !pos |
| 0100b796 | nbus_op_bge | 8 | known | 0 | 1 | 0 |  |  | op $12: jump if !neg |
| 0100b79e | nbus_op_bne | 6 | known | 0 | 1 | 0 |  |  | op $13: jump if !zero |
| 0100b7a4 | nbus_op_jump | 12 |  | 0 | 1 | 0 |  |  | op $0D (and taken branches): pc = ins & $3FFFFFF |
| 0100b7b0 | nbus_op_return | 14 | known | 0 | 1 | 0 |  |  | op $00: return r0 |
| 0100b7c0 | vid_find_driver | 66 |  | 1 | 0 | 0 |  |  | call probe(mg) of the 3 display drivers ($0101B080, 28 bytes each); ret first index answering 1, else -1 |
| 0100b802 | vid_enable_display | 90 |  | 2 | 0 | 1 |  |  | clamp NVRAM brightness to >= $14 (nvram write); on-board display: driver op +$C (palette + video enable) |
| 0100b85c | vid_driver_init | 74 |  | 3 | 0 | 1 |  |  | (mg,idx): bzero mg+$324..$3A3, call driver[idx] init(mg,idx) |
| 0100b8a6 | vid_driver_setup_dac | 50 |  | 1 | 0 | 0 |  |  | on-board display: driver op +8 (dac_init_bt463 for colour, nop for mono) |
| 0100b8d8 | vid_driver_enter | 50 |  | 1 | 0 | 0 |  |  | on-board display: driver op +$10 (sub_0100c1aa nop for all built-in displays) |
| 0100b90a | vid_driver_exit | 50 |  | 1 | 0 | 0 |  |  | on-board display: driver op +$14 (colour: sub_010040a8 cpusha; mono: nop) |
| 0100b93c | vid_driver_set_brightness | 54 |  | 1 | 0 | 0 |  |  | (mg,val): on-board display: driver op +$18 (colour: palette rescale; mono: $02110000 register) |
| 0100b972 | vid_probe_color_1120 | 34 | known | 0 | 1 | 0 |  |  | driver 0 probe: type 3 -> 1; types 5,7,9,B -> SCR2 byte2 bit4 (video mode) set; else 0 |
| 0100b994 | vid_probe_scr2_vidmode | 10 | known | 0 | 4 | 0 |  | System Control Register 2 | ret 1 if SCR2 $0200D002 bit4 set (Previous: 'video mode is 25 MHz'), else 0 |
| 0100b99e | vid_probe_yes | 4 |  | 0 | 1 | 0 |  |  | ret 1 |
| 0100b9a2 | vid_probe_no | 6 |  | 0 | 4 | 0 |  |  | ret 0 |
| 0100b9a8 | vid_probe_color_832 | 62 | known | 0 | 1 | 0 |  | System Control Register 2 | driver 1 probe: types 5,7,9,B with SCR2 byte2 bit4 clear -> 1 (832x624 colour mode) |
| 0100b9e6 | vid_init_color_1120x832 | 424 | known | 0 | 1 | 0 |  |  | display struct: 2 px/long (16bpp), 2240 B/line, 1120x832, VRAM $0C000000 (Turbo)/$2C000000, greys FFF0/AAA0/5550/0 |
| 0100bb8e | vid_init_color_832x624 | 234 | known | 0 | 1 | 0 |  |  | display struct: 16bpp, 1664 B/line, 832x624, VRAM $0C000000/$2C000000, same grey values |
| 0100bc78 | dac_init_bt463 | 516 | known | 0 | 2 | 0 |  | RAMDAC (Brooktree Bt463), System Control Register 2, device space mirror of $020 | Bt463 $0201C000 (Turbo)/$02118100: CR0=40 CR1=0 CR2=80 readmask F0x4 blink 0x4, WTT[16]=000100, gamma palette, ovl FF |
| 0100be7c | vid_color_enable | 66 | known | 0 | 2 | 1 |  | Turbo Memory Controller, device space mirror of $02018180 = Serial Interface Clo | driver op +$C colour: palette from NVRAM brightness, then TMC $02200080=$04000000 (Turbo) / $02118180=4 |
| 0100bebe | dac_set_brightness_palette | 180 |  | 1 | 2 | 0 |  | RAMDAC (Brooktree Bt463), device space mirror of $02018100 = Serial Interface Cl | (mg,bright): Bt463 palette 0..255 = min(255, gamma[i]*(bright*64/61)/64 + 8), R=G=B |
| 0100bf72 | vid_probe_mono | 34 | known | 0 | 1 | 0 |  |  | driver 2 probe: types 4,6,8,A -> 1; 3,5,7,9,B -> 0; other types -> 1 |
| 0100bf94 | vid_probe_mono_no | 4 | known | 0 | 5 | 0 |  |  | ret 0 (colour type) |
| 0100bf98 | vid_probe_mono_yes | 6 |  | 0 | 4 | 0 |  |  | ret 1 |
| 0100bf9e | vid_init_mono_1120x832 | 424 | known | 0 | 1 | 0 |  |  | display struct: 16 px/long (2bpp), 280 B/line (288 non-Turbo), 1120x832, VRAM $0C000000/$0B000000 |
| 0100c146 | vid2_nop_m2 | 8 | known | 0 | 1 | 0 |  |  | video driver 2 method 2: empty (link/unlk/rts) |
| 0100c14e | vid2_enable | 60 | known | 0 | 1 | 0 |  | Turbo Memory Controller, device space mirror of $02010000 = Brightness | vid drv 2 method 3: brightness reg $02110000 = LFSR(ni_brightness)\|$40; Turbo: TMC video intr reg = $04 (enable) |
| 0100c18a | vid2_set_brightness | 32 | known | 0 | 1 | 0 |  | device space mirror of $02010000 = Brightness | vid drv 2 method 6 (mg, level): $02110000 = brightness_lfsr_tab[level] \| $40 |
| 0100c1aa | vid_nop | 8 | known | 0 | 4 | 0 |  |  | empty method shared by video driver vectors (link/unlk/rts) |
| 0100c1b4 | adb_init | 270 |  | 1 | 0 | 6 |  | Turbo Memory Controller | reset ADB bus, probe addr 1..7 (talk reg 3), build device chain at mg+$3e6, init kbd(2)/mouse(3), start talk reg0 |
| 0100c2c2 | adb_intr | 214 | known | 0 | 0 | 2 |  | Turbo Memory Controller | ADB interrupt service (unreferenced): ack INTSTATUS, CTRL=$10, read DATA0/1, call handler tab 0101b114, re-poll |
| 0100c398 | adb_kbd_poll | 192 |  | 2 | 0 | 3 |  | Turbo Memory Controller | (buf): ack ADB int, if ACCESS+DATAPEND for dev 2 copy DATA0/1 to buf; send talk addr2 reg0; delay 8000; ret 1=data |
| 0100c458 | adb_reset_bus | 42 |  | 3 | 0 | 0 |  | Turbo Memory Controller | (wait): ack INTSTATUS, CTRL=$08 RESET_ADB; if wait spin on INTSTATUS bit3 then write 8 to clear |
| 0100c482 | adb_send_cmd | 120 |  | 5 | 0 | 0 |  | Turbo Memory Controller | (cmdbyte,dataptr,len,wait): CMD=addr<<4\|cmd<<2\|reg, DATA0/1, COUNT=len*8, CTRL=$04 XMIT; wait ACCESS int, clear |
| 0100c4fa | adb_talk | 120 |  | 2 | 2 | 1 |  | Turbo Memory Controller | (addr,reg,dataptr,countptr): TALK cmd (3) with wait; if STATUS bit3 DATAPEND read COUNT>>3 bytes from DATA0/1 |
| 0100c572 | adb_listen | 52 |  | 8 | 2 | 1 |  |  | (addr,reg,dataptr,len): LISTEN cmd (2) with wait via adb_send_cmd |
| 0100c5a6 | adb_kbd_raise_nmi | 58 |  | 3 | 0 | 3 |  | Turbo Memory Controller | Turbo only: reset ADB bus, set TMC NMI reg $02200020 bit0 (raises NMI), delay 8000 us |
| 0100c5e0 | adb_set_config | 70 | known | 0 | 0 | 1 |  | Turbo Memory Controller | (flag) (unreferenced): CTRL=$10 RESET_WD; CONFIG = 3 (SYSTEM\|WATCHDOG) if flag==1 and a device is current else 0 |
| 0100c626 | adb_probe_kbd_alt_video | 100 |  | 1 | 0 | 3 |  | System Control Register 2 | (mg): mg+$3be=2, reset ADB, talk addr2 reg3; if kbd answers and SCR2 byte2 bit4: alt TMC timing by type 4..9 |
| 0100c68a | tmc_alt_timing_color | 26 | known | 0 | 3 | 0 |  | Turbo Memory Controller | types 5,7,9: TMC horiz $02200088 = $29044118, vert $0220008c = $021A0340 (20/32/68/280, 1/3/32/832) |
| 0100c6a4 | tmc_alt_timing_mono | 32 | known | 0 | 3 | 0 |  | Turbo Memory Controller | types 4,6,8: TMC horiz $02200088 = $5B02B118, vert $0220008c = $0041C340 (45/32/43/280, 0/8/28/832) |
| 0100c6c4 | adb_kbd_init | 196 |  | 1 | 0 | 1 |  |  | (addr,buf): mg+$3e2\|=1; listen reg3 handler=3; talk reg3; if handler 3: $3e2\|=2, talk reg2, set caps state, listen reg2 LEDs |
| 0100c788 | adb_kbd_handler | 464 | known | 0 | 1 | 2 |  |  | (data,count) ADB reg0 handler for addr 2 (tab 0101b114[2]): push 2 key events to ring mg+$486, translate to NeXT event mg+$144 |
| 0100c958 | kbd_a_up_ctrl_l | 10 | known | 0 | 1 | 0 |  |  | ADB $36 ctrl release: clear mg+$48a bit7, recompute ctrl bit |
| 0100c962 | kbd_a_up_ctrl_r | 10 | known | 0 | 1 | 0 |  |  | ADB $7d right ctrl release: clear $48a bit6 |
| 0100c96c | kbd_a_up_cmd | 26 | known | 0 | 1 | 0 |  |  | ADB $37 command release: clear $48a bit3 and event bits $1000/$800 |
| 0100c986 | kbd_a_up_shift_l | 24 | known | 0 | 1 | 0 |  |  | ADB $38 shift release: clear $200 (and $400 if not extended kbd) |
| 0100c99e | kbd_a_up_shift_r | 10 | known | 0 | 1 | 0 |  |  | ADB $7b right shift release: clear $400 |
| 0100c9a8 | kbd_a_up_alt_l | 38 | known | 0 | 1 | 0 |  |  | ADB $3a option release: clear $2000 (and $4000), clear $48a bit5 |
| 0100c9ce | kbd_a_up_alt_r | 24 | known | 0 | 1 | 0 |  |  | ADB $7c right option release: clear $4000 unless help held, clear $48a bit4 |
| 0100c9e6 | kbd_a_up_capslock | 88 | known | 0 | 1 | 1 |  |  | ADB $39 caps lock release: clear $48a bits0-1, clear $400, update LEDs (listen reg2) if extended |
| 0100ca3e | kbd_a_up_help | 68 | known | 0 | 1 | 0 |  |  | ADB $72 release: clear $48a bit2, clear $1000/$4000 unless cmd/alt_r held |
| 0100ca82 | kbd_a_down_ctrl_l | 8 | known | 0 | 1 | 0 |  |  | ADB $36 ctrl press: set $48a bit7, set event ctrl bit |
| 0100ca8a | kbd_a_down_ctrl_r | 34 | known | 0 | 1 | 0 |  |  | ADB $7d right ctrl press: set $48a bit6 |
| 0100caac | kbd_a_down_cmd | 26 | known | 0 | 1 | 0 |  |  | ADB $37 command press: set $48a bit3, event \|= $1000\|$800 |
| 0100cac6 | kbd_a_down_shift_l | 24 | known | 0 | 1 | 0 |  |  | ADB $38 shift press: set $200 (and $400 if not extended) |
| 0100cade | kbd_a_down_shift_r | 10 | known | 0 | 1 | 0 |  |  | ADB $7b right shift press: set $400 |
| 0100cae8 | kbd_a_down_alt_l | 30 | known | 0 | 1 | 0 |  |  | ADB $3a option press: set $2000 (and $4000 if not extended), $48a bit5 |
| 0100cb06 | kbd_a_down_alt_r | 14 | known | 0 | 1 | 0 |  |  | ADB $7c right option press: set $4000, $48a bit4 |
| 0100cb14 | kbd_a_down_capslock | 96 | known | 0 | 1 | 2 |  |  | ADB $39 caps lock press: $48a bit1, set $400, update LEDs if extended |
| 0100cb74 | kbd_a_down_help | 26 | known | 0 | 1 | 0 |  |  | ADB $72 press: $48a bit2, event \|= $1000\|$4000 |
| 0100cb8e | kbd_a_event_done | 120 |  | 0 | 126 | 2 |  |  | after modifier update: magic keys (0x25 reset via sub_01009860, 0x26 NMI), loop while ring not empty |
| 0100cc06 | adb_kbd_getevent_unused | 354 | known | 0 | 0 | 2 |  |  | (evptr) duplicate of adb_kbd_getevent; no reference found |
| 0100cd68 | kbd_b_up_ctrl_l | 10 | known | 0 | 1 | 0 |  |  | copy of kbd_a_up_ctrl_l |
| 0100cd72 | kbd_b_up_ctrl_r | 10 | known | 0 | 1 | 0 |  |  | copy of kbd_a_up_ctrl_r |
| 0100cd7c | kbd_b_up_cmd | 26 | known | 0 | 1 | 0 |  |  | copy of kbd_a_up_cmd |
| 0100cd96 | kbd_b_up_shift_l | 24 | known | 0 | 1 | 0 |  |  | copy of kbd_a_up_shift_l |
| 0100cdae | kbd_b_up_shift_r | 10 | known | 0 | 1 | 0 |  |  | copy of kbd_a_up_shift_r |
| 0100cdb8 | kbd_b_up_alt_l | 38 | known | 0 | 1 | 0 |  |  | copy of kbd_a_up_alt_l |
| 0100cdde | kbd_b_up_alt_r | 24 | known | 0 | 1 | 0 |  |  | copy of kbd_a_up_alt_r |
| 0100cdf6 | kbd_b_up_capslock | 88 | known | 0 | 1 | 1 |  |  | copy of kbd_a_up_capslock |
| 0100ce4e | kbd_b_up_help | 68 | known | 0 | 1 | 0 |  |  | copy of kbd_a_up_help |
| 0100ce92 | kbd_b_down_ctrl_l | 8 | known | 0 | 1 | 0 |  |  | copy of kbd_a_down_ctrl_l |
| 0100ce9a | kbd_b_down_ctrl_r | 34 | known | 0 | 1 | 0 |  |  | copy of kbd_a_down_ctrl_r |
| 0100cebc | kbd_b_down_cmd | 26 | known | 0 | 1 | 0 |  |  | copy of kbd_a_down_cmd |
| 0100ced6 | kbd_b_down_shift_l | 24 | known | 0 | 1 | 0 |  |  | copy of kbd_a_down_shift_l |
| 0100ceee | kbd_b_down_shift_r | 10 | known | 0 | 1 | 0 |  |  | copy of kbd_a_down_shift_r |
| 0100cef8 | kbd_b_down_alt_l | 30 | known | 0 | 1 | 0 |  |  | copy of kbd_a_down_alt_l |
| 0100cf16 | kbd_b_down_alt_r | 14 | known | 0 | 1 | 0 |  |  | copy of kbd_a_down_alt_r |
| 0100cf24 | kbd_b_down_capslock | 96 | known | 0 | 1 | 2 |  |  | copy of kbd_a_down_capslock |
| 0100cf84 | kbd_b_down_help | 26 | known | 0 | 1 | 0 |  |  | copy of kbd_a_down_help |
| 0100cf9e | kbd_b_event_done | 148 |  | 0 | 126 | 3 |  |  | store event to *evptr, magic key check, return |
| 0100d032 | adb_kbd_getevent | 354 |  | 4 | 0 | 2 |  |  | (evptr): drain ring or poll kbd; ADB code->NeXT keycode, modifiers; magic Cmd+Alt+* reset / Cmd+Alt+` NMI; ret 1 if event |
| 0100d194 | kbd_c_up_ctrl_l | 10 | known | 0 | 1 | 0 |  |  | copy of kbd_a_up_ctrl_l |
| 0100d19e | kbd_c_up_ctrl_r | 10 | known | 0 | 1 | 0 |  |  | copy of kbd_a_up_ctrl_r |
| 0100d1a8 | kbd_c_up_cmd | 26 | known | 0 | 1 | 0 |  |  | copy of kbd_a_up_cmd |
| 0100d1c2 | kbd_c_up_shift_l | 24 | known | 0 | 1 | 0 |  |  | copy of kbd_a_up_shift_l |
| 0100d1da | kbd_c_up_shift_r | 10 | known | 0 | 1 | 0 |  |  | copy of kbd_a_up_shift_r |
| 0100d1e4 | kbd_c_up_alt_l | 38 | known | 0 | 1 | 0 |  |  | copy of kbd_a_up_alt_l |
| 0100d20a | kbd_c_up_alt_r | 24 | known | 0 | 1 | 0 |  |  | copy of kbd_a_up_alt_r |
| 0100d222 | kbd_c_up_capslock | 88 | known | 0 | 1 | 1 |  |  | copy of kbd_a_up_capslock |
| 0100d27a | kbd_c_up_help | 68 | known | 0 | 1 | 0 |  |  | copy of kbd_a_up_help |
| 0100d2be | kbd_c_down_ctrl_l | 8 | known | 0 | 1 | 0 |  |  | copy of kbd_a_down_ctrl_l |
| 0100d2c6 | kbd_c_down_ctrl_r | 34 | known | 0 | 1 | 0 |  |  | copy of kbd_a_down_ctrl_r |
| 0100d2e8 | kbd_c_down_cmd | 26 | known | 0 | 1 | 0 |  |  | copy of kbd_a_down_cmd |
| 0100d302 | kbd_c_down_shift_l | 24 | known | 0 | 1 | 0 |  |  | copy of kbd_a_down_shift_l |
| 0100d31a | kbd_c_down_shift_r | 10 | known | 0 | 1 | 0 |  |  | copy of kbd_a_down_shift_r |
| 0100d324 | kbd_c_down_alt_l | 30 | known | 0 | 1 | 0 |  |  | copy of kbd_a_down_alt_l |
| 0100d342 | kbd_c_down_alt_r | 14 | known | 0 | 1 | 0 |  |  | copy of kbd_a_down_alt_r |
| 0100d350 | kbd_c_down_capslock | 96 | known | 0 | 1 | 2 |  |  | copy of kbd_a_down_capslock |
| 0100d3b0 | kbd_c_down_help | 26 | known | 0 | 1 | 0 |  |  | copy of kbd_a_down_help (table entry 010127cc) |
| 0100d3ca | kbd_c_event_done | 548 |  | 0 | 126 | 4 |  |  | store event to *evptr, magic key check (reset/NMI), return |
| 0100d5ee | kbd_d_up_ctrl_l | 10 | known | 0 | 1 | 0 |  |  | copy of kbd_a_up_ctrl_l |
| 0100d5f8 | kbd_d_up_ctrl_r | 10 | known | 0 | 1 | 0 |  |  | copy of kbd_a_up_ctrl_r |
| 0100d602 | kbd_d_up_cmd | 26 | known | 0 | 1 | 0 |  |  | copy of kbd_a_up_cmd |
| 0100d61c | kbd_d_up_shift_l | 24 | known | 0 | 1 | 0 |  |  | copy of kbd_a_up_shift_l |
| 0100d634 | kbd_d_up_shift_r | 10 | known | 0 | 1 | 0 |  |  | copy of kbd_a_up_shift_r |
| 0100d63e | kbd_d_up_alt_l | 38 | known | 0 | 1 | 0 |  |  | copy of kbd_a_up_alt_l |
| 0100d664 | kbd_d_up_alt_r | 24 | known | 0 | 1 | 0 |  |  | copy of kbd_a_up_alt_r |
| 0100d67c | kbd_d_up_capslock | 88 | known | 0 | 1 | 1 |  |  | copy of kbd_a_up_capslock |
| 0100d6d4 | kbd_d_up_help | 68 | known | 0 | 1 | 0 |  |  | copy of kbd_a_up_help |
| 0100d718 | kbd_d_down_ctrl_l | 8 | known | 0 | 1 | 0 |  |  | copy of kbd_a_down_ctrl_l |
| 0100d720 | kbd_d_down_ctrl_r | 34 | known | 0 | 1 | 0 |  |  | copy of kbd_a_down_ctrl_r |
| 0100d742 | kbd_d_down_cmd | 26 | known | 0 | 1 | 0 |  |  | copy of kbd_a_down_cmd |
| 0100d75c | kbd_d_down_shift_l | 24 | known | 0 | 1 | 0 |  |  | copy of kbd_a_down_shift_l |
| 0100d774 | kbd_d_down_shift_r | 10 | known | 0 | 1 | 0 |  |  | copy of kbd_a_down_shift_r |
| 0100d77e | kbd_d_down_alt_l | 30 | known | 0 | 1 | 0 |  |  | copy of kbd_a_down_alt_l |
| 0100d79c | kbd_d_down_alt_r | 14 | known | 0 | 1 | 0 |  |  | copy of kbd_a_down_alt_r |
| 0100d7aa | kbd_d_down_capslock | 96 | known | 0 | 1 | 2 |  |  | copy of kbd_a_down_capslock |
| 0100d80a | kbd_d_down_help | 26 | known | 0 | 1 | 0 |  |  | copy of kbd_a_down_help |
| 0100d824 | kbd_d_event_done | 130 |  | 0 | 126 | 2 |  |  | store event to *evptr, magic key check (reset/NMI), return |
| 0100d8a6 | adb_mouse_init | 224 |  | 1 | 0 | 1 |  |  | (addr,buf): $3e2\|=$10000; talk/listen reg3 handler=3; if ok talk reg1 (8 bytes) then 3 listens reg1; $3e2\|=$20000 |
| 0100d986 | adb_nop | 8 | known | 0 | 0 | 0 |  |  | empty (link/unlk/rts), unreferenced |
| 0100d98e | adb_kbd_present | 28 | known | 0 | 0 | 1 |  |  | returns mg+$3e2 bit 0 (ADB keyboard found); unreferenced |
| 0100d9aa | adb_dev_handler_stub | 8 | known | 0 | 7 | 0 |  |  | empty ADB register-0 data handler used for all device slots except 2 in table 0101b114 |
| 0100d9b4 | scsi_init | 474 | known | 2 | 0 | 3 |  | DMA Controller (Motorola) (writes MUST be 32-bit), device space mirror of $02014 | (mg): alloc softc(0x21e) -> mg+$186; DMA ctrl $22/$20; cfg1 $57; CCF 5 (Turbo); seltimeout $99; sync 5/0; bus reset; cfg1 $17 |
| 0100db8e | scsi_run_cmd | 182 | known | 2 | 0 | 5 | "Didn't complete" |  | (mg,?,sd): mg+$302=scsi_intr; scstart; poll INT_SCSI (bit12) up to 1000x10ms calling scsi_intr; 'Didn't complete'; ret 1 ok |
| 0100dc44 | scsi_start | 266 |  | 1 | 0 | 2 | "scstart: bad state" | device space mirror of $02014000 = SCSI Controller (NCR53C90A) | (softc,sd) scstart: CDB len by group, control byte must be 0; FIFO <- IDENTIFY(lun)\|$80 + CDB; ESP cmd $42 SELATN |
| 0100dd4e | scsi_intr | 258 |  | 1 | 1 | 2 | "software error"; "parity error" | device space mirror of $02014000 = SCSI Controller (NCR53C90A) | (softc) scintr: DMA flush ($3c/$38 x3) if state 4; read status/seqstep/intstatus; bus reset wait; dispatch on state tab 01012a3c |
| 0100de50 | scsi_intr_selected | 54 | known | 0 | 1 | 0 |  |  | state 1: DC -> sd state 1 (no target); seqstep 2/4 and intstatus $18 -> state 2 (phase dispatch) else 'selection failed' |
| 0100de86 | scsi_intr_state6 | 20 |  | 0 | 1 | 0 | "selection failed" |  | state 6 (after PAD transfer): go to phase dispatch |
| 0100de9a | scsi_intr_dma_done | 72 | known | 0 | 1 | 1 | "bus error" |  | state 4: resid = ESP count regs; update $214/$218; dma_cleanup; softc+$2c & $4000 -> 'bus error' |
| 0100dee2 | scsi_intr_status | 60 | known | 0 | 1 | 0 | "target aborted"; "fifo level" |  | state 3 (after ICCS $11): DC -> 'target aborted'; FC and fifo==2 -> status byte to sd+$1c, msg byte to $21c, msgin |
| 0100df1e | scsi_intr_msgin | 64 | known | 0 | 1 | 2 | "target aborted2"; "msgin fifo level" |  | state 7 (after TI $10 in MSG IN): fifo must be 1 -> msg byte to softc+$21c, call sub_0100e11e |
| 0100df5e | scsi_intr_complete | 22 | known | 0 | 1 | 0 |  |  | state 5: softc state 0, current sd cleared, sd+$18 = resid, sd+$1d = 2 (done) |
| 0100df74 | scsi_intr_bad_state | 42 |  | 0 | 2 | 2 | "scintr program error" |  | states 0/2: print 'scintr program error' |
| 0100df9e | scsi_phase_dispatch | 70 |  | 1 | 0 | 0 | "SCSI command phase" | device space mirror of $02014000 = SCSI Controller (NCR53C90A), device space mir | (softc): ESP cmd 1 (flush FIFO); phase = status&7 -> tab 01012a5c (DATA OUT/IN, STATUS, MSG IN; others error) |
| 0100dfe4 | scsi_phase_data_out | 122 | known | 0 | 1 | 2 | "SCSI bad i/o direction" |  | DATA OUT: dir must be write; count 0 -> PAD $98 state 6; else dma_setup/start, ESP count, cmd $90 (DMA TI), DMA ctrl $30 |
| 0100e05e | scsi_phase_datain | 136 | known | 0 | 1 | 2 | "SCSI bad i/o direction" |  | DATA IN phase: set up DEV2M DMA chain, ESP count, cmd $90 DMA-xfer, ESP_DMA_CTRL=$38 (or pad if count 0) |
| 0100e0e6 | scsi_phase_status | 14 | known | 0 | 1 | 0 |  |  | STATUS phase: sc state=3, ESP cmd $11 (Initiator Command Complete) |
| 0100e0f4 | scsi_phase_msgin | 18 | known | 0 | 1 | 0 |  |  | MESSAGE IN phase: sc state=7, ESP cmd $10 (Transfer Information, PIO) |
| 0100e106 | scsi_phase_msgout_err | 6 | known | 0 | 1 | 0 | "SCSI msgout phase" |  | MESSAGE OUT phase is unexpected: abort with 'SCSI msgout phase' |
| 0100e10c | scsi_phase_error | 18 |  | 0 | 0 | 1 |  |  | common tail of the phase handlers: scsi_abort(sc, msg) |
| 0100e11e | scsi_msgin_done | 106 |  | 1 | 0 | 2 | "scmsgin: no current sd"; "SCSI unexpected msg:%d\n"; "Unexpected msg" | device space mirror of $02014000 = SCSI Controller (NCR53C90A) | after MSG IN byte: expect COMMAND COMPLETE (0) and FUNCCMPLT, state=5, ESP cmd $12 (Message Accepted) |
| 0100e188 | scsi_abort | 100 |  | 6 | 0 | 3 | "sc: %s\n" | device space mirror of $02014020 = SCSI DMA Control/Status Registers | print 'sc: %s', stop SCSI DMA (ESP_DMA_CTRL=$20), mark sd disconnected, reset ESP via sub_0100d9b4(0,0) |
| 0100e1ec | sd_open | 260 | known | 0 | 1 | 8 | "SCSI Bus Hung\n"; "no SCSI disk\n"; "booting SCSI target %d, lun %d\n" |  | devops[0]: alloc sd (mg+$17e), reset ESP, find n-th target by INQUIRY, START UNIT, READ CAPACITY -> bd blksize/nblocks |
| 0100e2f0 | sd_close | 8 |  | 1 | 1 | 0 |  |  | devops[1]: no-op |
| 0100e2f8 | sd_find_target | 94 |  | 1 | 0 | 1 |  |  | scan targets 0..6 with INQUIRY; return the unit-th responding target or -1 (stops on bus hung) |
| 0100e356 | sd_inquiry | 180 |  | 1 | 0 | 2 |  |  | INQUIRY $12 len $42 into sd data buf; ok if device type 0,4,5,7,8; 3 tries |
| 0100e40a | sd_read_capacity | 144 |  | 1 | 0 | 3 | "READ CAPACITY" |  | READ CAPACITY $25 (8 bytes) into sd data buf; returns buf ptr (last LBA, blk len) or 0; 3 tries |
| 0100e49a | sd_request_sense | 174 |  | 1 | 0 | 4 | "REQ SENSE" |  | REQUEST SENSE $03 len 14 into sd data buf; 3 tries; 1 s delay on BUSY |
| 0100e548 | sd_start_unit_wait_ready | 254 |  | 1 | 0 | 5 | "waiting for drive to come ready" |  | START STOP UNIT $1b (Immed, Start) then TEST UNIT READY loop; prints 'waiting for drive to come ready' + dots |
| 0100e646 | sd_read | 224 | known | 0 | 1 | 4 | "bad dev blk size %d\n"; "READ" |  | devops[2](mg,bd,blkno,addr,len): READ(6) $08 via DMA, len must be multiple of blksize, 3 tries; returns bytes or -1 |
| 0100e726 | sd_write_stub | 8 | known | 0 | 1 | 0 |  |  | devops[3]: no-op (no write support in ROM) |
| 0100e72e | sd_label_blkno | 34 | known | 0 | 1 | 0 |  |  | devops[4](mg,bd,size,i): block number of disk-label copy i = ceil(size/blksize)*i |
| 0100e750 | sd_command | 158 |  | 5 | 0 | 4 | "sdcmd bad state: %d\n" |  | issue sd CDB via sub_0100db8e; on CHECK CONDITION do REQUEST SENSE, on BUSY wait 1 s; returns 1 ok / 0 fail |
| 0100e7ee | sd_print_error | 222 |  | 3 | 0 | 1 | "Selection timeout on target\n"; "Failed, sense key: 0x%x\n"; "Target busy\n" |  | print '%s: ' + selection timeout / sense key / busy / disconnected / driver refused message |
| 0100e8cc | dma_init | 126 |  | 3 | 0 | 1 |  |  | CSR=DMA_RESET, clear flags, sc+$38=16-byte scratch, sc+$e4=8K-aligned bounce buffer at top-of-RAM-64K |
| 0100e94a | dma_setup_chain | 272 |  | 5 | 0 | 1 |  |  | (sc,chain,addr,len,dir): build 2-entry chain in bounce buffer (+scratch tail), copy data for M2DEV |
| 0100ea5a | dma_cleanup | 114 |  | 2 | 0 | 3 | "dma_cleanup: negative resid" |  | (sc,resid): dma_stop, copy scratch tail back, copy bounce buffer to caller for DEV2M |
| 0100eacc | dma_start | 196 |  | 5 | 0 | 2 | "dma_start: bad DMA buffer alignm" |  | (sc,chain,dir): CSR=dir\|RESET\|BUFRESET, load next/limit(+start/stop), CSR=dir\|SETENABLE(\|SETSUPDATE) |
| 0100eb90 | dma_stop | 52 |  | 5 | 0 | 0 |  |  | save CSR status bits (sc+$24), CSR=DMA_RESET, save 'next' reg (sc+$28), clear flags |
| 0100ebc4 | boot_fs_open | 138 | known | 0 | 1 | 1 |  |  | fsops[0]: alloc 8K-aligned label buffer (mg+$182) + 8K sector cache, call devops[0] open |
| 0100ec4e | boot_fs_load | 224 | known | 0 | 1 | 3 | "Bad label\n"; "No bootfile in label\n"; "dev blk len %d, fs sect %d\n" |  | fsops[2]: skip name to flags, read+check label, pick bootfile, load boot block 0/1 and run it |
| 0100ed2e | boot_read_label | 150 |  | 1 | 0 | 4 |  |  | try label copies 0..3: read $1c48 bytes at devops[4] blkno, validate with boot_check_label |
| 0100edc4 | boot_check_label | 144 |  | 1 | 0 | 2 | "Bad version 0x%x\n"; "Bad blkno\n"; "Bad cksum\n" |  | NeXT/dlV2 ($1c48 B) or dlV3 ($230 B): check version, label_blkno and 16-bit checksum |
| 0100ee54 | boot_exec_blk0 | 252 |  | 1 | 0 | 5 | "short read\n" |  | (mg,bd,byteoff): read 1 KB, parse a.out/Mach-O header, load image, build 'dev(c,u,p)file' and jump |
| 0100ef50 | boot_fs_seek | 22 |  | 2 | 0 | 0 |  |  | set current byte offset (labelbuf+$1c50) |
| 0100ef66 | boot_fs_read | 222 |  | 3 | 0 | 0 |  |  | (mg,bd,dst,len): read through 8 KB block cache via devops[2]; returns len or -1 ('short read' by caller) |
| 0100f044 | boot_fs_close | 28 | known | 0 | 1 | 0 |  |  | fsops[1]: call devops[1] close |
| 0100f060 | od_ctrl_init | 262 |  | 1 | 0 | 4 | "no optical disk\n" | DMA Controller (Motorola) (writes MUST be 32-bit), System Control Register 1 | (regs,ctrl,quiet,nowait): probe OSP at $02112000, alloc od softc mg+$18a, write init/format/mark/flags regs, DMA $02000050 |
| 0100f166 | od_volume_init | 200 |  | 1 | 0 | 4 | "Canon OMD-1"; "no valid disk label found\n" |  | alloc od volume struct mg+$18e, drive type 'Canon OMD-1', read label via sub_010100aa, bd blksize=1024 |
| 0100f22e | od_label_blkno | 22 | known | 0 | 1 | 0 |  |  | devops[4](.,.,.,i): label copy sector from table $0101b358 (0, $3c460, -1, -1) |
| 0100f244 | od_open | 124 |  | 2 | 1 | 3 | "bad ctrl or unit number\n" | device space mirror of $02012000 = GPIO Register | devops[0]: refuse on machine type 1/3, ctrl must be 0, unit <=1, od_ctrl_init + od_volume_init |
| 0100f2c0 | od_close | 8 | known | 0 | 1 | 0 |  |  | devops[1]: no-op |
| 0100f2c8 | od_read | 54 | known | 0 | 1 | 1 |  |  | devops[2](mg,bd,blkno,addr,len): sub_01010004(cmd 2 read, ..., flags $80000); returns len |
| 0100f2fe | od_write_stub | 8 | known | 0 | 1 | 0 |  |  | devops[3]: no-op |
| 0100f306 | od_strategy | 84 |  | 1 | 0 | 2 |  |  | (iob,flag): len must be multiple of sector size else error $16; od_start_io |
| 0100f35a | od_start_io | 134 |  | 1 | 0 | 1 |  |  | copy iob sector/addr/len into od softc ($4254/$210/$4260/$4264), clear retry counters, dispatch cmd 1 |
| 0100f3e0 | od_cmd_dispatch | 90 |  | 3 | 0 | 1 |  |  | (od,vol,cmd,iob): od+$4281=cmd, clear bits 30/29, jump via table $01012a7c[cmd-1] |
| 0100f43a | od_cmd_start | 562 | known | 0 | 1 | 3 |  |  | cmd 1: clip chunk to track/alt-group, compute physical track+sector, select head or spiral-on/RID/eject |
| 0100f66c | od_cmd_seek_low | 42 | known | 0 | 1 | 0 |  |  | cmd 2: send DRV_SEK (track & $fff) with head-select pending, next cmd from table $0101b3b2 |
| 0100f696 | od_cmd_resume | 22 | known | 0 | 1 | 0 |  |  | cmd 8: clear bit 23 and re-dispatch saved cmd od+$4285 |
| 0100f6ac | od_cmd_fail_ret | 6 | known | 0 | 1 | 0 |  |  | cmd 12: return -1 |
| 0100f6b2 | od_cmd_check_motor | 72 | known | 0 | 1 | 3 |  |  | cmd 13: DRV_RDS; if DS_STOPPED send DRV_STM start motor (cmd $e) else finish (cmd 14) |
| 0100f6fa | od_cmd_finish | 28 |  | 0 | 1 | 0 |  |  | cmd 14: clear bits 24/17, mark iob done (\|=2) |
| 0100f716 | od_cmd_after_eject | 30 | known | 0 | 1 | 0 |  |  | cmd 7: clear vol bits 15/14, od bit 23; bit 12 -> error finish else next chunk |
| 0100f734 | od_cmd_next_chunk | 68 |  | 0 | 1 | 1 |  |  | cmd 5: sectors -= done; advance addr/sector and re-run cmd 1, or mark iob done |
| 0100f778 | od_cmd_error_finish | 30 |  | 0 | 1 | 1 |  |  | cmd 6: print 'failed', iob+$1c=error code, iob \|= 6 |
| 0100f796 | od_cmd_xfer | 70 |  | 0 | 5 | 2 |  |  | cmd 3/4/9/10/11: write track hi/lo, sector\|$10, count to OSP regs, od_issue, od_complete |
| 0100f7dc | od_complete | 768 |  | 2 | 0 | 5 |  |  | read/clear OSP int status + err stat, map to error code, read drive status, retry/restore/re-spin/eject logic |
| 0100fadc | od_issue | 292 |  | 3 | 0 | 5 |  |  | start MO DMA (chain, dir by op), send pending drive cmd or CSR2, write formatter cmd to CSR1, poll DMA complete |
| 0100fc00 | od_drive_cmd | 236 |  | 8 | 0 | 2 |  |  | (od,vol,cmd16,flags): CSR2=drive sel\|$80, wait CMD_COMPL, write CSR_H/CSR_L, wait; err $3a/$3b on timeout |
| 0100fcec | od_print_error | 218 |  | 5 | 0 | 1 | "read"; "write"; "erase" |  | (od,action): 'od%d%c: %s %s (%s) trk:0:sec' using op name and error table $0101b1d8 |
| 0100fdc6 | od_read_drive_status | 420 |  | 1 | 0 | 2 |  |  | DRV_RDS/RES/RHS status words -> od+$4266/$4268/$426a, map error bits via tables, then DRV_RID |
| 0100ff6a | od_drive_query | 152 |  | 6 | 1 | 2 |  |  | (od,vol,regs,cmd,flags): send drive cmd, 40 us, CSR1=$20 read-status, return 16-bit reply from CSR_H/L |
| 01010002 | stub_rts | 2 |  | 0 | 3 | 0 |  |  | bare rts; only reached through pointer tables at 0100cbec/0100d004/0100d88a |
| 01010004 | od_cmd | 166 |  | 4 | 1 | 3 |  |  | OD driver: queue op (F0 probe, F1 eject, 2 read) in od cmd block, poll done; 0 ok / 5 err+status |
| 010100aa | od_read_label | 366 |  | 1 | 0 | 4 | "Canon OMD-1" |  | OD: probe drive (op F0), then read label at each candidate block, verify; 0 ok, 1/2/3 drive err, 4 no label |
| 01010218 | disk_label_check | 102 |  | 1 | 0 | 1 |  |  | verify NeXT disk label: magic NeXT/dlV2 (sum @1c46) or dlV3 (sum @22e), blkno match; 0 ok / -1 |
| 0101027e | od_eject | 144 |  | 3 | 0 | 3 |  |  | on machine type 0/2 open OD (ctrl 1) and issue op F1 (eject); returns 0 or -1 |
| 0101030e | od_reset | 62 |  | 1 | 0 | 2 |  | device space mirror of $02012000 = GPIO Register | machine type 0/2 only: write 1 (MOINT_RESET) to MO int-status $02112004, wait 100, write 0 |
| 0101034c | od_query_status | 132 |  | 1 | 0 | 3 |  |  | machine type 0/2: open OD, run sub_0100ff6a(od,$2000,9), return bit14 of result (uncertain) |
| 010103d0 | fd_probe_media | 402 |  | 1 | 0 | 7 | "fd: RECALIBRATE FAILED\n"; "fd: CONTROLLER I/O ERROR\n"; "RECALIBRATE FAILED\n" |  | recalibrate x2, read media id, autodetect density 3..1 x secsize 512/1024 by test reads; 0/1/3/4 |
| 01010562 | fd_open | 286 |  | 1 | 1 | 6 | "No Floppy Disk Drive\n"; "No Floppy Disk Present\n"; "Floppy Disk not Formatted\n" | device space mirror of $02014100 = Floppy Controller (Intel 82077AA) | device-switch open: alloc fcp ($704) at mg+$3a4, fc_init, fd_probe_media, print fd errors, fill size |
| 01010680 | fd_close | 8 |  | 1 | 1 | 0 |  |  | device-switch entry: empty |
| 01010688 | fd_read | 78 | known | 0 | 1 | 1 |  |  | device-switch read(mg,x,sector,buf,len): fd_setup_io(fvp,sector,len/secsize,buf,read); bytes done or -1 |
| 010106d6 | fd_write_nop | 8 | known | 0 | 1 | 0 |  |  | device-switch entry: empty (ROM never writes floppies) |
| 010106de | fd_round_to_sectors | 34 | known | 0 | 1 | 0 |  |  | device-switch entry: ceil(len/secsize)*arg |
| 01010700 | fd_eject | 90 |  | 2 | 0 | 3 |  |  | monitor eject: fd_open(ctrl1,unit,noprobe,quiet) then fd_simple_cmd(fvp,2=EJECT) |
| 0101075a | fd_raw_cmd | 98 |  | 4 | 0 | 2 |  |  | copy cmd block into fvp+8, set raw flag, run fd_run_io, copy back; -1 on error |
| 010107bc | fd_run_io | 82 |  | 2 | 0 | 2 |  |  | fd state machine: set retries (2 retry,1 recal), state=1, loop fc_start until state 0; returns bytes left |
| 0101080e | fd_intr | 144 |  | 1 | 0 | 0 |  |  | completion: account bytes moved, then switch on cmd status (table 01012ab4) |
| 0101089e | fd_intr_ok | 68 | known | 0 | 1 | 1 | "fd_intr: BOGUS fvp->state" |  | cmd status 0: state 2->1, 3->2; continue if bytes remain else state 0 |
| 010108e2 | fd_intr_error | 142 | known | 0 | 10 | 3 | "RECALIBRATE"; "RETRY"; "FATAL" |  | cmd status err: RETRY, then RECALIBRATE, then FATAL (prints fd%d: Sector %d ...) |
| 01010970 | fd_intr_fatal | 24 |  | 0 | 6 | 1 | "FATAL" |  | unknown cmd status: print FATAL and stop |
| 01010988 | fd_print_error | 64 |  | 4 | 0 | 1 | "fd%d: Sector %d(d) cmd = %s; sta" |  | printf fd%d: Sector %d(d) cmd = Read/W; status = %d: %s |
| 010109c8 | fd_start_transfer | 154 |  | 3 | 0 | 2 |  |  | limit chunk to end of track, save sector/len/buf, build R/W command |
| 01010a62 | fd_build_rw_cmd | 232 |  | 2 | 0 | 2 |  |  | 82077 READ(06)/WRITE(05) DATA cmd bytes MT=0 MFM,C,H,R,N,EOT,GPL,DTL=ff; 9 bytes, 7 results |
| 01010b4a | fd_setup_io | 72 |  | 1 | 0 | 1 |  |  | fvp: sector, buffer, nsectors*secsize, read flag (bit0 of fvp+$92) -> fd_run_io |
| 01010b92 | fd_probe_read | 86 |  | 1 | 0 | 3 |  |  | read nsectors at sector into buffer via raw cmd (used by fd_probe_media) |
| 01010be8 | fd_sense_media | 62 |  | 1 | 0 | 2 |  |  | raw cmd type 5 (no 82077 cmd): returns media-id/motor byte in *arg |
| 01010c26 | fd_recalibrate | 46 |  | 2 | 0 | 2 |  |  | build RECALIBRATE(07) cmd and run it as raw cmd |
| 01010c54 | fd_simple_cmd | 62 |  | 2 | 0 | 2 |  |  | raw cmd of type arg (2=eject, 4=motor off) with 10ms timeout |
| 01010c92 | fd_build_recal_cmd | 78 |  | 2 | 0 | 0 |  |  | cmd bytes 07,drive; timeout 1000, 2 cmd bytes, 2 result bytes |
| 01010ce0 | fd_lba_to_chs | 86 |  | 2 | 0 | 0 |  |  | C=lba/spt/heads, H=(lba/spt)%heads, R=lba%spt+1 into cmd bytes 2..4 |
| 01010d36 | fd_vol_init | 58 |  | 1 | 0 | 1 |  |  | zero fvp ($c2), density=2, unit, flags |
| 01010d70 | fd_set_density | 74 |  | 2 | 0 | 0 |  |  | copy 14-byte entry for density key from dat_0101b448 to fvp+$a8 (capacity,GPL,MFM) |
| 01010dba | fd_set_geometry | 90 |  | 2 | 0 | 0 |  |  | secsize -> spt = cap/(heads*cyls)/secsize, total = heads*spt*cyls; mark geometry valid |
| 01010e14 | fc_init | 130 |  | 1 | 0 | 2 |  | DMA Controller (Motorola) (writes MUST be 32-bit), device space mirror of $02014 | fcp: 82077 base $02114100, ext ctrl $02114108=$40, fc_reset, DMA chan CSR $02000010, ESP DMA ctrl $02114020 |
| 01010e96 | fc_start | 164 |  | 1 | 0 | 1 |  |  | run cmd block: select drive in DOR, dispatch cmd type 1..5 (table 01012af8), media status, hang check |
| 01010f3a | fc_start_type1 | 14 | known | 0 | 1 | 1 |  |  | cmd type 1: fc_do_command |
| 01010f48 | fc_start_type2 | 16 | known | 0 | 1 | 1 |  |  | cmd type 2: fc_eject, fvp state=2 |
| 01010f58 | fc_start_type3 | 10 | known | 0 | 1 | 1 |  |  | cmd type 3: fc_motor_on |
| 01010f62 | fc_start_type4 | 20 | known | 0 | 1 | 1 |  |  | cmd type 4: fc_motor_off |
| 01010f76 | fc_start_type5 | 152 | known | 0 | 1 | 3 | "Bad Controller Phase"; "Controller hang" |  | cmd type 5: no controller command, status 0 |
| 0101100e | fc_intr | 202 |  | 1 | 0 | 2 |  |  | floppy IRQ service: flush ESP DMA (x1/x8), wait RQM; DIO=0 -> send SENSE INT (08) else read ST0 |
| 010110d8 | fc_reset | 170 |  | 5 | 0 | 4 | "fc: Controller Reset: %s\n"; "Sony MPX-111N" |  | print fc: Controller Reset, DOR=0, 250us, DOR=4, DSR=0, CCR=0, ext ctrl=$40, fc_configure, fc_specify |
| 01011182 | fc_send_byte | 46 |  | 2 | 0 | 1 |  |  | wait RQM&DIO=0 then write FIFO $02114105 |
| 010111b0 | fc_get_byte | 44 |  | 1 | 0 | 1 |  |  | wait RQM&DIO=1 then read FIFO into *arg |
| 010111dc | fc_wait_rqm | 84 |  | 2 | 0 | 0 |  |  | poll MSR up to 80000x for RQM; 0 ok, 1 = poll count hit $3e80, $a = DIO mismatch (phase) |
| 01011230 | fc_ctrl_set | 30 |  | 1 | 0 | 0 |  |  | ext control $02114108 \|= arg (shadow fcp+$10) |
| 0101124e | fc_ctrl_clr | 32 |  | 1 | 0 | 0 |  |  | ext control $02114108 &= ~arg (shadow fcp+$10) |
| 0101126e | fc_read_media_status | 76 |  | 1 | 0 | 0 |  |  | cmd+$4e: bit5 = DOR motor bit for drive, bits7:6 = ext status media id |
| 010112ba | fc_configure | 84 |  | 2 | 0 | 2 |  |  | 82077 CONFIGURE 13 00 58 00 (EIS, FIFO on, no poll, thr 8) via fc_send_cmd |
| 0101130e | fc_specify | 382 |  | 2 | 0 | 3 | "fd: Bogus density (%d) in fc_spe" |  | SPECIFY 03 SRT/HUT HLT from drive table; DSR/CCR rate 2/0/3 for density 1/2/3; else Bogus density |
| 0101148c | fc_do_command | 170 |  | 1 | 0 | 2 | "Sony MPX-111N" |  | type 1: OR drive into cmd byte1, specify if density changed, motor on for r/w ops, send |
| 01011536 | fc_cmd_motor_on | 30 | known | 0 | 10 | 1 |  |  | opcodes needing spindle: fc_motor_on, ext status bit2 set -> status 5 (no drive) |
| 01011554 | fc_cmd_send | 24 |  | 0 | 11 | 1 |  |  | fc_send_cmd and store status in cmd+$3e |
| 0101156c | fc_eject | 170 |  | 1 | 0 | 8 |  |  | motor on, SEEK cyl 79, ext ctrl \|= $80 then &= ~$80, wait 2s, motor off |
| 01011616 | fc_build_seek_cmd | 90 |  | 1 | 0 | 0 |  |  | SEEK 0F, head<<2, cyl; timeout 400, 3 cmd bytes, 2 results |
| 01011670 | fc_motor_on | 60 |  | 3 | 0 | 1 |  |  | DOR \|= $10<<drive if not already, wait 500ms |
| 010116ac | fc_motor_off | 38 |  | 2 | 0 | 0 |  |  | DOR &= ~($10<<drive) |
| 010116d2 | fc_send_cmd | 402 |  | 4 | 0 | 6 | "fc_send_cmd: Error sending comma" |  | set up DMA (ESP ctrl $08=dev->mem,$10 dma), send cmd bytes, wait IRQ/immediate, results, check |
| 01011864 | fc_cmd_wait_intr | 26 |  | 0 | 22 | 1 |  |  | opcodes with execution phase: fd_wait_intr(timeout ms*1000) |
| 0101187e | fc_cmd_result_phase | 362 |  | 0 | 7 | 5 | "fc_send_cmd: Error getting statu" |  | after exec: pulse ESP flush (x1/x8), clear DMA mode; then result bytes and DMA accounting |
| 010119e8 | fc_check_rw_result | 60 | known | 0 | 3 | 0 |  |  | ok if IC=0, or ST1==$80, or IC=$40 + all bytes DMAed + ST1.OR; else 8; no results -> $12 |
| 01011a24 | fc_check_seek_result | 32 | known | 0 | 1 | 0 |  |  | ST0 SE set and PCN == requested cyl else status 9 |
| 01011a44 | fc_check_recal_result | 28 | known | 0 | 1 | 0 |  |  | ST0 SE set, PCN 0 and status A TRK0_N low else status 9 |
| 01011a60 | fc_send_cmd_exit | 34 |  | 0 | 6 | 1 |  |  | dma_cleanup(fcp+$12) if DMA was started; return status (1 if timeout) |
| 01011a82 | fc_dma_reset | 102 |  | 2 | 0 | 4 |  |  | dummy 16-byte dev->mem DMA setup/start, 10us, dma_stop: clears the SCSI/floppy DMA channel |
| 01011ae8 | dma_bytes_moved | 132 |  | 1 | 0 | 1 | "dma_bytes_moved: DMA buf overflo" |  | walk up to 10 DMA chain entries against TDMA saved next ptr ($4000 off CSR); bytes done |
| 01011b6c | fd_wait_intr | 130 |  | 3 | 0 | 3 |  |  | poll int status $02007000 for INT_PHONE ($80) up to us/1000 ms; run fc_intr; 1 on timeout |
