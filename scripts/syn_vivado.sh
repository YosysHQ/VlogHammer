#!/bin/bash

if [ $# -eq 0 ]; then
	echo "Usage: $0 <job_id>" >&2
	exit 1
fi

job="$1"
set -ex --

rm -rf temp/syn_vivado_$job
mkdir -p temp/syn_vivado_$job
cd temp/syn_vivado_$job

sed 's/^module/(* use_dsp48="no" *) module/;' < ../../rtl/$job.v > rtl.v
cat > $job.tcl <<- EOT
	read_verilog rtl.v
	synth_design -part xc7k70t -top $job
	write_verilog -force synth.v
EOT

/opt/Xilinx/Vivado/2013.2/bin/vivado -mode batch -source $job.tcl

mkdir -p ../../syn_vivado
cp synth.v ../../syn_vivado/$job.v

sync
echo READY.
