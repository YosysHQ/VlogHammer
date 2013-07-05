#!/bin/bash

if [ $# -eq 0 ]; then
	echo "Usage: $0 <job_id>" >&2
	exit 1
fi

job="$1"
set -e --

. /opt/Xilinx/14.5/ISE_DS/settings64.sh
set -x

rm -rf temp/syn_xst_$job
mkdir -p temp/syn_xst_$job
cd temp/syn_xst_$job

cat > $job.xst <<- EOT
	run
	-ifn $job.prj -ofn $job -p artix7 -top $job
	-iobuf NO -ram_extract NO -rom_extract NO -use_dsp48 NO
	-fsm_extract YES -fsm_encoding Auto
EOT

cat > $job.prj <<- EOT
	verilog work "../../rtl/$job.v"
EOT

xst -ifn $job.xst
netgen -w -ofmt verilog $job.ngc $job
sed -i '/^`ifndef/,/^`endif/ d; s/ *Timestamp: .*//;' $job.v

mkdir -p ../../syn_xst
cp $job.v ../../syn_xst/$job.v

sync
echo READY.
