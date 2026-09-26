#!/usr/bin/env python3
"""Sim-only fast-boot variant of the Rev 3.3 v74 ROM (never for hardware).

The real ROM spends ~10M clk_sys cycles on its CRC-32, ~45M on the 2 MB VRAM
test and 25M on a 750 ms delay before video enable -- over two minutes of
simulation before anything new happens.  This patches those out so later boot
stages can be iterated on quickly; the full-ROM run stays the reference (the
same idea as MacQuadra800's make-fastboot-rom.sh).  Every patch checks the
original bytes first.  Addresses: rom-dissassembly/Rev_3.3_v74.asm.

    python3 scripts/make_fastboot_rom.py releases/boot.rom verilator/rom_fast.hex
"""
import sys

BASE = 0x01000000

PATCHES = [
    # $010003D2 reset_int_mask_crc: after the interrupt-mask clear, skip both
    # CRC-32 passes and their compares; land at $0100042E (reset_pick_stack's
    # machine-type dispatch).  movea.l #reset_entry,a1 -> jmp $0100042E.l
    (0x010003D2, "227c0100001e", "4ef90100042e", "skip the ROM CRC-32 checks"),
    # $01003AFA vid_vram_test: after its mg_init_machine setup, go straight to
    # the success exit loc_01003bd4 (clr.l d0; bra exit).  cmpi.l #$139,$194(a2)
    # -> bra.w loc_01003bd4 ; (4 bytes of the old instruction left, unreachable)
    (0x01003AFA, "0caa00000139", "600000d84e71", "skip the 2 MB VRAM pattern test"),
    # $0100AD02 vid_console_init: delay_us(750000) before video enable -> 1000 us
    (0x0100AD02, "2f3c000b71b0", "2f3c000003e8", "750 ms video-enable delay -> 1 ms"),
    # $0100DB66 scsi_init: delay_us(2000000) after the SCSI bus reset
    # command (HS 9.2 step 8) -> 1000 us; the sim's targets answer at once
    (0x0100DB66, "2f3c001e8480", "2f3c000003e8", "2 s SCSI bus-reset settle -> 1 ms"),
    # $010012EA mon_init: the TEST_DRAM (POT $10) branch around
    # mem_test_all_t -> always taken (beq.b -> bra.b loc_01001320), so a
    # --pot-on run gets to the POST proper instead of testing 64 MB
    (0x010012EA, "6734", "6034", "skip the TEST_DRAM main memory test"),
]

def main():
    src, dst = sys.argv[1], sys.argv[2]
    rom = bytearray(open(src, "rb").read())
    assert len(rom) == 128 * 1024, "expected a 128 KB image"
    for addr, old, new, what in PATCHES:
        off = addr - BASE
        o = bytes.fromhex(old)
        n = bytes.fromhex(new)
        assert len(o) == len(n)
        if rom[off:off + len(o)] != o:
            raise SystemExit("patch at %08X: expected %s, found %s" % (addr, old, rom[off:off + len(o)].hex()))
        rom[off:off + len(n)] = n
        print("patched %08X: %s" % (addr, what))
    with open(dst, "w", newline="\n") as f:
        for i in range(0, len(rom), 4):
            f.write(rom[i:i + 4].hex() + "\n")
    print("-> %s" % dst)

if __name__ == "__main__":
    main()
