#!/bin/bash

rtl=$1
syn_list=$( echo $2 | tr , ' ' )
inp_list=$( echo $3 | tr , ' ' )
pat_list=$( echo $4 | tr , ' ' )
und_list=$( echo $5 | tr , ' ' )

cat << EOT
#include "obj_dir/Vtestbench.h"
#include "verilated.cpp"
#include "../../scripts/verilator_tb.h"

// bash $0 $*

// rtl=$rtl
// syn_list=$syn_list
// inp_list=$inp_list
// pat_list=$pat_list
// und_list=$und_list

int main() {
EOT

for pat in $pat_list; do
	echo "	set_pattern(\"$pat\");"
	for inp in $inp_list; do
		bits=$( expr $( sed "/input.* $inp;/ !d; s/.*\[//; s/:.*//;" rtl.v ) + 1 )
		if [ $bits -le 8 ]; then
			echo "	set_input8(\"$inp\", tb.$inp, $bits);"
		elif [ $bits -le 16 ]; then
			echo "	set_input16(\"$inp\", tb.$inp, $bits);"
		elif [ $bits -le 32 ]; then
			echo "	set_input32(\"$inp\", tb.$inp, $bits);"
		elif [ $bits -le 64 ]; then
			echo "	set_input64(\"$inp\", tb.$inp, $bits);"
		else
			echo "	set_inputW(\"$inp\", tb.$inp, $bits);"
		fi
	done | tac
	echo "	print_input_patterns();"
	echo "	tb.eval();"
	bits=$( expr $( sed "/output.* y;/ !d; s/.*\[//; s/:.*//;" rtl.v ) + 1 )
	echo "	set_undef(\"${und_list%% *}\");"
	und_list="${und_list#* }"
	for syn in $syn_list; do
		if [ $bits -le 8 ]; then
			echo "	get_output8(\"$syn\", tb.${syn}_y, $bits);"
		elif [ $bits -le 16 ]; then
			echo "	get_output16(\"$syn\", tb.${syn}_y, $bits);"
		elif [ $bits -le 32 ]; then
			echo "	get_output32(\"$syn\", tb.${syn}_y, $bits);"
		elif [ $bits -le 64 ]; then
			echo "	get_output64(\"$syn\", tb.${syn}_y, $bits);"
		else
			echo "	get_outputW(\"$syn\", tb.${syn}_y, $bits);"
		fi
	done
	echo "	printf(\"++RPT++ ----\\n\");"
	echo "	pattern_idx++;"
done

cat << EOT
	tb.final();
	printf("++OK++\n");
	return 0;
}
EOT
