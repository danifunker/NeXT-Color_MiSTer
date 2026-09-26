// Simulation stand-in for Main_MiSTer's cd.h (the toc_t the CD image
// layer fills), without libchdr.
#ifndef CD_H
#define CD_H

#include <stdint.h>
#include "file_io.h"

typedef struct chd_file chd_file;

typedef enum
{
	SUBCODE_NONE = 0, SUBCODE_RW, SUBCODE_RW_RAW
} cd_subcode_types_t;

enum TrackType {
	TT_CDDA,
	TT_MODE1,
	TT_MODE2,
};

typedef struct
{
	fileTYPE f;
	int offset;
	int pregap;
	int start;
	int end;
	enum TrackType type;
	int sector_size;
	int indexes[100];
	int index_num;
	cd_subcode_types_t sbc_type;
} cd_track_t;

typedef struct
{
	int end;
	int last;
	int sectorSize;
	chd_file *chd_f;
	int chd_hunksize;
	cd_track_t tracks[100];
	fileTYPE sub;
} toc_t;

#endif
