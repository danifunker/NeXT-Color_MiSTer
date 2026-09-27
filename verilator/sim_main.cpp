// NeXT-Color full-machine simulation (Verilator).
//
// Drives verilator/sim.v: clk_ram at 99 MHz and clk_sys at a third of it
// with aligned rising edges (the PLL relationship the SDRAM bridge and the
// VRAM engine rely on).  clk_vid is clk_ram inside sim.v.
//
// What it gives you (all logged to stdout, one line per event):
//   [STEP]  first arrival at each reset-to-prompt checkpoint of
//           rom-dissassembly/hardware-summary.md section 0.3
//   [CALL]  entries into named ROM routines (--trace-calls N: first N per
//           routine; names from verilator/rom_syms.txt, built from
//           rom-dissassembly/known_names.py by scripts/gen_rom_syms.py)
//   [EXC]   every exception the core takes (vector, format, pc, fault addr)
//   [BERR]  bus errors the machine raised (first 64)
//   [LED]   SCR2 LED changes; [FATAL] the ROM's LED blink halt, with its code
//   [HB]    a heartbeat every --heartbeat cycles
// and PNGs: --vram-png (the framebuffer straight from the DDR3 model,
// through the Bt463 LUT), --frames (the VGA output of the scan-out).
//
// Headless by default; build with `make gui` for the ImGui/SDL window
// (MacQuadra800's verilator/sim framework).

#include <verilated.h>
#include "Vemu.h"

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cstdint>
#include <string>
#include <vector>
#include <map>
#include <set>
#include <csignal>

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "sim/stb_image_write.h"

#ifdef SIM_GUI
#include "imgui.h"
#include <SDL.h>
#include <SDL_opengl.h>
#include "sim_console.h"
#include "sim_video.h"
#include "sim_input.h"
// MacQuadra800's verilator/sim framework: the VGA output in an ImGui window,
// the host keyboard through SimInput's SDL -> PS/2 mapping.
DebugConsole console;
SimVideo video(1120, 832, 0);
SimInput input(12, console);
static bool gui_run = true;
static int  gui_batch = 200000;
static float gui_scale = 1.0f;
#endif

static Vemu* top;
static uint64_t cyc = 0;            // clk_sys cycles since start
static volatile bool stop_req = false;

// ------------------------------------------------------------------ options
static uint64_t opt_max_cycles  = 0;
static std::vector<uint32_t> opt_stop_pc;
static int      opt_trace_calls = 0;
static uint64_t opt_heartbeat   = 5000000;
static std::string opt_syms     = "rom_syms.txt";
static std::string opt_vram_png;             // at exit
static std::vector<uint64_t> opt_png_at;     // cycles for extra VRAM PNGs
static std::set<int> opt_frames;             // VGA frames to capture
static int      opt_ram_cfg     = 0;         // 0=64MB 1=128MB 2=16MB 3=32MB
static bool     opt_pot_on      = false;
static std::string opt_boot;                 // NVRAM default boot command
static uint64_t opt_reset_cycles = 5000;     // machine reset after SDRAM init
static bool     opt_quiet_calls = false;
static std::vector<std::pair<uint64_t, std::string>> opt_type;   // --type CYC:text
static uint64_t opt_trace_pc_from = 0, opt_trace_pc_n = 0;       // --trace-pc FROM,N
static uint64_t opt_color_bars = 0;                              // --color-bars CYCLE
static std::string opt_disk[2];                                  // --disk0 / --disk1 images

// host/host_dpi.cpp: the SD slots' disk images and Main's mount hook
int64_t sim_disk_open(int slot, const char* path);
extern "C" int host_mount_disk(int slot, long long bytes);
static int64_t disk_bytes[2] = {0, 0};
static std::string opt_floppy;                                  // --floppy image (SD slot 4)
static int64_t floppy_bytes = 0;

// ------------------------------------------------------------------ symbols
static std::map<uint32_t, std::string> syms;
static std::map<uint32_t, int> sym_hits;

static void load_syms(const std::string& path) {
	FILE* f = fopen(path.c_str(), "r");
	if (!f) { printf("[SIM] no symbol file %s (run scripts/gen_rom_syms.py)\n", path.c_str()); return; }
	char line[256];
	while (fgets(line, sizeof line, f)) {
		unsigned a; char name[200];
		if (sscanf(line, "%x %199s", &a, name) == 2) syms[a] = name;
	}
	fclose(f);
	syms[0x0100001E] = "reset_entry";
	printf("[SIM] %zu ROM symbols\n", syms.size());
}

static std::string sym_of(uint32_t pc) {
	auto it = syms.upper_bound(pc);
	if (it == syms.begin()) return "?";
	--it;
	char b[240];
	if (it->first == pc) snprintf(b, sizeof b, "%s", it->second.c_str());
	else snprintf(b, sizeof b, "%s+%X", it->second.c_str(), pc - it->first);
	return b;
}

// Reset-to-prompt checkpoints, hardware-summary.md section 0.3.
struct Step { uint32_t pc; const char* what; bool hit; };
static Step steps[] = {
	{0x0100001E, " 1 reset_entry: BMAP probe write (must bus-error)", false},
	{0x01000092, " 2 reset_probe_ncc: BMAP faulted; NCC probe (must bus-error)", false},
	{0x010000B0, " 3 reset_machine_dispatch: NCC faulted; SCR1 / TMC SCR1", false},
	{0x010002A6, " 3 reset_turbo_setup: machine type 5 (Turbo Color)", false},
	{0x01000C68, " 4 mmu_transparent_setup", false},
	{0x010002B4, " 5 tmc_reset_config: TMC control, ADB mask/config", false},
	{0x010003CC, " 6 reset_int_mask_crc: int mask = 0, ROM CRC", false},
	{0x0100041E, " 6 reset_pick_stack: body CRC passed", false},
	{0x01003DFC, " 7 mem_dram_probe", false},
	{0x01000514, " 8 reset_mg_in_dram: a bank passed", false},
	{0x01003A9C, " 8 vid_vram_test: 2 MB VRAM test", false},
	{0x01000556, " 9 reset_install_vectors", false},
	{0x01005CD2, " 9 nvram_check_or_rtc_ramtest", false},
	{0x0100AC8A, "10 vid_console_init", false},
	{0x0100C626, "10 adb_probe_kbd_alt_video", false},
	{0x0100B9E6, "10 vid_init_color_1120x832 (driver 0)", false},
	{0x0100BC78, "10 dac_init_bt463", false},
	{0x0100BE7C, "10 vid_color_enable", false},
	{0x01000E2E, "11 mon_show_test_panel", false},
	{0x01000EC6, "12 mon_init", false},
	{0x0100361A, "12 mem_config_test_t: bank sizing", false},
	{0x010039BC, "12 mem_test_all_t (TEST_DRAM)", false},
	{0x0100C1B4, "12 adb_init", false},
	{0x01005A46, "12 post_run_all (POT_ON)", false},
	{0x0100A1A8, "13 kms_power_key_check", false},
	{0x010019D8, "14 exc_dispatch vector $704: device init", false},
	{0x01008964, "14 scc_init", false},
	{0x010098A4, "14 kms_console_init", false},
	{0x0100610C, "15 boot_cmd", false},
	{0x01001DD8, "16 mon_command_loop: NeXT> prompt", false},
};
static const uint32_t PC_LED_BLINK = 0x010040EC;

// ------------------------------------------------------------------ video
static const int FB_W = 1120, FB_H = 832;
static std::vector<uint32_t> vga_fb(2048 * 1024);
static int vga_x = 0, vga_y = 0, vga_frame = 0, vga_w = 0, vga_h = 0;
static bool vga_de_d = false, vga_vs_d = false;

static void write_png(const char* name, const uint32_t* px, int w, int h, int stride) {
	std::vector<uint8_t> rgb((size_t)w * h * 3);
	for (int y = 0; y < h; y++)
		for (int x = 0; x < w; x++) {
			uint32_t c = px[y * stride + x];
			uint8_t* d = &rgb[((size_t)y * w + x) * 3];
			d[0] = (c >> 16) & 255; d[1] = (c >> 8) & 255; d[2] = c & 255;
		}
	stbi_write_png(name, w, h, 3, rgb.data(), w * 3);
	printf("[PNG] %s (%dx%d) @%llu\n", name, w, h, (unsigned long long)cyc);
}

static uint8_t lut_byte(const VlWide<4>& w, int n) {
	return (w[n >> 2] >> ((n & 3) * 8)) & 255;
}

// the framebuffer straight from VRAM (DDR3 model), through the Bt463 LUT
static void dump_vram_png(const char* name) {
	std::vector<uint32_t> img(FB_W * FB_H);
	uint64_t word = 0;
	for (int i = 0; i < FB_W * FB_H; i++) {
		if ((i & 3) == 0) {
			top->vram_peek_addr = i >> 2;
			top->eval();
			word = top->vram_peek_data;
		}
		int p = i & 3;
		// bytes 2p (high) and 2p+1 of the little-endian DDR word
		uint16_t pix = (uint16_t)((((word >> (16 * p)) & 0xFF) << 8) | ((word >> (16 * p + 8)) & 0xFF));
		int r = (pix >> 12) & 15, g = (pix >> 8) & 15, b = (pix >> 4) & 15;
		img[i] = (lut_byte(top->lut_r, r) << 16) | (lut_byte(top->lut_g, g) << 8) | lut_byte(top->lut_b, b);
	}
	write_png(name, img.data(), FB_W, FB_H, FB_W);
}

// Sim-only: write colour bars into VRAM through the DDR3 model's backdoor
// (rows 560..799), to show the scan-out + Bt463 path in colour while the
// ROM monitor (which only draws greys) is on screen.  Pixel format
// RRRRGGGGBBBBxxxx, big-endian, stored as the VRAM engine does (the pixel's
// high byte at the even byte of the little-endian DDR word).
static void poke_color_bars() {
	for (int y = 560; y < 800; y++) {
		for (int w = 0; w < FB_W / 4; w++) {
			uint64_t word = 0;
			for (int p = 0; p < 4; p++) {
				int x = w * 4 + p, bar = x / 70;          // 16 bars of 70 pixels
				int r, g, b;
				switch ((y - 560) / 60) {
				case 0:  r = bar; g = 0; b = 0; break;       // red ramp
				case 1:  r = 0; g = bar; b = 0; break;       // green ramp
				case 2:  r = 0; g = 0; b = bar; break;       // blue ramp
				default: {                                   // 8 saturated colours, then 8 pastels
					int c = bar & 7;
					r = (c & 4) ? 15 : 0; g = (c & 2) ? 15 : 0; b = (c & 1) ? 15 : 0;
					if (bar >= 8) { r = r ? 15 : 8; g = g ? 15 : 8; b = b ? 15 : 8; }
				}
				}
				uint16_t pix = (uint16_t)((r << 12) | (g << 8) | (b << 4));
				word |= (uint64_t)(pix >> 8) << (16 * p);
				word |= (uint64_t)(pix & 0xFF) << (16 * p + 8);
			}
			top->vram_poke_addr = (uint32_t)(y * (FB_W / 4) + w);
			top->vram_poke_data = word;
			top->vram_poke_en = 1;
			// the DDR3 model's clk_ram: one rising edge with the port enabled
			top->clk_ram = 0; top->eval();
			top->clk_ram = 1; top->eval();
			top->vram_poke_en = 0;
			top->clk_ram = 0; top->eval();
		}
	}
	printf("[SIM] colour bars written into VRAM rows 560-799 @%llu\n", (unsigned long long)cyc);
}

static void vga_clock() {
	bool de = top->VGA_DE, vs = top->VGA_VS;
	if (de) {
		if (vga_x < 2048 && vga_y < 1024)
			vga_fb[vga_y * 2048 + vga_x] = (top->VGA_R << 16) | (top->VGA_G << 8) | top->VGA_B;
		vga_x++;
	}
	if (!de && vga_de_d) {          // end of a visible line
		if (vga_x > vga_w) vga_w = vga_x;
		vga_x = 0;
		vga_y++;
	}
	if (vs && !vga_vs_d) {          // frame done
		if (vga_y > 0) {
			vga_h = vga_y;
			if (opt_frames.count(vga_frame)) {
				char n[64]; snprintf(n, sizeof n, "frame_%04d.png", vga_frame);
				write_png(n, vga_fb.data(), vga_w, vga_h, 2048);
			}
			if (vga_frame < 3 || vga_frame % 50 == 0)
				printf("[VID] frame %d %dx%d video_enable=%d @%llu\n", vga_frame, vga_w, vga_h,
				       top->dbg_video_enable, (unsigned long long)cyc);
			vga_frame++;
		}
		vga_y = 0; vga_x = 0; vga_w = 0;
	}
	vga_de_d = de; vga_vs_d = vs;
}

// ------------------------------------------------------------------ keyboard
// PS/2 set-2 codes for typing monitor commands (--type CYCLE:text)
static uint16_t ps2_of(char c, bool& shift) {
	static const char* lc = "abcdefghijklmnopqrstuvwxyz";
	static const uint8_t lcode[26] = {0x1C,0x32,0x21,0x23,0x24,0x2B,0x34,0x33,0x43,0x3B,0x42,0x4B,0x3A,
	                                  0x31,0x44,0x4D,0x15,0x2D,0x1B,0x2C,0x3C,0x2A,0x1D,0x22,0x35,0x1A};
	static const uint8_t dcode[10] = {0x45,0x16,0x1E,0x26,0x25,0x2E,0x36,0x3D,0x3E,0x46};
	shift = false;
	if (c >= 'a' && c <= 'z') return lcode[strchr(lc, c) - lc];
	if (c >= 'A' && c <= 'Z') { shift = true; return lcode[c - 'A']; }
	if (c >= '0' && c <= '9') return dcode[c - '0'];
	switch (c) {
	case ' ': return 0x29; case '\n': return 0x5A; case '-': return 0x4E; case '=': return 0x55;
	case '.': return 0x49; case ',': return 0x41; case '/': return 0x4A; case ';': return 0x4C;
	case '(': shift = true; return 0x46; case ')': shift = true; return 0x45;
	case '?': shift = true; return 0x4A;
	default: return 0;
	}
}

struct KeyEv { uint64_t at; uint16_t code; bool press; };
static std::vector<KeyEv> keyq;
static size_t keyq_pos = 0;

static void queue_text(uint64_t at, const std::string& s) {
	const uint64_t gap = 400000;   // ~12 ms between events: the ROM polls KMS
	for (char c : s) {
		bool sh; uint16_t k = ps2_of(c == '|' ? '\n' : c, sh);
		if (!k) continue;
		if (sh) { keyq.push_back({at, 0x12, true}); at += gap; }
		keyq.push_back({at, k, true});  at += gap;
		keyq.push_back({at, k, false}); at += gap;
		if (sh) { keyq.push_back({at, 0x12, false}); at += gap; }
	}
}

static void keyboard_tick() {
	while (keyq_pos < keyq.size() && keyq[keyq_pos].at <= cyc) {
		const KeyEv& k = keyq[keyq_pos++];
		uint32_t v = top->ps2_key;
		uint32_t toggle = ((v >> 10) & 1) ^ 1;
		top->ps2_key = (toggle << 10) | ((k.press ? 1 : 0) << 9) | (k.code & 0x1FF);
	}
}

// ------------------------------------------------------------------ monitor
static uint32_t pc_prev = 0;
static bool led_prev = false;
static int led_changes = 0, berr_count = 0;
static bool berr_prev = false;
static uint8_t state_prev = 0;
static uint64_t pc_trace_left = 0;
static bool ran_dram = false;

static void print_regs(const char* why) {
	printf("[REGS] %s pc=%08X (%s) pc_i=%08X sr=%04X ir=%04X a7=%08X d0=%08X d1=%08X d2=%08X a0=%08X ipl=%u int=%08X @%llu\n",
	       why, top->dbg_pc, sym_of(top->dbg_pc_i).c_str(), top->dbg_pc_i, top->dbg_sr, top->dbg_ir,
	       top->dbg_a7, top->dbg_d0, top->dbg_d1, top->dbg_d2, top->dbg_a0, top->dbg_ipl,
	       top->dbg_intstat, (unsigned long long)cyc);
}

static void monitor() {
	uint32_t pc = top->dbg_pc_i;

	if (pc != pc_prev) {
		for (auto& s : steps)
			if (!s.hit && s.pc == pc) {
				s.hit = true;
				printf("[STEP] %s  @%llu (%.3f ms)\n", s.what, (unsigned long long)cyc, cyc / 33000.0);
			}
		auto it = syms.find(pc);
		if (it != syms.end()) {
			int& h = sym_hits[pc];
			if (h < opt_trace_calls)
				printf("[CALL] %08X %s a7=%08X d0=%08X @%llu\n", pc, it->second.c_str(), top->dbg_a7,
				       top->dbg_d0, (unsigned long long)cyc);
			h++;
		}
		if (pc == PC_LED_BLINK) {
			printf("[FATAL] led_blink_loop: %u blinks (a0), called from here -- boot halted\n", top->dbg_a0);
			print_regs("led_blink");
		}
		for (uint32_t s : opt_stop_pc)
			if (pc == s) {
				print_regs("stop-at-pc");
				stop_req = true;
			}
		// the ROM jumps into a loaded boot program (HS 9.3: "jsr entry")
		if (!ran_dram && pc >= 0x04000000 && pc < 0x0C000000) {
			ran_dram = true;
			printf("[BOOT] first instruction from DRAM: %08X @%llu (%.3f ms)\n", pc,
			       (unsigned long long)cyc, cyc / 33000.0);
			print_regs("boot-entry");
		}
		if (pc_trace_left && cyc >= opt_trace_pc_from) {
			printf("[PC] %08X %s\n", pc, sym_of(pc).c_str());
			pc_trace_left--;
		}
		pc_prev = pc;
	}

	// exception entry: the core's state 34 (MacQuadra800 sim_main.cpp [EXC])
	if (top->dbg_state == 34 && state_prev != 34 && !top->dbg_exc_irq)
		printf("[EXC] vec=%u fmt=%u spc=%08X addr=%08X pc_i=%08X (%s) @%llu\n", top->dbg_exc_vec,
		       top->dbg_exc_fmt, top->dbg_exc_spc, top->dbg_exc_addr, pc, sym_of(pc).c_str(),
		       (unsigned long long)cyc);
	state_prev = top->dbg_state;

	if (top->dbg_berr && !berr_prev && berr_count < 64) {
		berr_count++;
		printf("[BERR] %08X pc_i=%08X (%s) @%llu\n", top->dbg_berr_addr, pc, sym_of(pc).c_str(),
		       (unsigned long long)cyc);
	}
	berr_prev = top->dbg_berr;

	if (top->led != led_prev) {
		if (led_changes < 64)
			printf("[LED] %s  pc_i=%08X (%s) @%llu\n", top->led ? "on " : "off", pc, sym_of(pc).c_str(),
			       (unsigned long long)cyc);
		led_changes++;
		led_prev = top->led;
	}
}

// ------------------------------------------------------------------ clocking
// One tick = half a clk_ram period.  clk_ram toggles every tick, clk_sys
// every third tick; both start low, so their rising edges coincide every
// third clk_ram rise.
static uint64_t tick = 0;

static void step_tick() {
	tick++;
	top->clk_ram = !top->clk_ram;
	bool sys_edge = (tick % 3) == 0;
	if (sys_edge) top->clk_sys = !top->clk_sys;
	top->eval();
	if (top->clk_ram) {
		vga_clock();
#ifdef SIM_GUI
		video.Clock(!top->VGA_DE, false, top->VGA_HS, top->VGA_VS,
		            0xFF000000u | (top->VGA_B << 16) | (top->VGA_G << 8) | top->VGA_R);
#endif
	}
	if (sys_edge && top->clk_sys) {
		cyc++;
		// reset sequencing: SDRAM init for 16 clocks, machine reset after
		top->sdram_init   = cyc < 16;
		top->config_reset = cyc < opt_reset_cycles;
		top->reset        = cyc < opt_reset_cycles || top->reset_req;
		top->timestamp    = ((uint64_t)1 << 32) | 1790000000u;   // 2026-09-21 UTC, fixed
		// the mounts, one slot per clock at cycles 100/102, inside the reset
		// window as the core-start mount is on hardware (tc_scsi keeps its
		// mount state outside the reset)
		top->img_mounted = 0;
		for (int s = 0; s < 2; s++)
			if (disk_bytes[s] > 0 && cyc == 100 + 2 * (uint64_t)s) {
				top->img_mounted = 1 << s;
				top->img_size = (uint64_t)disk_bytes[s];
			}
		if (floppy_bytes > 0 && cyc == 104) {
			top->img_mounted = 1 << 4;
			top->img_size = (uint64_t)floppy_bytes;
		}
		if (!top->reset) monitor();
		keyboard_tick();
#ifdef SIM_GUI
		input.BeforeEval();
#endif
	}
}

static void on_signal(int) { stop_req = true; }

static void usage() {
	printf("NeXT-Color sim: obj_dir/Vemu [options] [+rom=file.hex]\n"
	       "  --max-cycles N        stop after N clk_sys cycles (33 MHz)\n"
	       "  --stop-at-pc A[,B..]  stop when the executed PC reaches A (hex)\n"
	       "  --trace-calls N       print the first N entries of every named ROM routine\n"
	       "  --trace-pc FROM,N     print N executed PCs from cycle FROM\n"
	       "  --heartbeat N         progress line every N cycles (default 5000000)\n"
	       "  --syms FILE           ROM symbol table (default rom_syms.txt)\n"
	       "  --vram-png FILE       dump the framebuffer (VRAM through the Bt463 LUT) at exit\n"
	       "  --png-at C1,C2,..     also dump vram_<cycle>.png at those cycles\n"
	       "  --frames F1,F2,..     save VGA output frames as frame_NNNN.png\n"
	       "  --ram N               0=64MB (default) 1=128MB 2=16MB 3=32MB\n"
	       "  --pot-on              NVRAM default image with the power-on test on (POT $11)\n"
	       "  --boot CMD            NVRAM default boot command (default: empty -> prompt)\n"
	       "  --type CYC:TEXT       type TEXT on the keyboard from cycle CYC ('|' = Return)\n"
	       "  --disk0 FILE          SCSI target 0 image (SD slot 0; written back: use a copy)\n"
	       "  --disk1 FILE          SCSI target 1 image (SD slot 1)\n"
	       "  --floppy FILE         floppy image, 720K/1.44M/2.88M (SD slot 4; written back)\n"
	       "  --color-bars CYC      sim-only: write colour bars into VRAM at cycle CYC\n");
}

static std::vector<uint64_t> parse_list(const char* s) {
	std::vector<uint64_t> v;
	while (*s) {
		v.push_back(strtoull(s, (char**)&s, 0));
		if (*s == ',') s++; else break;
	}
	return v;
}

int main(int argc, char** argv) {
	Verilated::commandArgs(argc, argv);
	for (int i = 1; i < argc; i++) {
		std::string a = argv[i];
		auto next = [&]() -> const char* { return i + 1 < argc ? argv[++i] : ""; };
		if (a == "--max-cycles") opt_max_cycles = strtoull(next(), nullptr, 0);
		else if (a == "--stop-at-pc") {
			for (const char* s = next(); *s; ) {
				opt_stop_pc.push_back((uint32_t)strtoul(s, (char**)&s, 16));
				if (*s == ',') s++; else break;
			}
		}
		else if (a == "--trace-calls") opt_trace_calls = atoi(next());
		else if (a == "--trace-pc") {
			auto v = parse_list(next());
			if (v.size() == 2) { opt_trace_pc_from = v[0]; opt_trace_pc_n = v[1]; }
		}
		else if (a == "--color-bars") opt_color_bars = strtoull(next(), nullptr, 0);
		else if (a == "--heartbeat") opt_heartbeat = strtoull(next(), nullptr, 0);
		else if (a == "--syms") opt_syms = next();
		else if (a == "--vram-png") opt_vram_png = next();
		else if (a == "--png-at") opt_png_at = parse_list(next());
		else if (a == "--frames") for (auto f : parse_list(next())) opt_frames.insert((int)f);
		else if (a == "--ram") opt_ram_cfg = atoi(next()) & 3;
		else if (a == "--pot-on") opt_pot_on = true;
		else if (a == "--boot") opt_boot = next();
		else if (a == "--disk0") opt_disk[0] = next();
		else if (a == "--disk1") opt_disk[1] = next();
		else if (a == "--floppy") opt_floppy = next();
		else if (a == "--type") {
			std::string s = next();
			size_t c = s.find(':');
			if (c != std::string::npos) opt_type.push_back({strtoull(s.c_str(), nullptr, 0), s.substr(c + 1)});
		}
		else if (a == "-h" || a == "--help") { usage(); return 0; }
		else if (a[0] == '+') ;   // Verilog plusargs
		else { printf("unknown option %s\n", a.c_str()); usage(); return 1; }
	}
	pc_trace_left = opt_trace_pc_n;
	for (auto& t : opt_type) queue_text(t.first, t.second);

	signal(SIGINT, on_signal);
	signal(SIGTERM, on_signal);

	load_syms(opt_syms);

	top = new Vemu;
	top->clk_ram = 0;
	top->clk_sys = 0;
	top->reset = 1;
	top->config_reset = 1;
	top->sdram_init = 1;
	top->ram_cfg = opt_ram_cfg;
	top->pot_on = opt_pot_on;
	// boot command: 12 ASCII chars, first in [95:88]
	for (int w = 0; w < 3; w++) top->boot_cmd[w] = 0;
	for (size_t i = 0; i < opt_boot.size() && i < 12; i++) {
		int bit = 88 - 8 * (int)i;
		top->boot_cmd[bit / 32] |= (uint32_t)(uint8_t)opt_boot[i] << (bit % 32);
	}
	top->ps2_key = 0;
	top->ps2_mouse = 0;
	top->vram_poke_en = 0;
	top->img_mounted = 0;
	top->img_readonly = 0;
	top->img_size = 0;
	top->eval();

	for (int s = 0; s < 2; s++) {
		if (opt_disk[s].empty()) continue;
		disk_bytes[s] = sim_disk_open(s, opt_disk[s].c_str());
		if (disk_bytes[s] <= 0) { printf("[SIM] cannot open disk %d image %s\n", s, opt_disk[s].c_str()); return 1; }
		host_mount_disk(s, disk_bytes[s]);
		printf("[SIM] SCSI target %d: %s, %lld bytes (%lld blocks)\n", s, opt_disk[s].c_str(),
		       (long long)disk_bytes[s], (long long)(disk_bytes[s] / 512));
	}
	if (!opt_floppy.empty()) {
		floppy_bytes = sim_disk_open(4, opt_floppy.c_str());
		if (floppy_bytes <= 0) { printf("[SIM] cannot open floppy image %s\n", opt_floppy.c_str()); return 1; }
		printf("[SIM] floppy: %s, %lld bytes\n", opt_floppy.c_str(), (long long)floppy_bytes);
	}

	static const char* ram_names[4] = {"64 MB", "128 MB", "16 MB", "32 MB"};
	printf("[SIM] RAM %s, POT %s, boot command \"%s\"\n", ram_names[opt_ram_cfg],
	       opt_pot_on ? "$11" : "$00", opt_boot.c_str());

	size_t png_i = 0;
	uint64_t next_hb = opt_heartbeat;
#ifdef SIM_GUI
	input.ps2_key = &top->ps2_key;
	input.Initialise();
	if (video.Initialise("NeXT-Color sim") == 1) return 1;
#endif
	while (!Verilated::gotFinish() && !stop_req) {
#ifdef SIM_GUI
		{
			SDL_Event event;
			while (SDL_PollEvent(&event)) {
				ImGui_ImplSDL2_ProcessEvent(&event);
				if (event.type == SDL_QUIT) stop_req = true;
			}
			video.StartFrame();
			input.Read();
			ImGui::NewFrame();
			ImGui::Begin("Simulation");
			ImGui::SetWindowPos("Simulation", ImVec2(0, 0), ImGuiCond_Once);
			ImGui::SetWindowSize("Simulation", ImVec2(420, 200), ImGuiCond_Once);
			ImGui::Checkbox("RUN", &gui_run);
			ImGui::SliderInt("Batch (ticks)", &gui_batch, 10000, 2000000);
			ImGui::SliderFloat("Scale", &gui_scale, 0.25f, 1.0f);
			ImGui::Text("cycle %llu (%.1f ms)  frame %d", (unsigned long long)cyc, cyc / 33000.0, vga_frame);
			ImGui::Text("pc %08X %s", top->dbg_pc_i, sym_of(top->dbg_pc_i).c_str());
			ImGui::Text("sr %04X  led %d  ipl %d  int %08X", top->dbg_sr, top->led, top->dbg_ipl, top->dbg_intstat);
			if (ImGui::Button("VRAM PNG")) dump_vram_png("gui_vram.png");
			ImGui::End();
			ImGui::Begin("VGA output");
			ImGui::SetWindowPos("VGA output", ImVec2(430, 0), ImGuiCond_Once);
			ImGui::Image(video.texture_id, ImVec2(video.output_width * gui_scale, video.output_height * gui_scale));
			ImGui::End();
			video.UpdateTexture();
			if (!gui_run) continue;
			for (int b = 0; b < gui_batch && !stop_req; b++) step_tick();
		}
#else
		step_tick();
#endif
		if (opt_max_cycles && cyc >= opt_max_cycles) break;
		if (opt_color_bars && cyc >= opt_color_bars && (tick % 6) == 0) {
			poke_color_bars();
			opt_color_bars = 0;
		}
		if (png_i < opt_png_at.size() && cyc >= opt_png_at[png_i] && (tick % 6) == 0) {
			char n[64]; snprintf(n, sizeof n, "vram_%llu.png", (unsigned long long)opt_png_at[png_i]);
			dump_vram_png(n);
			png_i++;
		}
		if (cyc >= next_hb && (tick % 6) == 0) {
			printf("[HB] %llu cycles (%.1f ms) pc=%08X (%s) led=%d frames=%d\n", (unsigned long long)cyc,
			       cyc / 33000.0, top->dbg_pc_i, sym_of(top->dbg_pc_i).c_str(), top->led, vga_frame);
			fflush(stdout);
			next_hb += opt_heartbeat;
		}
	}

	print_regs("end");
	int reached = 0;
	for (auto& s : steps) reached += s.hit;
	printf("[SIM] %d of %zu checkpoints reached, %d bus errors, %d LED changes, %d frames, %llu cycles\n",
	       reached, sizeof(steps) / sizeof(steps[0]), berr_count, led_changes, vga_frame,
	       (unsigned long long)cyc);
	if (!opt_vram_png.empty()) dump_vram_png(opt_vram_png.c_str());
#ifdef SIM_GUI
	video.CleanUp();
	input.CleanUp();
#endif
	top->final();
	delete top;
	return 0;
}
