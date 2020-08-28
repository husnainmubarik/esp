#!/bin/bash

num_acc_tiles=0
esp_config="$1/socs/$2/.esp_config"
DEVICE=$3
device=$(echo ${DEVICE} | awk '{print tolower($0)}') 
declare -a accelerators

tile_acc="$1/socs/$2/sldgen/tile_acc.vhd"
dpr_srcs="$1/socs/$2/sldgen/dpr_srcs"
dpr_bbox="$dpr_srcs/tile_acc_bbox.vhd"
original_src="vivado/srcs.tcl"
temp_srcs="/tmp/temp_srcs.tcl"

while read line
do
    for word in $line
    do
        if [[ $word == *"TILE"* ]]; then
            _line=( $line ) 
            tile_token=${_line[0]}
            tile_index=${_line[2]}
            tile_type=${_line[3]}
            acc_name=${_line[4]}
            if [ $tile_type == "acc" ]; then
                accelerators[$num_acc_tiles, 0]=$tile_index;
                accelerators[$num_acc_tiles, 1]=$(echo ${acc_name} | awk '{print tolower($0)}');    
                ((num_acc_tiles++));
            fi
            echo $tile_token $tile_index $tile_type $acc_name;
        fi
    done
done < $esp_config
echo "number of accelerator tiles is $num_acc_tiles";
echo "$1    $2   $3"
for i in $num_acc_tiles
do
    echo "tile id ${accelerators[$i, 0]} accelerator name ${accelerators[$i,1]}"
done

#initialize tiles with accelerators
for i in $num_acc_tiles
do
    prj_source="$1/socs/$2/vivado/srcs.tcl"
    acc_dir="$dpr_srcs/accelerator_$i";
    output="$acc_dir/src.prj"
    
echo " " > $output
while read -r type ext addr
do
    if [[ "$ext" == *"tile_acc.vhd"* ]] || [[ "$ext" == *"tile_acc_bbox.vhd"* ]]; then
        echo "vhdl xil_defaultlib $acc_dir/tile_acc_$i.vhd" >> $output;
    elif [ "$type" == "read_verilog" ] && [ "$ext" == "-sv" ] && [[ "$addr" != *"nbdcache"* ]] && [[ "$addr" != *"miss_handler"* ]]; then
        echo "system xil_defaultlib $addr" >> $output
    elif [ "$type" == "read_vhdl" ]; then
        echo "vhdl xil_defaultlib $ext" >> $output
    elif [ "$type" == "read_verilog" ] && [ "$ext" != "-sv" ]; then
        echo "verilog  xil_defaultlib $ext" >> $output
    else
        echo " "  
    fi;
done < $prj_source
done

dpr_syn_tcl="vivado_dpr/ooc_syn.tcl"
echo "set tclParams [list hd.visual 1]" > $dpr_syn_tcl;
echo "set tclHome \"$1/socs/common/Tcl\" " >> $dpr_syn_tcl;
echo "set tclDir \$tclHome " >> $dpr_syn_tcl;
echo "set projDir \"$1/socs/$2/vivado_dpr\" " >> $dpr_syn_tcl;
echo "source \$tclDir/design_utils.tcl" >> $dpr_syn_tcl;
echo "source \$tclDir/log_utils.tcl" >> $dpr_syn_tcl;
echo "source \$tclDir/synth_utils.tcl" >> $dpr_syn_tcl;
echo "source \$tclDir/impl_utils.tcl" >> $dpr_syn_tcl;
echo "source \$tclDir/pr_utils.tcl" >> $dpr_syn_tcl;
echo "source \$tclDir/log_utils.tcl" >> $dpr_syn_tcl;
echo "source \$tclDir/hd_floorplan_utils.tcl" >> $dpr_syn_tcl;

echo " " >> $dpr_syn_tcl;

echo "####### FPGA type #######" >> $dpr_syn_tcl;
echo "set part $device" >> $dpr_syn_tcl;
echo "check_part \$part" >> $dpr_syn_tcl;

echo "set run.topSynth  0" >> $dpr_syn_tcl;
echo "set run.rmSynth   1" >> $dpr_syn_tcl;
echo "set run.prImpl    1" >> $dpr_syn_tcl;
echo "set run.prVerify  1" >> $dpr_syn_tcl;
echo "set run.writeBitstream 1" >> $dpr_syn_tcl;

echo "####Report and DCP controls - values: 0-required min; 1-few extra; 2-all" >> $dpr_syn_tcl;
echo "set verbose      1" >> $dpr_syn_tcl;
echo "set dcpLevel     1" >> $dpr_syn_tcl;

echo " " >> $dpr_syn_tcl;

echo "####Output Directories" >> $dpr_syn_tcl;
echo "set synthDir  \$projDir/Synth" >> $dpr_syn_tcl;
echo "set implDir   \$projDir/Implement" >> $dpr_syn_tcl;
echo "set dcpDir    \$projDir/Checkpoint" >> $dpr_syn_tcl;
echo "set bitDir    \$projDir/Bitstreams" >> $dpr_syn_tcl;

echo " " >> $dpr_syn_tcl;

echo "####Input Directories " >> $dpr_syn_tcl;
echo "set srcDir     \$projDir/Sources" >> $dpr_syn_tcl;
echo "set rtlDir     \$srcDir/hdl" >> $dpr_syn_tcl;
echo "set prjDir     \$srcDir/project" >> $dpr_syn_tcl;
echo "set xdcDir     \$srcDir/xdc" >> $dpr_syn_tcl;
echo "set coreDir    \$srcDir/cores" >> $dpr_syn_tcl;
echo "set netlistDir \$srcDir/netlist" >> $dpr_syn_tcl;

echo " " >> $dpr_syn_tcl;

echo "#################################################################### " >> $dpr_syn_tcl; 
echo "### Top Module Definitions" >> $dpr_syn_tcl; 
echo "#################################################################### " >> $dpr_syn_tcl; 
echo "set top \"top\" " >> $dpr_syn_tcl; 
echo "set static \"Static\" " >> $dpr_syn_tcl; 
echo "add_module \$static " >> $dpr_syn_tcl; 
echo "set_attribute module \$static moduleName    \$top" >> $dpr_syn_tcl; 
echo "set_attribute module \$static top_level     1 " >> $dpr_syn_tcl; 
echo "#set_attribute module \$static synthCheckpoint \$synthDir/\$static/top_synth.dcp " >> $dpr_syn_tcl; 
echo "set_attribute module \$static synth         \${run.topSynth} " >> $dpr_syn_tcl; 


echo "####################################################################" >> $dpr_syn_tcl; 
echo "### RP Module Definitions " >> $dpr_syn_tcl; 
echo "#################################################################### " >> $dpr_syn_tcl; 

for i in $num_acc_tiles
do
    acc_dir="$dpr_srcs/accelerator_$i";
    prj_src="$acc_dir/src.prj"

    echo "add_module ${accelerators[$i, 1]} " >> $dpr_syn_tcl; 
    echo "set_attribute module ${accelerators[$i, 1]} moduleName tile_acc" >> $dpr_syn_tcl; 
    echo "set_attribute module ${accelerators[$i, 1]} prj $prj_src" >> $dpr_syn_tcl; 
    echo "set_attribute module ${accelerators[$i, 1]} synth  \${run.rmSynth}" >> $dpr_syn_tcl; 
done

echo "####################################################################" >> $dpr_syn_tcl; 
echo "### Implementation " >> $dpr_syn_tcl; 
echo "#################################################################### " >> $dpr_syn_tcl; 

echo "add_implementation top_dpr " >> $dpr_syn_tcl;
echo "set_attribute impl top_dpr top        \$top" >> $dpr_syn_tcl;
echo "set_attribute impl top_dpr pr.impl      1" >> $dpr_syn_tcl;
echo "set_attribute impl top_dpr implXDC     [list [ list $1/constraints/$2/pblocks.xdc $1/constraints/$2/$2.xdc $1/constraints/$2/$2-eth-constraints.xdc $1/constraints/$2/$2-eth-pins.xdc  $1/socs/$2/vivado/esp-$2.srcs/sources_1/ip/mig/mig/user_design/constraints/mig.xdc $1/socs/$2/vivado/esp-$2.srcs/sources_1/ip/sgmii/synth/sgmii.xdc ] ]" >> $dpr_syn_tcl;

echo "set_property SEVERITY {Warning} [get_drc_checks HDPR-41]" >> $dpr_syn_tcl;
    
echo "set_attribute impl top_dpr partitions  [list [list \$static \$top  implement ] \\" >> $dpr_syn_tcl; 

for i in $num_acc_tiles
do
    echo "[list ${accelerators[$i, 1]}  esp_1/tiles_gen[${accelerators[$i, 0]}].accelerator_tile.tile_acc_i implement ] \\" >>  $dpr_syn_tcl;
done
echo "]"  >> $dpr_syn_tcl;
echo "set_attribute impl top_dpr impl       \${run.prImpl}" >> $dpr_syn_tcl; 
echo "set_attribute impl top_dpr verify     \${run.prVerify}" >> $dpr_syn_tcl;
echo "set_attribute impl top_dpr bitstream  \${run.writeBitstream}" >> $dpr_syn_tcl;


echo "source \$tclDir/run.tcl" >> $dpr_syn_tcl; 
echo "exit" >> $dpr_syn_tcl; 


#prj_source="$1/socs/$2/vivado/srcs.tcl"
#output="$1/socs/$2/vivado_dpr/src.prj"

#rm -rf $output
#while read -r type ext addr
#do
#  if [ $type == "read_verilog" ] && [ $ext == "-sv" ] && [[ $addr != *"nbdcache"* ]] && [[ $addr != *"miss_handler"* ]]; then 
#    echo "system xil_defaultlib $addr" >> $output
#  elif [ $type == "read_vhdl" ]; then
#    echo "vhdl xil_defaultlib $ext" >> $output
#  elif [ $type == "read_verilog" ] && [ $ext != "-sv" ]; then 
#    echo "verilog  xil_defaultlib $ext" >> $output
#  else
#    echo " "  
#  fi

#done < "$prj_source"
