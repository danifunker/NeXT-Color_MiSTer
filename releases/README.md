# Releases

| file | what | md5 |
|---|---|---|
| `NeXT-Color_20260926.rbf` | the core: M4 (SCSI + DMA), the T7213 Ethernet model, palette/timing rewrites, and the CPU page-end prefetch fault fix (NeXTSTEP `cc` / NWBench Compile work); RTL 6d2e1a5, seed 1, timing met (worst +0.208 ns, hold +0.246 ns), 37,483 ALMs (89%) | `6382ea7ac8ca4b092ec7bce670b924e8` |
| `MiSTer_20260926` | Main_MiSTer, branch `next-color` f2d08a5 (`is_next()` matches "NeXT-Color"; required for SCSI disks) | `50aff88c5cddeccb19e1b0db33c02af4` |
| `boot.rom` | NeXT ROM Rev 3.3 v74 (`games/NeXT-Color/boot.rom` on the MiSTer) | `dadf3fb6b6b18b2d325eb42b61d83175` |

Install: the rbf in `_Unstable/` (or `_Computer/`) as `NeXT-Color.rbf`, `boot.rom` in
`games/NeXT-Color/`, and `MiSTer_20260926` as `/media/fat/MiSTer` (keep the old one,
`sync`, reboot).  A NeXTSTEP disk image goes in the OSD's "SCSI disk 0" slot; set
"Boot device" to "SCSI disk".  See the top-level Readme for the 1080p display setup.

Replaces the first 20260926 build (a73ffaf seed 3, md5 34396054), whose CPU hung
every `cc` in a translation-fault loop (docs/OPEN-QUESTIONS.md 39).  The full NWBench
suite runs on this one on the MiSTer.

The build before those (a56f083, a different fitter seed, timing missed by
0.138 ns) booted NeXTSTEP 3.3 to the colour login window on the MiSTer on
2026-09-26 (`docs/img/hw_a56f083_*.png`).
