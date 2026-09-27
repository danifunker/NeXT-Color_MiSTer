# NeXT-Color full-machine Verilator simulation (headless).
#
#   make                 build obj_dir/Vemu, rom.hex and rom_syms.txt
#   ./obj_dir/Vemu --help
#   make tb_sdram        (later: unit benches; see verilator/unit/)
#
# Run it on ext4 inside WSL (scripts/sim_wsl.sh syncs the tree there): the
# build and the run are several times faster than on /mnt/c.
V = verilator

TOP  = --top-module emu
RTL  = ../rtl
AP   = ../rtl/ap68040/rtl
APX  = ../rtl/ap68040/experimental
V_INC = +incdir+$(RTL) +incdir+$(AP) -I$(AP)

V_DEFINE = +define+SIMULATION=1 \
	+define+AP040_EXPERIMENTAL_XSTORE=1 +define+AP040_EXPERIMENTAL_LEA=1 \
	--timescale-override 1ps/1ps -Wno-TIMESCALEMOD -I$(RTL)
V_DEFINE += -Wno-fatal -Wno-WIDTH -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC -Wno-IMPLICIT \
	-Wno-PINMISSING -Wno-UNUSEDSIGNAL -Wno-UNOPTFLAT -Wno-CASEINCOMPLETE \
	-Wno-UNSIGNED -Wno-CMPCONST -Wno-LATCH -Wno-UNDRIVEN -Wno-MISINDENT \
	-Wno-COMBDLY -Wno-INITIALDLY -Wno-SYNCASYNCNET -Wno-BLKLOOPINIT \
	-Wno-MULTIDRIVEN -Wno-GENUNNAMED -Wno-BLKSEQ -Wno-DECLFILENAME
V_DEFINE += --timing
# --unroll-count: ap040_mmu.v clears the 128 ATC valid flops with a for loop of
# delayed assignments (PFLUSHA, reset); above Verilator's default of 64 the loop
# is not unrolled and the assignment is silently dropped (BLKLOOPINIT), so
# PFLUSHA was a no-op in the sim (found 2026-09-26, open question 39).
V_OPT = --x-assign fast --x-initial fast --noassert -O3 --unroll-count 256

# The HPS side of the SD slots (host/host_dpi.cpp) runs Main_MiSTer's own
# support/next sources, copied with the shim headers (host/shim) into
# HOST_MAIN by scripts/sim_wsl.sh build (from ../Main_MiSTer, branch next-color).
HOST_MAIN ?= $(abspath ../host_main)
HOST_SRC = host/host_dpi.cpp \
	$(addprefix $(HOST_MAIN)/support/next/,next_scsi.cpp next_cdrom.cpp next_cdrom_resp.cpp \
		next_cdrom_play.cpp next_mo.cpp next_rs.cpp)
ifneq ($(MAKECMDGOALS),clean)
ifeq ($(wildcard $(HOST_MAIN)/support/next/next_scsi.cpp),)
$(error $(HOST_MAIN) has no Main_MiSTer support/next copy: run scripts/sim_wsl.sh build)
endif
endif

CXXFLAGS_SIM = -O2 -g -I../sim -I$(HOST_MAIN)

EXE  = ./obj_dir/Vemu
VOUT = obj_dir/Vemu.cpp

V_SRC = \
	sim.v \
	sdram_model.sv \
	ddr3_model.sv \
	altddio_out_stub.v \
	$(RTL)/tc_machine.sv \
	$(RTL)/tc_memsys.sv \
	$(RTL)/tc_rom.sv \
	$(RTL)/tc_vram.sv \
	$(RTL)/tc_vtiming.sv \
	$(RTL)/tc_dpram_dc.sv \
	$(RTL)/tc_tmc.sv \
	$(RTL)/tc_scr.sv \
	$(RTL)/tc_mccs1850.sv \
	$(RTL)/tc_intc.sv \
	$(RTL)/tc_timers.sv \
	$(RTL)/tc_bt463.sv \
	$(RTL)/tc_kms.sv \
	$(RTL)/next_sound_output.sv \
	$(RTL)/tc_enet.sv \
	$(RTL)/tc_scc.sv \
	$(RTL)/tc_tdma.sv \
	$(RTL)/tc_scsi.sv \
	$(RTL)/next_floppy.sv \
	$(RTL)/next_enet_bridge.sv \
	$(RTL)/next_ddram_arb.sv \
	$(RTL)/tc_enet_ddr.sv \
	$(RTL)/wombat_cpu.sv \
	$(RTL)/wombat_store_buffer.sv \
	$(RTL)/wombat_bus32.sv \
	$(RTL)/sdram.sv \
	$(RTL)/sdram_beat32.sv \
	$(RTL)/dpram.v \
	$(AP)/ap040_core.v \
	$(AP)/ap040_bus_timeout.v \
	$(AP)/ap040_regfile.v \
	$(AP)/ap040_alu.v \
	$(AP)/ap040_muldiv.v \
	$(AP)/ap040_mmu.v \
	$(AP)/ap040_cache.v \
	$(AP)/ap040_fpu.v \
	$(APX)/ap040_pipeline_integer.sv

C_SRC = sim_main.cpp $(HOST_SRC)

all: $(EXE) rom.hex rom_fast.hex rom_syms.txt

# ROM image as $readmemh longwords (big-endian: file order = byte order)
rom.hex: ../releases/boot0.rom
	xxd -p -c4 $< > $@

# sim-only fast boot: CRC, VRAM test and the 750 ms video delay patched out
rom_fast.hex: ../releases/boot0.rom ../scripts/make_fastboot_rom.py
	python3 ../scripts/make_fastboot_rom.py $< $@

rom_syms.txt: ../rom-dissassembly/known_names.py ../scripts/gen_rom_syms.py
	python3 ../scripts/gen_rom_syms.py $@

$(VOUT): $(V_SRC) $(C_SRC) Makefile
	$V -cc $(V_OPT) -exe --Mdir ./obj_dir --build-jobs 0 \
		$(V_DEFINE) $(V_INC) $(TOP) -CFLAGS "$(CXXFLAGS_SIM)" $(V_SRC) $(C_SRC)
	@touch $(VOUT)

$(EXE): $(VOUT)
	@for f in $(C_SRC); do o=obj_dir/$$(basename $${f%.*}).o; \
		[ -e $$o ] && [ $$f -nt $$o ] && rm -f $$o obj_dir/Vemu || true; done
	(cd obj_dir; $(MAKE) -f Vemu.mk -j$$(nproc))

# GUI variant (MacQuadra800's ImGui/SDL framework): obj_dir_gui/Vemu
GUI_SRC = sim/sim_console.cpp sim/sim_video.cpp sim/sim_input.cpp \
	sim/imgui/imgui_impl_sdl.cpp sim/imgui/imgui_impl_opengl2.cpp \
	sim/imgui/imgui_draw.cpp sim/imgui/imgui_widgets.cpp \
	sim/imgui/imgui_tables.cpp sim/imgui/imgui.cpp
GUI_CFLAGS = -O2 -g -I../sim -I../sim/imgui -I$(HOST_MAIN) -DSIM_GUI `sdl2-config --cflags`
GUI_LIBS = -lGL -ldl `sdl2-config --libs`

gui: rom.hex rom_fast.hex rom_syms.txt
	$V -cc $(V_OPT) -exe --Mdir ./obj_dir_gui --build-jobs 0 \
		$(V_DEFINE) $(V_INC) $(TOP) -CFLAGS "$(GUI_CFLAGS)" -LDFLAGS "$(GUI_LIBS)" \
		$(V_SRC) $(C_SRC) $(GUI_SRC)
	(cd obj_dir_gui; $(MAKE) -f Vemu.mk -j$$(nproc))

clean:
	rm -rf obj_dir obj_dir_gui rom.hex rom_fast.hex rom_syms.txt

.PHONY: all clean gui
