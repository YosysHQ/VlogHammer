#!/bin/bash

set -e

mkdir -p check_verilator
rm -f check_verilator/${1}_verilator.txt

rm -rf temp/check_verilator_$1
mkdir -p temp/check_verilator_$1
cd temp/check_verilator_$1

cp ../../rtl/${1}.v rtl.v
cp ../../spec/${1}_spec.v spec.v
cp ../../refdat/${1}_refdat.txt refdat.txt

echo "#include \"V${1}.h\"" > spec.h
sed 's,^.define ,#define spec_,; s/module_name /\0V/; /module_args/ { s/\.\([a-zA-Z0-9_]\+\)(in_v\[\([0-9]\+\):\([0-9]\+\)\]),\?/SET(uut.\1, \2, \3);/g; s/;[^;]*$/;/; };' < spec.v >> spec.h

if ! verilator -exe -cc -Wno-fatal --top-module ${1} rtl.v ../../scripts/check_verilator.cc > ${1}_verilator.txt 2>&1; then
	if grep -q "Unsupported: Shifting of by over 32-bit number isn't supported." ${1}_verilator.txt; then
		echo "++OK++ (skip)" >> ${1}_verilator.txt
	elif grep -q "Unsupported: Large >64bit \*\* power operator not implemented." ${1}_verilator.txt; then
		echo "++OK++ (skip)" >> ${1}_verilator.txt
	else
		cat ${1}_verilator.txt
		exit 1
	fi
else
	{ make -C obj_dir -f V${1}.mk; ./obj_dir/V${1}; } >> ${1}_verilator.txt 2>&1
fi

mv ${1}_verilator.txt ../../check_verilator/

