#!/bin/bash

set -e

mkdir -p check_xsim
rm -f check_xsim/${1}_xsim.txt

rm -rf temp/check_xsim_$1
mkdir -p temp/check_xsim_$1
cd temp/check_xsim_$1

cat ../../spec/${1}_spec.v ../../scripts/check.v ../../rtl/$1.v > runme.v
cp ../../refdat/${1}_refdat.txt refdat.txt

xvlog -d MATCH_DC --nolog runme.v > xvlog.log 2>&1
xelab -R work.check > ${1}_xsim.txt

mv ${1}_xsim.txt ../../check_xsim/

