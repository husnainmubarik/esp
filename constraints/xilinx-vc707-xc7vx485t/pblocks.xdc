#set_property HD.RECONFIGURABLE true [get_cells system_i/slot_p0_s0]

set_property HD.RECONFIGURABLE true [get_cells esp_1/tiles_gen[2].accelerator_tile.tile_acc_i]

create_pblock pblock_1
add_cells_to_pblock [get_pblocks pblock_1] [get_cells -quiet [list esp_1/tiles_gen[2].accelerator_tile.tile_acc_i]]
resize_pblock [get_pblocks pblock_1] -add {SLICE_X48Y0:SLICE_X107Y99}
resize_pblock [get_pblocks pblock_1] -add {RAMB18_X4Y0:RAMB18_X6Y39}
resize_pblock [get_pblocks pblock_1] -add {RAMB36_X4Y0:RAMB36_X6Y19}
resize_pblock [get_pblocks pblock_1] -add {DSP48_X3Y0:DSP48_X8Y39}

set_property RESET_AFTER_RECONFIG true [get_pblocks pblock_1]
set_property SNAPPING_MODE ON [get_pblocks pblock_1]


#set_property HD.RECONFIGURABLE true [get_cells gen_mig.ddrc/MCB_inst]

#create_pblock pblock_2
#add_cells_to_pblock [get_pblocks pblock_2] [get_cells -quiet [list gen_mig.ddrc/MCB_inst]]
#resize_pblock [get_pblocks pblock_2] -add {SLICE_X174Y0:SLICE_X209Y149}
#resize_pblock [get_pblocks pblock_2] -add {RAMB18_X11Y0:RAMB18_X13Y59}
#resize_pblock [get_pblocks pblock_2] -add {RAMB36_X11Y0:RAMB36_X13Y29}
#resize_pblock [get_pblocks pblock_2] -add {DSP48_X17Y0:DSP48_X19Y59}

#set_property RESET_AFTER_RECONFIG true [get_pblocks pblock_2]
#set_property SNAPPING_MODE ON [get_pblocks pblock_2]


#set_property HD.RECONFIGURABLE true [get_cells eth0.sgmii0/core_wrapper]

#create_pblock pblock_3
#add_cells_to_pblock [get_pblocks pblock_3] [get_cells -quiet [list eth0.sgmii0/core_wrapper]]
#resize_pblock [get_pblocks pblock_3] -add {SLICE_X174Y200:SLICE_X209Y349}
#resize_pblock [get_pblocks pblock_3] -add {RAMB18_X11Y80:RAMB18_X13Y139}
#resize_pblock [get_pblocks pblock_3] -add {RAMB36_X11Y40:RAMB36_X13Y69}
#resize_pblock [get_pblocks pblock_3] -add {DSP48_X17Y80:DSP48_X19Y139}

#set_property RESET_AFTER_RECONFIG true [get_pblocks pblock_3]
#set_property SNAPPING_MODE ON [get_pblocks pblock_3]

set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]

