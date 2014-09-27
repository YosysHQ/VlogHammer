#!/bin/bash

mkdir -p tb/quartus_$1
cd tb/quartus_$1

cp ../../rtl/$1.v .

{
	echo '`timescale 1ns / 1ps'
	echo "module ${1}_tb;"
	egrep '^ *(input|output)' $1.v | sed 's, input , reg ,; s, output , wire ,;'
	echo
	egrep '^module' $1.v | sed "s,module $1,  $1 uut ,;"
	echo
	echo "  initial begin"
	echo "    a = 23; #1;"
	echo '    $display("%b %b", a, y);'
	echo "  end"
	echo "endmodule"
} > ${1}_tb.v

{
	echo "/opt/altera/14.0/quartus/bin/quartus_map $1 --source=$1.v --family='Cyclone V'"
	echo "/opt/altera/14.0/quartus/bin/quartus_fit $1 --part=5CGXFC7D6F27C6"
	echo "/opt/altera/14.0/quartus/bin/quartus_eda $1 --simulation --tool=modelsim --format=verilog"
	echo
	echo "/opt/altera/14.0/modelsim_ase/bin/vlib gold"
	echo "/opt/altera/14.0/modelsim_ase/bin/vlog -work gold $1.v"
	echo "/opt/altera/14.0/modelsim_ase/bin/vlog -work gold ${1}_tb.v"
	echo
	echo "/opt/altera/14.0/modelsim_ase/bin/vlib gate"
	echo "/opt/altera/14.0/modelsim_ase/bin/vlog -work gate simulation/modelsim/$1.vo"
	echo "/opt/altera/14.0/modelsim_ase/bin/vlog -work gate /opt/altera/14.0/quartus/eda/sim_lib/cyclonev_atoms.v"
	echo "/opt/altera/14.0/modelsim_ase/bin/vlog -work gate ${1}_tb.v"
	echo
	echo "/opt/altera/14.0/modelsim_ase/bin/vsim -c -do 'run -all; exit' gold.${1}_tb"
	echo "/opt/altera/14.0/modelsim_ase/bin/vsim -c -do 'run -all; exit' gate.${1}_tb"
} > $1.sh

{
	echo "{"
	echo "echo '**Test case:**'"
	echo "echo '    :::Verilog'"
	echo "cat $1.v | sed -r 's,^,    ,'"
	echo "echo"
	echo "echo '**Test bench:**'"
	echo "echo '    :::Verilog'"
	echo "cat ${1}_tb.v | sed -r 's,^,    ,'"
	echo "echo"
	echo "echo '**Test script:**'"
	echo "echo '    :::Shell'"
	echo "cat ${1}.sh | sed -r 's,^,    ,'"
	echo "} | xsel"
	echo "xsel -o | xsel -b"
} > select.sh

