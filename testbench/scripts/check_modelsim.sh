#!/bin/bash

set -e
MODELSIM_DIR=/opt/altera/13.1/modelsim_ase/bin

mkdir -p check_modelsim
rm -f check_modelsim/${1}_modelsim.txt

rm -rf temp/check_modelsim_$1
mkdir -p temp/check_modelsim_$1
cd temp/check_modelsim_$1

cat ../../spec/${1}_spec.v ../../scripts/check.v ../../rtl/$1.v > runme.v
cp ../../refdat/${1}_refdat.txt refdat.txt

{
	$MODELSIM_DIR/vlib work
	$MODELSIM_DIR/vlog +define+MATCH_DC runme.v
	$MODELSIM_DIR/vsim -c -do "run -all; exit" work.check
} > ${1}_modelsim.txt

mv ${1}_modelsim.txt ../../check_modelsim/

