## =============================================================================
## Constraints : 32-tap FIR Filter — Nexys A7 (Artix-7 XC7A100T-CSG324)
## =============================================================================

## -----------------------------------------------------------------------------
## System clock — 100 MHz on-board oscillator
## -----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name sys_clk [get_ports clk]

## -----------------------------------------------------------------------------
## Reset — BTNC (centre push button, active high)
## -----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports reset]

## -----------------------------------------------------------------------------
## PmodAD1 — PMOD connector JA (ADC, top row)
##   JA1 = filter_in   (MISO from ADC)
##   JA2 = PMODAD1_CS  (CS_N)
##   JA3 = PMODAD1_CLK (SCLK)
## -----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN C17 IOSTANDARD LVCMOS33} [get_ports filter_in]
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports PMODAD1_CS]
set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS33} [get_ports PMODAD1_CLK]

## -----------------------------------------------------------------------------
## PmodDA1 — PMOD connector JB (DAC, top row)
##   JB1 = filter_out  (MOSI to DAC)
##   JB2 = PMODDA1_CS  (ext_sync / CS_N)
##   JB3 = PMODDA1_CLK (SCLK)
## -----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN D14 IOSTANDARD LVCMOS33} [get_ports filter_out]
set_property -dict {PACKAGE_PIN F16 IOSTANDARD LVCMOS33} [get_ports PMODDA1_CS]
set_property -dict {PACKAGE_PIN G16 IOSTANDARD LVCMOS33} [get_ports PMODDA1_CLK]

## -----------------------------------------------------------------------------
## Timing exceptions
## SPI outputs are driven at clock_pmod rate (≤ 25 MHz in v1, 20 MHz in v2).
## Relaxed output delay constraints relative to 100 MHz system clock.
## -----------------------------------------------------------------------------
set_output_delay -clock sys_clk -max 4.0 [get_ports {PMODAD1_CS PMODAD1_CLK PMODDA1_CS PMODDA1_CLK filter_out}]
set_output_delay -clock sys_clk -min 0.5 [get_ports {PMODAD1_CS PMODAD1_CLK PMODDA1_CS PMODDA1_CLK filter_out}]
set_input_delay  -clock sys_clk -max 4.0 [get_ports filter_in]
set_input_delay  -clock sys_clk -min 0.5 [get_ports filter_in]

## -----------------------------------------------------------------------------
## Bitstream configuration
## -----------------------------------------------------------------------------
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
