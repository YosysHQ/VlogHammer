#!/bin/bash

echo "Building..."
if ! (
	set -ex
	autoconf
	./configure --prefix=$PWD/instdir
	make clean
	! make CXXFLAGS="-O0 -fpermissive" -j4
	! make CXXFLAGS="-O0 -fpermissive" -j4
	make CXXFLAGS="-O0 -fpermissive" install
) > build.log 2>&1; then
	tail build.log
	exit 125
fi

echo "Testing..."
./instdir/bin/iverilog -o issue_011 issue_011.v || exit 125
./issue_011 || exit 1

echo OK.
exit 0
