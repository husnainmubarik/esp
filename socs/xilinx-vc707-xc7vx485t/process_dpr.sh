#!/bin/bash

#variables related to srcs of accelerators
tile_acc="$1/socs/$2/sldgen/tile_acc.vhd"
dpr_srcs="$1/socs/$2/sldgen/dpr_srcs"
dpr_bbox="$dpr_srcs/tile_acc_bbox.vhd"
original_src="$1/socs/$2/vivado/srcs.tcl"
temp_srcs="/tmp/temp_srcs.tcl"

#variables related to accelerator tiles
num_acc_tiles=0
num_old_acc_tiles=0
num_modified_acc_tiles=0
esp_config="$1/socs/$2/.esp_config"
esp_config_old="$1/socs/$2/vivado_dpr/.esp_config"
DEVICE=$3
device=$(echo ${DEVICE} | awk '{print tolower($0)}')
acc_id_match="CFG_TILES_NUM - 1 := 0"
declare -A new_accelerators old_accelerators modified_accelerators

#extract the number of accelerator tiles from esp_config
function extract_acc() {
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
                new_accelerators["$num_acc_tiles,0"]=$tile_index;
                new_accelerators["$num_acc_tiles,1"]=$(echo ${acc_name} | awk '{print tolower($0)}');
                ((num_acc_tiles++));
            fi
#            echo $tile_token $tile_index $tile_type $acc_name $1 $2 $3;
        fi
    done
done < $esp_config

#for ((i=0; i<num_acc_tiles; i++)) 
#do
#echo " new accelerator $i is ${new_accelerators[${i},0]}  ${new_accelerators[${i},1]};"
#done

}

function extract_acc_old() {
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
                old_accelerators["$num_old_acc_tiles,0"]=$tile_index;
                old_accelerators["$num_old_acc_tiles,1"]=$(echo ${acc_name} | awk '{print tolower($0)}');
                ((num_old_acc_tiles++));
            fi
#            echo $tile_token $tile_index $tile_type $acc_name $1 $2 $3;
        fi
    done
done < $esp_config_old
}

function diff_accelerators() {
for ((i=0; i<$num_acc_tiles; i++))
do
    if [ ${new_accelerators[$i,1]} != ${old_accelerators[$i,1]} ]; then
        modified_accelerators[$num_modified_acc_tiles,0]=${new_accelerators[$i,0]};
        modified_accelerators[$num_modified_acc_tiles,1]=${new_accelerators[$i,1]};
        ((num_modified_acc_tiles++));
    fi
       
done 

    echo "number modified tiles is equal to $num_modified_acc_tiles "
}
#initialize the accelerator tiles
function initialize_acc_tiles() {
for ((i=0; i<$num_acc_tiles; i++))
do

    acc_dir="$dpr_srcs/tile_${new_accelerators[$i,0]}_acc";
    mkdir -p $acc_dir;
    echo " " > $acc_dir/tile_acc_$i.vhd;

    while read acc_src
    do
        if [[ $acc_src == *"$acc_id_match"*  ]]; then
            echo "  tile_id : integer range 0 to CFG_TILES_NUM - 1 := ${new_accelerators[$i,0]});" >> $acc_dir/tile_acc_$i.vhd;
        else
            echo "  $acc_src" >> $acc_dir/tile_acc_$i.vhd;
        fi
    done <$tile_acc
done
}

#initialize bbox tiles
function initialize_bbox_tiles() {
mkdir -p $dpr_srcs
echo " " > $dpr_bbox;
echo " " > $temp_srcs;

while read line
do
    if [[ $line == "begin" ]]; then
        echo "  attribute black_box : string;" >> $dpr_bbox;
        echo "  attribute black_box of rtl : architecture is \"true\";" >> $dpr_bbox;
    fi
    echo "  $line" >> $dpr_bbox;
done < $tile_acc


while read src_list
do
    if [[ $src_list == *"tile_acc.vhd" ]]; then
        echo "read_vhdl /home/sholmes/esp/socs/xilinx-vc707-xc7vx485t/sldgen/dpr_srcs/tile_acc_bbox.vhd" >> $temp_srcs;
    else
        echo "$src_list" >> $temp_srcs;
    fi
done < $original_src

mv $temp_srcs $original_src;
}

#initialize tiles with accelerators
function add_acc_prj_file() {
for ((i=0; i<$num_acc_tiles; i++))
do
    prj_source="$1/socs/$2/vivado/srcs.tcl"
    acc_dir="$dpr_srcs/tile_${new_accelerators[$i,0]}_acc";
    #acc_dir="$dpr_srcs/accelerator_$i";
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
    fi;
done < $prj_source
done
}

#generate dpr script
function gen_dpr() {
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

echo "number of acc tiles inside dpr gen is $num_acc_tiles ";
if [[ "$4" == "DPR" ]]; then
    for ((i=0; i<num_acc_tiles; i++))
    do
        acc_dir="$dpr_srcs/tile_${new_accelerators[$i,0]}_acc";
        #acc_dir="$dpr_srcs/accelerator_$i";
        prj_src="$acc_dir/src.prj"
        echo "add_module ${new_accelerators[$i,1]} " >> $dpr_syn_tcl;
        echo "set_attribute module ${new_accelerators[$i,1]} moduleName tile_acc" >> $dpr_syn_tcl;
        echo "set_attribute module ${new_accelerators[$i,1]} prj $prj_src" >> $dpr_syn_tcl;
        echo "set_attribute module ${new_accelerators[$i,1]} synth  \${run.rmSynth}" >> $dpr_syn_tcl;
    done
elif [[ "$4" == "ACC" ]] && [[ "$num_modified_acc_tiles" != "0" ]]; then
    for ((i=0; i<$num_acc_tiles; i++))
    do
        acc_dir="$dpr_srcs/tile_${new_accelerators[$i,0]}_acc";
        #acc_dir="$dpr_srcs/accelerator_$i";
        prj_src="$acc_dir/src.prj"
        echo "add_module ${new_accelerators[$i,1]} " >> $dpr_syn_tcl;
        echo "set_attribute module ${new_accelerators[$i,1]} moduleName tile_acc" >> $dpr_syn_tcl;
        echo "set_attribute module ${new_accelerators[$i,1]} prj $prj_src" >> $dpr_syn_tcl;
        if [[ ${modified_accelerators[$i,0]} == ${new_accelerators[$i,0]} ]]; then
            echo "set_attribute module ${new_accelerators[$i,1]} synth  \${run.rmSynth}" >> $dpr_syn_tcl;
        fi;
    done
fi;

echo "####################################################################" >> $dpr_syn_tcl;
echo "### Implementation " >> $dpr_syn_tcl;
echo "#################################################################### " >> $dpr_syn_tcl;

echo "add_implementation top_dpr " >> $dpr_syn_tcl;
echo "set_attribute impl top_dpr top        \$top" >> $dpr_syn_tcl;
echo "set_attribute impl top_dpr pr.impl      1" >> $dpr_syn_tcl;
echo "set_attribute impl top_dpr implXDC     [list [ list $1/constraints/$2/pblocks.xdc $1/constraints/$2/$2.xdc $1/constraints/$2/$2-eth-constraints.xdc $1/constraints/$2/$2-eth-pins.xdc  $1/socs/$2/vivado/esp-$2.srcs/sources_1/ip/mig/mig/user_design/constraints/mig.xdc $1/socs/$2/vivado/esp-$2.srcs/sources_1/ip/sgmii/synth/sgmii.xdc ] ]" >> $dpr_syn_tcl;

echo "set_property SEVERITY {Warning} [get_drc_checks HDPR-41]" >> $dpr_syn_tcl;

if [[ "$4" == "DPR" ]]; then
    echo "set_attribute impl top_dpr partitions  [list [list \$static \$top  implement ] \\" >> $dpr_syn_tcl;
    for ((i=0; i<$num_acc_tiles; i++))
    do
        echo "[list ${new_accelerators[$i,1]}  esp_1/tiles_gen[${new_accelerators[$i,0]}].accelerator_tile.tile_acc_i implement ] \\" >>  $dpr_syn_tcl;
    done
    echo "]"  >> $dpr_syn_tcl;
elif [[ "$4" == "ACC" ]] && [[ "$num_modified_acc_tiles" != "0" ]]; then
    
    echo "set_attribute impl top_dpr partitions  [list [list \$static \$top  import ] \\" >> $dpr_syn_tcl; 
    
    for ((i=0, j=0; j<$num_acc_tiles; j++))
    do
        if [[ ${modified_accelerators[$i,0]} == ${new_accelerators[$i,0]} ]]; then
            echo "[list ${modified_accelerators[$i,1]}  esp_1/tiles_gen[${modified_accelerators[$i,0]}].accelerator_tile.tile_acc_i implement ] \\" >>  $dpr_syn_tcl;
            ((i++));
        else
            echo "[list ${new_accelerators[$j,1]}  esp_1/tiles_gen[${new_accelerators[$j,0]}].accelerator_tile.tile_acc_i import ] \\" >>  $dpr_syn_tcl;
        fi
    done
    echo "]"  >> $dpr_syn_tcl;
else
    echo "No accelerator tile was modified ";
    exit;
fi;
echo "set_attribute impl top_dpr impl       \${run.prImpl}" >> $dpr_syn_tcl;
echo "set_attribute impl top_dpr verify     \${run.prVerify}" >> $dpr_syn_tcl;
echo "set_attribute impl top_dpr bitstream  \${run.writeBitstream}" >> $dpr_syn_tcl;


echo "source \$tclDir/run.tcl" >> $dpr_syn_tcl;
echo "exit" >> $dpr_syn_tcl;
}

if [ "$4" == "BBOX" ]; then
    extract_acc $1 $2 $3 
    initialize_acc_tiles $1 $2 $3
    initialize_bbox_tiles $1 $2 $3
elif [ "$4" == "DPR" ]; then 
    extract_acc $1 $2 $3
    initialize_acc_tiles $1 $2 $3
    add_acc_prj_file $1 $2 $3
    gen_dpr $1 $2 $3 $4
elif [ $4 == "ACC" ]; then
    extract_acc $1 $2 $3; \
    extract_acc_old $1 $2 $3; \
    diff_accelerators $1 $2 $3; 
    initialize_acc_tiles $1 $2 $3
    add_acc_prj_file $1 $2 $3
    gen_dpr $1 $2 $3 $4;
fi;

