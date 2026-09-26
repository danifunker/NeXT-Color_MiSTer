// Simulation stand-in for Main_MiSTer's file_io.h: only what
// support/next needs, on top of stdio.
#ifndef FILE_IO_H
#define FILE_IO_H

#include <stdint.h>
#include <stdio.h>

struct fileTYPE
{
	FILE   *fp;
	int64_t size;
	char    name[1024];
	bool opened() const { return fp != nullptr; }
};

int  FileOpen(fileTYPE *f, const char *name, int mode = 0);
int  FileSeek(fileTYPE *f, int64_t offset, int origin);
int  FileReadAdv(fileTYPE *f, void *buf, int length, int failres = 0);
void FileClose(fileTYPE *f);

#endif
