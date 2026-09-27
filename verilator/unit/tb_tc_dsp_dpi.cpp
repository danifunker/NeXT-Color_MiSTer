// tb_tc_dsp DPI side: the DDR3 mailbox as an array, shared by the RTL's
// mailbox port (mb_read / mb_write) and the ARM daemon, Main_MiSTer
// support/next/next_dsp.cpp with Previous's DSP core (support/next/dsp56k),
// stepped from the bench (arm_step) instead of running as a thread.
#include <stdint.h>
#include <stdio.h>
#include "svdpi.h"
#include "next_dsp.h"
#include "dsp56k/dsp_core.h"

static uint64_t mb[0x4000 / 8];          // the mailbox: 16 KB from $30400000

static uint64_t arm_rd(uint32_t off)             { return mb[(off & 0x3FFF) >> 3]; }
static void     arm_wr(uint32_t off, uint64_t v) { mb[(off & 0x3FFF) >> 3] = v; }

extern "C" long long mb_read(int widx)             { return (long long)mb[widx & 0x7FF]; }
extern "C" void      mb_write(int widx, long long v) { mb[widx & 0x7FF] = (uint64_t)v; }

extern "C" int arm_step(int n)
{
	static int attached = 0;
	if (!attached) { next_dsp_sim_attach(arm_rd, arm_wr); attached = 1; }
	return next_dsp_sim_step(n);
}

// next_dsp_start's /dev/mem mapping is not used here
extern void *shmem_map(uint32_t, uint32_t);
void *shmem_map(uint32_t address, uint32_t size) { (void)address; (void)size; return 0; }

// debug: the DSP's running flag (bit 16) and PC
extern "C" int arm_dsp_state(void) { return (dsp_core.running ? 0x10000 : 0) | dsp_core.pc; }
