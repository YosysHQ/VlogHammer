#!/bin/bash

if [ $# -ne 1 ]; then
	echo "Usage: $0 <job_name>" >&2
	exit 1
fi

job="$1"
set -ex --

rm -rf temp/syn_yosys_$job
mkdir -p temp/syn_yosys_$job
cd temp/syn_yosys_$job

yosys -q -l synth.log -b 'verilog -noattr' -o synth.v \
      -p 'hierarchy; proc; opt; techmap; opt; abc; opt' ../../rtl/$job.v

mkdir -p ../../syn_yosys
cp synth.v ../../syn_yosys/$job.v

sync
echo READY.
