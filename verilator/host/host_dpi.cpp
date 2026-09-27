// The HPS side of tc_scsi's SD slots, for the full-machine sim (sim.v).
//
// Two halves:
//   * the SCSI target-response and command windows (lba >= $7C000000 on
//     slot 3): served by the Main_MiSTer sources that ship
//     (support/next/next_scsi.cpp and friends, copied into ../host_main by
//     scripts/sim_wsl.sh build), exactly as NeXT_MiSTer's
//     tb/host/next_host_dpi.cpp does for the mono core's benches;
//   * the disk images behind slots 0 and 1: 512-byte blocks read and
//     written with pread/pwrite, so images past 2 GB work (Verilog $fseek
//     offsets are 32-bit).
//
// Also the implementations behind the shim headers (host/shim, from
// NeXT_MiSTer tb/host/shim_impl.cpp): stdio file access, no-op SPI, the
// core is a NeXT, no CHD.
//
//   host_fill(slot, lba, sz)   serve a window read: fills the byte buffer
//   host_byte(i)               byte i of it
//   host_put(i, b)             stage byte i of a window write
//   host_exec(slot, lba, sz)   a window write landed: run the command
//   disk_read(slot, lba)       read a block of the slot's image
//   disk_byte(i) / disk_put(i, b) / disk_write(slot, lba)
//
// sim_main.cpp opens the images (sim_disk_open) and reports each mount to
// Main's hook (host_mount_disk) before the machine leaves reset.

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>

#include "file_io.h"
#include "user_io.h"
#include "spi.h"
#include "hardware.h"
#include "support/chd/mister_chd.h"
#include "support/next/next_scsi.h"
#include "support/next/next_cdrom.h"
#include "support/next/next_mo.h"

// ------------------------------------------------------------ windows
static uint8_t hbuf[16384];

extern "C" int host_fill(int slot, int lba, int sz)
{
	uint32_t l = (uint32_t)lba;
	if (sz < 0 || sz > (int)sizeof(hbuf)) return 0;
	memset(hbuf, 0, (size_t)sz);
	if (slot == NEXT_CDROM_SLOT)
	{
		if (l >= NEXT_WIN_BASE) next_scsi_window_fill(l, hbuf, sz);
		else if (next_cdrom_active(slot)) next_cdrom_fill(slot, l, hbuf, sz);
		else return 0;
		return 1;
	}
	return 0;
}

extern "C" int host_byte(int i)
{
	if (i < 0 || i >= (int)sizeof(hbuf)) return 0;
	return hbuf[i];
}

extern "C" void host_put(int i, int b)
{
	if (i < 0 || i >= (int)sizeof(hbuf)) return;
	hbuf[i] = (uint8_t)b;
}

extern "C" void host_exec(int slot, int lba, int sz)
{
	uint32_t l = (uint32_t)lba;
	if (sz < 0 || sz > (int)sizeof(hbuf)) return;
	if (slot == NEXT_CDROM_SLOT && l >= NEXT_WIN_BASE) next_cdrom_command(l, hbuf, sz);
}

// Main's mount hook for a disk slot (what user_io does on an OSD mount):
// it records the size the INQUIRY / READ CAPACITY responses report.
extern "C" int host_mount_disk(int slot, long long bytes)
{
	fileTYPE f = {};
	int writable = 1;
	f.size = bytes;
	return next_mount_hook(slot, "disk", &f, &writable);
}

// ------------------------------------------------------------ disk images
// slots 0..3 as tc_scsi's, 4 = the floppy (next_floppy, --floppy)
static int     dfd[5] = {-1, -1, -1, -1, -1};
static int64_t dbytes[5];
static uint8_t dblk[512];

int64_t sim_disk_open(int slot, const char *path)
{
	if (slot < 0 || slot > 4) return -1;
	int fd = open(path, O_RDWR);
	if (fd < 0) { perror(path); return -1; }
	dfd[slot] = fd;
	dbytes[slot] = (int64_t)lseek(fd, 0, SEEK_END);
	return dbytes[slot];
}

extern "C" int disk_read(int slot, int lba)
{
	memset(dblk, 0, sizeof dblk);
	if (slot < 0 || slot > 4 || dfd[slot] < 0) return 0;
	off_t at = (off_t)(uint32_t)lba * 512;
	return pread(dfd[slot], dblk, sizeof dblk, at) == (ssize_t)sizeof dblk;
}

extern "C" int disk_byte(int i)
{
	return (i >= 0 && i < 512) ? dblk[i] : 0;
}

extern "C" void disk_put(int i, int b)
{
	if (i >= 0 && i < 512) dblk[i] = (uint8_t)b;
}

extern "C" void disk_write(int slot, int lba)
{
	if (slot < 0 || slot > 4 || dfd[slot] < 0) return;
	off_t at = (off_t)(uint32_t)lba * 512;
	if (pwrite(dfd[slot], dblk, sizeof dblk, at) != (ssize_t)sizeof dblk) perror("disk_write");
}

// ------------------------------------------------------------ shim implementations
int FileOpen(fileTYPE *f, const char *name, int)
{
	f->fp = fopen(name, "rb");
	if (!f->fp) { f->size = 0; return 0; }
	fseeko(f->fp, 0, SEEK_END);
	f->size = (int64_t)ftello(f->fp);
	fseeko(f->fp, 0, SEEK_SET);
	strncpy(f->name, name, sizeof(f->name) - 1);
	f->name[sizeof(f->name) - 1] = 0;
	return 1;
}

int FileSeek(fileTYPE *f, int64_t offset, int origin)
{
	if (!f->fp) return 0;
	return fseeko(f->fp, (off_t)offset, origin) == 0;
}

int FileReadAdv(fileTYPE *f, void *buf, int length, int)
{
	if (!f->fp) return 0;
	return (int)fread(buf, 1, (size_t)length, f->fp);
}

void FileClose(fileTYPE *f)
{
	if (f->fp) fclose(f->fp);
	f->fp = nullptr;
	f->size = 0;
}

char is_next() { return 1; }
int  user_io_get_width() { return 0; }

void     EnableIO() {}
void     DisableIO() {}
uint16_t spi_w(uint16_t) { return 0; }
void     spi_block_read(uint8_t *, int, int) {}
void     spi_block_write(const uint8_t *, int, int) {}

void diskled_on() {}

chd_error mister_chd_read_sector(chd_file *, int, uint32_t, uint32_t, int, uint8_t *, uint8_t *, int *) { return 1; }
chd_error mister_load_chd(const char *, toc_t *) { return 1; }
void      chd_close(chd_file *) {}
