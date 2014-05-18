#!/bin/bash

set -e

mkdir -p refdat
rm -f refdat/${1}_refdat.txt

rm -rf temp/update_refdat_$1
mkdir -p temp/update_refdat_$1
cd temp/update_refdat_$1

cat ../../spec/${1}_spec.v ../../scripts/update_refdat.v ../../rtl/$1.v > runme.v
iverilog -s update_refdat -o runme runme.v
./runme

cp refdat.txt ${1}_refdat.txt
mv ${1}_refdat.txt ../../refdat/

