#!/bin/bash

set -e

mkdir -p check_vivado
rm -f check_vivado/${1}_vivado.txt

rm -rf temp/check_vivado_$1
mkdir -p temp/check_vivado_$1
cd temp/check_vivado_$1

sed 's/^module/(* use_dsp48="no" *) module/;' < ../../rtl/$1.v > rtl.v

cat > synth.tcl <<- EOT
	read_verilog rtl.v
	synth_design -part xc7k70t -top $1
	write_verilog -force synth.v
EOT

vivado -mode batch -source synth.tcl > synth.log 2>&1

grep -hv '^`timescale' ../../spec/${1}_spec.v ../../scripts/check.v \
		../../scripts/cells_xilinx_7.v synth.v > runme.v
cp ../../refdat/${1}_refdat.txt refdat.txt

xvlog --nolog runme.v > xvlog.log 2>&1
xelab -R work.check > ${1}_vivado.txt

mv ${1}_vivado.txt ../../check_vivado/

