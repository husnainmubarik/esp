#!/bin/bash

#variables related to srcs of accelerators
tile_acc="$1/socs/$2/sldgen/tile_acc.vhd"
dpr_srcs="$1/socs/$2/sldgen/dpr_srcs"
dpr_bbox="$dpr_srcs/tile_acc_bbox.vhd"
original_src="vivado/srcs.tcl"
temp_srcs="/tmp/temp_srcs.tcl"

#variables related to accelerator tiles
num_acc_tiles=0
esp_config="$1/socs/$2/.esp_config"
DEVICE=$3
device=$(echo ${DEVICE} | awk '{print tolower($0)}')
declare -a accelerators
acc_id_match="CFG_TILES_NUM - 1 := 0"

#extract the number of accelerator tiles from esp_config
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

#initialize the accelerator tiles
for i in $num_acc_tiles
do  
    
    acc_dir="$dpr_srcs/accelerator_$i";
    mkdir -p $acc_dir;
    echo " " > $acc_dir/tile_acc_$i.vhd;
    
    while read acc_src
    do
        if [[ $acc_src == *"$acc_id_match"*  ]]; then
            echo "  tile_id : integer range 0 to CFG_TILES_NUM - 1 := ${accelerators[$i, 0]});" >> $acc_dir/tile_acc_$i.vhd;
        else
            echo "  $acc_src" >> $acc_dir/tile_acc_$i.vhd;
        fi
    done <$tile_acc   
done

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
