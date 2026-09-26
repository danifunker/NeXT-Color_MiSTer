derive_pll_clocks
derive_clock_uncertainty

# core specific constraints

# ----------------------------------------------------------------------------
# Pixel-clock domain (rtl/pll_vid.v, 100 MHz) -- asynchronous to everything.
# ----------------------------------------------------------------------------
# sys_top.sdc groups only the main core PLL, so a second PLL would land in no
# group and every framework path touching CLK_VIDEO would be timed against
# unrelated domains (MacQuadra800.sdc and MacLC.sdc learned this).  The
# clk_sys <-> clk_vid crossings are 2FF synchronizers (*_meta) and the
# quasi-static TMC timing registers (tc_vtiming re-samples them).
set_clock_groups -asynchronous -group [get_clocks {emu|pllv|*|divclk}]

set_false_path -to [get_keepers {*_meta*}]
