#!/bin/bash

if [ $# -ne 2 ]; then
	echo "Usage: $0 <syn_type> <job_name>" >&2
	exit 1
fi

syn="$1"
job="$2"
set -ex --

rm -rf temp/check_${syn}_${job}
mkdir -p temp/check_${syn}_${job}
cd temp/check_${syn}_${job}

cp ../../rtl/$job.v rtl.v
cp ../../syn_$syn/$job.v syn.v

yosys -p "
read_verilog syn.v;
read_verilog ../../scripts/cells_cyclone_iii.v;
read_verilog ../../scripts/cells_xilinx_7.v;
hierarchy -check -top $job;
proc; opt_clean;
flatten $job;
hierarchy -top $job;
write_ilang syn.il
"

mkdir -p ../../cache_${syn}
cp syn.il ../../cache_${syn}/$job.il

{
	egrep '^ *(module|input|output)' rtl.v | sed 's/ y/ y_rtl, y_syn/'
	sed "/^ *module/ ! d; s/.*(//; s/[a-w0-9]\+/.\0(\0)/g; s/y[0-9]*/.\0(\0_rtl)/g; s/^/  ${job}_rtl ${job}_rtl (/;" rtl.v
	sed "/^ *module/ ! d; s/.*(//; s/[a-w0-9]\+/.\0(\0)/g; s/y[0-9]*/.\0(\0_syn)/g; s/^/  ${job}_syn ${job}_syn (/;" rtl.v
	echo "endmodule"
} > top.v

{
	echo "read_verilog rtl.v"
	echo "rename $job ${job}_rtl"

	echo "read_ilang syn.il"
	echo "rename $job ${job}_syn"

	echo "read_verilog top.v"
	echo "flatten ${job}"
	echo "opt_clean"

	ports=$( grep ^module top.v | tr '()' '::' | cut -f2 -d: | tr -d ' ' )
	echo "sat -timeout 60 -verify-no-timeout -show $ports -prove y_rtl y_syn ${job}"
	if [ $syn = yosys ] && [[ $job != expression_* ]]; then
		echo "eval -brute_force_equiv_checker ${job}_rtl ${job}_syn"
	fi
} > check.ys

if yosys -l check.log check.ys; then
	mkdir -p ../../check_${syn}
	cp check.log ../../check_${syn}/${job}.txt
	rm -f ../../check_${syn}/${job}.err
else
	mkdir -p ../../check_${syn}
	echo -n > ../../check_${syn}/${job}.txt
	cp check.log ../../check_${syn}/${job}.err
fi

sync
echo READY.
