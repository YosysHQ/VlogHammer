#!/bin/bash

set -e

mkdir -p spec
rm -f spec/${1}_spec.v

input_bits=$( sed '/^ *input/ ! d; s,^ *input\( *signed\)\? *\[,,; s,:.*,,;' rtl/$1.v | gawk '{ bits += $1+1; } END { print bits; }' )
output_bits=$( sed '/^ *output/ ! d; s,^ *output\( *signed\)\? *\[,,; s,:.*,,;' rtl/$1.v | gawk '{ bits += $1+1; } END { print bits; }' )
module_args=$( sed '/^ *input/ ! d; s,^ *input\( *signed\)\? *\[,,; s,:.*\],,; s,;,,;' rtl/$1.v | gawk 'BEGIN { cursor='$input_bits'-1; }
		{ printf(".%s(in_v[%d:%d]), ", $2, cursor, cursor-$1); cursor -= $1+1; } END { print ".y(out_v)"; }' )

{
	echo "\`define input_bits $input_bits"
	echo "\`define output_bits $output_bits"
	echo "\`define module_name $1"
	echo "\`define module_args $module_args"
} > spec/${1}_spec.v

