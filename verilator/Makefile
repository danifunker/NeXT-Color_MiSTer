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
V_OPT = --x-assign fast --x-initial fast --noassert -O3

CXXFLAGS_SIM = -O2 -g -I../sim

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
	$(RTL)/tc_regfile.sv \
	$(RTL)/tc_scc.sv \
	$(RTL)/tc_esp_mini.sv \
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

C_SRC = sim_main.cpp

all: $(EXE) rom.hex rom_fast.hex rom_syms.txt

# ROM image as $readmemh longwords (big-endian: file order = byte order)
rom.hex: ../releases/boot.rom
	xxd -p -c4 $< > $@

# sim-only fast boot: CRC, VRAM test and the 750 ms video delay patched out
rom_fast.hex: ../releases/boot.rom ../scripts/make_fastboot_rom.py
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

clean:
	rm -rf obj_dir rom.hex rom_fast.hex rom_syms.txt

.PHONY: all clean
