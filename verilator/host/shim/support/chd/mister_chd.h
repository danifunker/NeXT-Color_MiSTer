// Simulation stand-in for Main_MiSTer's CHD loader: CHD images are not
// supported in the bench (the loader fails the mount).
#ifndef MISTER_CHD_INCLUDED
#define MISTER_CHD_INCLUDED

#include <stdint.h>
#include "../../cd.h"

typedef int chd_error;
#define CHDERR_NONE 0

chd_error mister_chd_read_sector(chd_file *chd_f, int lba, uint32_t d_offset, uint32_t s_offset, int length, uint8_t *destbuf, uint8_t *hunkbuf, int *hunknum);
chd_error mister_load_chd(const char *filename, toc_t *cd_toc);
void      chd_close(chd_file *chd_f);

#endif
