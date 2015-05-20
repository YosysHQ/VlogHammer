#!/bin/bash

set -e

mkdir -p check_verific
rm -f check_verific/${1}_verific.txt

rm -rf temp/check_verific_$1
mkdir -p temp/check_verific_$1
cd temp/check_verific_$1

verifitest -t $1 -o synth.v ../../rtl/$1.v > synth.log 2>&1

cat ../../spec/${1}_spec.v ../../scripts/check.v synth.v > runme.v
cp ../../refdat/${1}_refdat.txt refdat.txt
iverilog -s check -o runme runme.v ../../scripts/cells_verific.v
./runme > ${1}_verific.txt

mv ${1}_verific.txt ../../check_verific/

