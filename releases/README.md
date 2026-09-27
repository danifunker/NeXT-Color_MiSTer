# Releases

| file | what | md5 |
|---|---|---|
| `NeXT-Color_20260927.rbf` | **latest.** The 20260926 core plus the **2.88 MB floppy** (82077, OSD "Floppy"; 720K/1.44M/2.88M images) and **Ethernet** (OSD "Ethernet: Connected": the 7213 on the LAN through Main's `next_enet` daemon, eth0 shared). RTL 2cd616c, seed 2, timing met (worst +0.231 ns), 38,548 ALMs (92%) | `b54060fa9c5bd3dfeedcc7254ef00e33` |
| `NeXT-Color_20260926.rbf` | M4 (SCSI + DMA), the T7213 Ethernet model (loopback only), palette/timing rewrites, and the CPU page-end prefetch fault fix (NeXTSTEP `cc` / NWBench Compile work); RTL 6d2e1a5, seed 1, timing met (worst +0.208 ns, hold +0.246 ns), 37,483 ALMs (89%) | `6382ea7ac8ca4b092ec7bce670b924e8` |
| `MiSTer` | Main_MiSTer, branch `next-color` f2d08a5 (`is_next()` matches "NeXT-Color": SCSI disks, the CD-ROM and the Ethernet daemon) | `50aff88c5cddeccb19e1b0db33c02af4` |
| `boot0.rom` | NeXT ROM Rev 3.3 v74 | `dadf3fb6b6b18b2d325eb42b61d83175` |

Install: the rbf in `_Unstable/` (or `_Computer/`) as `NeXT-Color.rbf`, `boot0.rom` in
`games/NeXT-Color/`, and `MiSTer` as `/media/fat/MiSTer` (keep the old one, `sync`,
reboot).  A NeXTSTEP disk image goes in the OSD's "SCSI disk 0" slot; set "Boot
device" to "SCSI disk".  See the top-level Readme for the 1080p display setup.
Load the core directly, not through an .mgl file (an MGL load corrupted the
remembered disk mount, `config/NeXT-Color.s0`).

## 20260927: floppy and Ethernet (verified on the MiSTer)

- **Floppy**: mount an image in the OSD "Floppy" slot.  NeXTSTEP attaches the drive
  as `fd0` (Sony MPX-111N); Workspace's Initialize formats a 2.88 MB image, mounts
  it, and files written there land in the image on the SD card.  NeXTSTEP does not
  recognise a DOS file system on a 2.88 MB disk (the sectors read correctly).
- **Ethernet**: set the OSD "Ethernet" to "Connected" (Main's network mode 1: the
  MiSTer's wired eth0, shared, the guest's MAC filtered).  The guest appears on the
  LAN with its own MAC (00:00:0F:12:34:56).  NeXTSTEP 3.3 has no DHCP client: its
  `-AUTOMATIC-` setting is BOOTP, which many routers do not answer, so give it a
  static address (HostManager, or `/etc/hostconfig` INETADDR/IPNETMASK/ROUTER).
  Tested: ping and TCP both ways at 192.168.99.38.  "Disconnected" is the old
  behaviour (no cable: 16 collisions).

## 20260926

Replaces the first 20260926 build (a73ffaf seed 3, md5 34396054), whose CPU hung
every `cc` in a translation-fault loop (docs/OPEN-QUESTIONS.md 39).  The full NWBench
suite runs on this one on the MiSTer.

The build before those (a56f083, a different fitter seed, timing missed by
0.138 ns) booted NeXTSTEP 3.3 to the colour login window on the MiSTer on
2026-09-26 (`docs/img/hw_a56f083_*.png`).
