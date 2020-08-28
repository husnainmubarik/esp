open_checkpoint /home/sholmes/esp/socs/xilinx-vc707-xc7vx485t/vivado/esp-xilinx-vc707-xc7vx485t.runs/synth_1/top.dcp
read_checkpoint -cell eth0.sgmii0/core_wrapper vivado/esp-xilinx-vc707-xc7vx485t.runs/sgmii_synth_1/sgmii.dcp
read_checkpoint -cell gen_mig.ddrc/MCB_inst vivado/esp-xilinx-vc707-xc7vx485t.runs/mig_synth_1/mig.dcp
write_checkpoint -force /home/sholmes/esp/socs/xilinx-vc707-xc7vx485t/vivado/esp-xilinx-vc707-xc7vx485t.runs/synth_1/top_dpr.dcp
close_project
exit
