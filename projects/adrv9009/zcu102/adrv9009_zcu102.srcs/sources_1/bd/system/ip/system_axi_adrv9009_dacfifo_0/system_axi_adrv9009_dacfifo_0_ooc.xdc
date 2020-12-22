
# This XDC is used only for OOC mode of synthesis, implementation.
# These are default values for timing driven synthesis during OOC flow.
# These values will be overwritten during implementation with information
# from top level.

create_clock -name dma_clk -period 8 [get_ports dma_clk]
create_clock -name dac_clk -period 3.2 [get_ports dac_clk]

################################################################################
