# Releases

| file | what | md5 |
|---|---|---|
| `NeXT-Color_20260928.rbf` | **latest.** The 20260927 core plus **sound out** (16-bit stereo, 44.1 / 22.05 kHz, through HDMI and the analog output), the **CD-ROM drive always on the SCSI bus** (a disc can be inserted while NeXTSTEP runs), and more room in the FPGA (no Y/C encoder, no OSD on the analog output). **No DSP56001** (`NEXT_NO_DSP`: parked). RTL 09a0e78, seed 8 (58f4ec9), timing met (worst +0.104 ns, hold +0.191 ns), 38,788 ALMs (93%) | `9233cdfa8f1320063529a0b0cd1b7fe5` |
| `NeXT-Color_20260927.rbf` | The 20260926 core plus the **2.88 MB floppy** (82077, OSD "Floppy"; 720K/1.44M/2.88M images) and **Ethernet** (OSD "Ethernet: Connected": the 7213 on the LAN through Main's `next_enet` daemon, eth0 shared). RTL 2cd616c, seed 2, timing met (worst +0.231 ns), 38,548 ALMs (92%) | `b54060fa9c5bd3dfeedcc7254ef00e33` |
| `NeXT-Color_20260926.rbf` | M4 (SCSI + DMA), the T7213 Ethernet model (loopback only), palette/timing rewrites, and the CPU page-end prefetch fault fix (NeXTSTEP `cc` / NWBench Compile work); RTL 6d2e1a5, seed 1, timing met (worst +0.208 ns, hold +0.246 ns), 37,483 ALMs (89%) | `6382ea7ac8ca4b092ec7bce670b924e8` |
| `MiSTer` | Main_MiSTer f2d08a5 (`is_next()` matches "NeXT-Color": SCSI disks, the CD-ROM and the Ethernet daemon; no DSP code), the tip of branch `next-color-support` (master + this commit, the PR branch) | `50aff88c5cddeccb19e1b0db33c02af4` |
| `boot0.rom` | NeXT ROM Rev 3.3 v74 | `dadf3fb6b6b18b2d325eb42b61d83175` |

Install: the rbf in `_Unstable/` (or `_Computer/`) as `NeXT-Color.rbf`, `boot0.rom` in
`games/NeXT-Color/`, and `MiSTer` as `/media/fat/MiSTer` (keep the old one, `sync`,
reboot).  A NeXTSTEP disk image goes in the OSD's "SCSI disk 0" slot; set "Boot
device" to "SCSI disk".  See the top-level Readme for the 1080p display setup.
Load the core directly, not through an .mgl file (an MGL load corrupted the
remembered disk mount, `config/NeXT-Color.s0`).

## 20260928: sound out, the CD-ROM on the bus, no DSP (verified on the MiSTer)

- **Sound out**: NeXTSTEP's sounds play through the MiSTer's HDMI and analog
  audio: 16-bit linear, 44.1 kHz, and 22.05 kHz doubled as on the real
  machine; the keyboard's volume keys work.  Verified: `sndplay` of the
  system sounds (`/NextLibrary/Sounds`).
- **CD-ROM**: the drive answers on SCSI target 3 even without a disc
  (NOT READY), so NeXTSTEP attaches it at boot ("PreviousCD-ROM Rev 1 as sd1")
  and a disc image mounted in the OSD's "CD-ROM" slot while NeXTSTEP runs
  appears in the Workspace.
- **No DSP56001**: its registers read 0 and NeXTSTEP attaches no `dsp0`, as
  in the releases before; programs that need the DSP (the Music Kit, sounds
  NeXTSTEP decodes on the DSP) do not work.  A DSP on the ARM exists in the
  source (see the top-level Readme, "Sound and DSP") but is parked.
- **Main**: unchanged, `MiSTer` below (f2d08a5, md5 50aff88c).  A Main from
  `next-color` with the DSP also works with this core (its DSP thread idles).
- Checked on the MiSTer (2026-09-28): cold start after a MiSTer reboot, the
  POST, NeXTSTEP 3.3 boot and root login, `sndplay` of Basso and Glass; the
  kernel lists en0, np0, sound0 and no dsp0.  Once, the first load right
  after swapping Main and rebooting stayed black (no POST); loading it again
  worked, and a later cold start came up normally.

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
