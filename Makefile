# ==============================================================================
# Makefile — 32-tap FIR Filter, VHDL simulation with GHDL
# ==============================================================================
# Requirements:
#   sudo apt install ghdl gtkwave
#
# Targets:
#   make sim_all       — run all self-checking testbenches
#   make sim_accu      — accumulator unit test
#   make sim_dl        — delay line waveform (inspect in GTKWave)
#   make sim_fsm       — FSM v1 waveform (inspect in GTKWave)
#   make sim_clkv2     — verify 20 MHz DDR clock generation
#   make wave_accu     — open GTKWave for accumulator
#   make wave_dl       — open GTKWave for delay line
#   make wave_fsm      — open GTKWave for FSM v1
#   make wave_clkv2    — open GTKWave for clk_div_v2
#   make clean         — remove build artefacts
# ==============================================================================

GHDL    ?= ghdl
GTKWAVE ?= gtkwave
BUILD   := build
STD     := 08

SRC := \
    src/accu.vhd        \
    src/buff.vhd        \
    src/delay_line.vhd  \
    src/mult.vhd        \
    src/rom.vhd         \
    src/fir_base.vhd    \
    src/pmod_adc.vhd    \
    src/pmod_dac.vhd    \
    src/clk_div_v1.vhd  \
    src/clk_div_v2.vhd  \
    src/fsm_v1.vhd      \
    src/fsm_v2.vhd      \
    src/fir_top.vhd

.PHONY: all sim_all sim_accu sim_dl sim_fsm sim_clkv2 \
        wave_accu wave_dl wave_fsm wave_clkv2 clean

all: sim_all

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/.analysed: $(SRC) | $(BUILD)
	$(GHDL) -a --std=$(STD) --workdir=$(BUILD) $(SRC)
	touch $@

# ── Accumulator (self-checking) ───────────────────────────────────────────────
sim_accu: $(BUILD)/.analysed tb/tb_accu.vhd
	$(GHDL) -a --std=$(STD) --workdir=$(BUILD) tb/tb_accu.vhd
	$(GHDL) -e --std=$(STD) --workdir=$(BUILD) tb_accu
	$(GHDL) -r --std=$(STD) --workdir=$(BUILD) tb_accu \
	    --vcd=$(BUILD)/tb_accu.vcd --stop-time=5us
	@echo "tb_accu OK"

wave_accu: sim_accu
	$(GTKWAVE) $(BUILD)/tb_accu.vcd &

# ── Delay line (waveform inspection) ─────────────────────────────────────────
sim_dl: $(BUILD)/.analysed tb/tb_delay_line.vhd
	$(GHDL) -a --std=$(STD) --workdir=$(BUILD) tb/tb_delay_line.vhd
	$(GHDL) -e --std=$(STD) --workdir=$(BUILD) tb_delay_line
	$(GHDL) -r --std=$(STD) --workdir=$(BUILD) tb_delay_line \
	    --vcd=$(BUILD)/tb_delay_line.vcd --stop-time=5us
	@echo "tb_delay_line OK — open with: make wave_dl"

wave_dl: sim_dl
	$(GTKWAVE) $(BUILD)/tb_delay_line.vcd &

# ── FSM v1 (waveform inspection) ──────────────────────────────────────────────
sim_fsm: $(BUILD)/.analysed tb/tb_fsm.vhd
	$(GHDL) -a --std=$(STD) --workdir=$(BUILD) tb/tb_fsm.vhd
	$(GHDL) -e --std=$(STD) --workdir=$(BUILD) tb_fsm
	$(GHDL) -r --std=$(STD) --workdir=$(BUILD) tb_fsm \
	    --vcd=$(BUILD)/tb_fsm.vcd --stop-time=20us
	@echo "tb_fsm OK — open with: make wave_fsm"

wave_fsm: sim_fsm
	$(GTKWAVE) $(BUILD)/tb_fsm.vcd &

# ── clk_div_v2 DDR 20 MHz (self-checking) ────────────────────────────────────
sim_clkv2: $(BUILD)/.analysed tb/tb_clk_div_v2.vhd
	$(GHDL) -a --std=$(STD) --workdir=$(BUILD) tb/tb_clk_div_v2.vhd
	$(GHDL) -e --std=$(STD) --workdir=$(BUILD) tb_clk_div_v2
	$(GHDL) -r --std=$(STD) --workdir=$(BUILD) tb_clk_div_v2 \
	    --vcd=$(BUILD)/tb_clk_div_v2.vcd --stop-time=500ns
	@echo "tb_clk_div_v2 OK"

wave_clkv2: sim_clkv2
	$(GTKWAVE) $(BUILD)/tb_clk_div_v2.vcd &

# ── All self-checking testbenches ─────────────────────────────────────────────
sim_all: sim_accu sim_clkv2
	@echo "================================================"
	@echo " All self-checking testbenches passed"
	@echo "================================================"

# ── Clean ─────────────────────────────────────────────────────────────────────
clean:
	rm -rf $(BUILD)
