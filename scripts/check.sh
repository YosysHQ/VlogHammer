#!/bin/bash
#
#  VlogHammer -- A Verilog Synthesis Regression Test
#
#  Copyright (C) 2013  Clifford Wolf <clifford@clifford.at>
#  
#  Permission to use, copy, modify, and/or distribute this software for any
#  purpose with or without fee is hereby granted, provided that the above
#  copyright notice and this permission notice appear in all copies.
#  
#  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
#  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
#  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
#  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
#  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
#  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#

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
read_verilog ../../scripts/cells_cyclone_v.v;
read_verilog ../../scripts/cells_xilinx_7.v;
read_verilog ../../scripts/cells_cmos.v;
read_verilog ../../scripts/cells_verific.v;
read_verilog -D SIMLIB_NOMEM -D SIMLIB_NOCHECKS $( yosys-config --datdir )/simlib.v;
read_verilog $( yosys-config --datdir )/simcells.v;
hierarchy -check -top $job;
proc;; flatten;;
write_ilang syn.il
"

mkdir -p ../../cache_${syn}
cp syn.il ../../cache_${syn}/$job.il

{
	egrep '^ *(module|input|output)' rtl.v | sed 's/ y/ y_rtl, y_syn/'
	sed "/^ *module/ ! d; s/.*(//; s/[a-x0-9]\+/.\0(\0)/g; s/y[0-9]*/.\0(\0_rtl)/g; s/^/  ${job}_rtl ${job}_rtl (/;" rtl.v
	sed "/^ *module/ ! d; s/.*(//; s/[a-x0-9]\+/.\0(\0)/g; s/y[0-9]*/.\0(\0_syn)/g; s/^/  ${job}_syn ${job}_syn (/;" rtl.v
	echo "endmodule"
} > top.v

{
	echo "read_verilog rtl.v"
	echo "proc"
	echo "rename $job ${job}_rtl"

	echo "read_ilang syn.il"
	echo "rename $job ${job}_syn"

	echo "read_verilog top.v"
	echo "flatten ${job}"
	echo "opt_clean"

	ports=$( grep ^module top.v | tr '()' '::' | cut -f2 -d: | tr -d ' ' )
	echo "sat -timeout 60 -verify-no-timeout -show $ports -set-def-inputs -prove-x y_rtl y_syn ${job}"
	if [ $syn = yosys ] && ([[ $job == binary_ops_* ]] || [[ $job == concat_ops_* ]] || [[ $job == repeat_ops_* ]] ||
			[[ $job == ternary_ops_* ]] || [[ $job == unary_ops_* ]]); then
		echo "eval -brute_force_equiv_checker_x ${job}_rtl ${job}_syn"
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

rm -rf ../check_${syn}_${job}
echo READY.
