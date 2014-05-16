#!/bin/bash

set -e

mkdir -p check_yosys
rm -f check_yosys/${1}_yosys.txt

rm -rf temp/check_yosys_$1
mkdir -p temp/check_yosys_$1
cd temp/check_yosys_$1

yosys -q -l synth.log -p 'proc; opt; techmap; opt; abc;;' -o synth.v ../../rtl/$1.v

cat ../../spec/${1}_spec.v ../../scripts/check.v synth.v > runme.v
cp ../../refdat/${1}_refdat.txt refdat.txt
iverilog -s check -o runme runme.v
./runme > ../../check_yosys/${1}_yosys.txt

