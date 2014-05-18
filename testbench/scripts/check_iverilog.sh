#!/bin/bash

set -e

mkdir -p check_iverilog
rm -f check_iverilog/${1}_iverilog.txt

rm -rf temp/check_iverilog_$1
mkdir -p temp/check_iverilog_$1
cd temp/check_iverilog_$1

cat ../../spec/${1}_spec.v ../../scripts/check.v ../../rtl/$1.v > runme.v
cp ../../refdat/${1}_refdat.txt refdat.txt
iverilog -DMATCH_DC -s check -o runme runme.v
./runme > ${1}_iverilog.txt

mv ${1}_iverilog.txt ../../check_iverilog/

