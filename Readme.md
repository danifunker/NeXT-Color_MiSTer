# NeXT-Color core for MiSTer

## General description
A NeXTstation Turbo Color (33 MHz 68040, Turbo chipset, 12-bit color, 1120x832) core for MiSTer. Work in progress.

* Boot ROM: Rev 3.3 v74, `releases/boot.rom` -> `games/NeXT-Color/boot.rom` on the MiSTer.
* Build: `bash scripts/build_only.sh` (Git bash; `--check` = Analysis & Synthesis only). Machine settings in `scripts/local.env` (from `local.env.sample`).
* Design decisions: `docs/DECISIONS.md`. Hand-off state: the newest `RESUME-*.md`.
* ROM analysis (the RTL spec): `rom-dissassembly/hardware-summary.md`. Hardware references: `RESOURCES.md`.

## Display: use 1080p

The NeXT screen is 1120x832. If `MiSTer.ini` does not set a video mode, the MiSTer
takes the display's preferred mode, often 1280x720. It then has to shrink 832
lines into 720, and the ROM monitor's text comes out smeared. Give the core its
own 1080p section instead:

1. Edit `/media/fat/MiSTer.ini` on the SD card, over SSH or with the card in a PC.
   Keep a copy of the original first, for example `cp MiSTer.ini MiSTer.ini.bak`.
2. Add this section at the end of the file. The section name must match the
   core name exactly.

   ```ini
   [NeXT-Color]
   video_mode=8      ; 1920x1080@60
   vscale_mode=3     ; 0.25 steps: 1.25x = 1400x1040
   vfilter_default=No Interpolation.txt
   ```

3. Load the core again, or reboot the MiSTer. The MiSTer reads the core's
   section each time the core loads.

`vscale_mode=3` lets the scaler use quarter steps, so 832 lines become exactly
1040 (5/4): every fourth pixel and line is repeated, a regular pattern, and the
picture fills 96% of the height. `No Interpolation` keeps those edges hard; the
filter can be changed live in the OSD's video processing menu (for example
`Upscaling - SharpBilinear/SharpBilinear_050.txt` for more even stroke weight).
Without the two extra lines, Normal stretches 832 lines to 1080 (1.298x), which
cannot stay crisp.

Then choose the look in the core's OSD, under **Scale**:

| Scale | Result on 1080p |
|---|---|
| Normal | with `vscale_mode=3`: 1400x1040, an exact 1.25x. Without it: 1454x1080, soft |
| V-Integer | 1:1 pixel-perfect 1120x832, centred with borders. The sharpest text |

If even V-Integer is not razor sharp, the display itself is rescaling the
1080p signal: set it to "Just Scan", "1:1" or PC mode.

**Aspect ratio** "Original" is 1120:832 (35:26), i.e. square pixels, as on the
NeXT display.

To undo the change, delete the `[NeXT-Color]` section. Other `video_mode` values
are listed in the MiSTer.ini that ships with MiSTer (for example `9` is
1920x1080@50).

## Disks

* OSD **SCSI disk 0 / 1** (`.hda`, `.vhd`, `.img`): SCSI targets 0 and 1. The
  mount is remembered (`config/NeXT-Color.s0`/`.s1`) and restored at core start.
  **CD-ROM** (`.iso`, `.cue`/`.bin`, `.chd`) is target 3.
* Set OSD **Boot device** to "SCSI disk" to boot NeXTSTEP from target 0 (the
  NVRAM boot command becomes `sd`), or type `b sd` at `NeXT>`.
* The target responses (INQUIRY, READ CAPACITY, ...) come from the MiSTer's
  Main program: it must be the `next-color` build of Main_MiSTer (its
  `is_next()` accepts this core; `scripts/build_main_wsl.sh`). A stock Main
  finds no disk.
* Disk images are written to: work on a copy.

## Sound and DSP

* **Sound out** plays through the MiSTer's HDMI / analog audio (16-bit
  stereo, 44.1 kHz; 22.05 kHz sounds are doubled as on the real machine;
  the keyboard's volume keys work).  There is no sound input (no microphone
  CODEC) and no DSP port (the DSP's serial ports have no connector here).
* **The DSP56001 runs on the MiSTer's ARM**, in the DSP interpreter of the
  Previous emulator, inside Main: the FPGA answers the 68040's side of the
  DSP host port and passes the traffic to the ARM through DDR3.  It needs
  the `next-color` build of Main_MiSTer (see Disks).  It runs at roughly
  1.5 million DSP instructions per second, about an eighth of a real
  25 MHz 56001: programs that use the DSP work, but heavy real-time work
  (Music Kit synthesis) runs slower than on the real machine.

The notes below come from the MiSTer template and describe the standard core layout. `<core_name>` is `NeXT-Color`.

## Source structure

### Legend:
* `<core_name>` - you have to use the same name where you see this in this manual. Basically it's your core name.

### Standard MiSTer core should have following folders:
* `sys` - the framework. Basically it's prohibited to change any files in this folder. Framework updates may erase any customization in this folder. All MiSTer cores have to include sys folder as is from this core.
* `rtl` - the actual source of core. It's up to the developer how to organize the inner structure of this folder. Exception is pll folder/files (see below).
* `releases` - the folder where rbf files should be placed. format of each rbf is: <core_name>_YYYYMMDD.rbf (YYYYMMDD is date code of release).

### Other standard files:
* `<core_name>.qpf`- quartus project file. Copy it as is and then modify the line `PROJECT_REVISION = "<core_name>"` according to your core name.
* `<core_name>.qsf` - quartus settings file. In most cases you don't need to modify anything inside (although you may wont to adjust some settings in quartus - this is fine, but keep changes minimal). You also need to watch this file before you make a commit. Quartus in some conditions may "spit" all settings from different files into this file so it will become large. If you see this, then simply revert it to original file.
* `<core_name>.srf` - optional file to disable some warnings which are safe to disable and make message list more clean, so you will have less chance to miss some important warnings. You are free to modify it.
* `<core_name>.sdc` - optional file for constraints in case if core require some special constraints. You are free to modify it.
* `<core_name>.sv` - glue logic between framework and core. This is where you adapt core specific signals to framework.
* `files.qip` - list of all core files. You need to edit it manually to add/remove files. Quartus will use this file but can't edit it. If you add files in Quartus IDE, then they will be added to `<core_name>.qsf` which is recommended manually move them to `files.qip`.
* `clean.bat` - windows batch file to clean the whole project from temporary files. In most cases you don't need to modify it.
* `.gitignore` - list of files should be ignored by git, so temporary files wont be included in commits.
* `jtag.cdf` - it will be produced when you compile the core. By clicking it in Quartus IDE, you will launch programmer where you can send the core to MiSTer over USB blaster cable (see manual for DE10-nano how to connect it). This file normally is not present on cleaned project and not included in commits.

### PLL:
Framework implies use of at least one PLL in the core. Framework doesn't contain this PLL but requires it to be placed in `rtl` folder, so `pll` folder and `pll.v`, `pll.qip` files must be present, however PLL settings are up to the core.

### Verilog Macros

The following macros can be defined and will affect the framework features:

Macro                    |   Effect
-------------------------|---------------------------------
MISTER_DEBUG_NOHDMI      | Disable HDMI-related modules. Speeds up compilation but only analogue/direct video is available
MISTER_DUAL_SDRAM        | Changes configuration of FPGA pins to work with dual SDRAM I/O boards
MISTER_FB                | Allows to use framebuffer from the core
MISTER_SMALL_VBUF        | Sets a smaller video buffer for the ASCAL
MISTER_DOWNSCALE_NN      | Ascal's downscale mode
MISTER_DISABLE_ADAPTIVE  | Disables adaptive scan lines
MISTER_FB_PALETTE        | Framebuffer palette


# Quartus version
Cores must be developed in **Quartus v17.0.x**. It's recommended to have updates, so it will be **v17.0.2**. Newer versions won't give any benefits to FPGA used in MiSTer, however they will introduce incompatibilities in project settings and it will make harder to maintain the core and collaborate with others. **So please stick to good old 17.0.x version.** You may use either Lite or Standard license.

