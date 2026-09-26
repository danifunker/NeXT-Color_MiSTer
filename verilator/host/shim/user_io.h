// Simulation stand-in for Main_MiSTer's user_io.h.
#ifndef USER_IO_H
#define USER_IO_H

#include <stdint.h>

#define UIO_SECTOR_RD 0x17
#define UIO_SECTOR_WR 0x18

char is_next();
int  user_io_get_width();

#endif
