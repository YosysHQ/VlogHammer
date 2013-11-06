#!/bin/bash
#
#  VlogHammer -- A Verilog Synthesis Regression Test
#
#  Copyright (C) 2013  Clifford Wolf <clifford@clifford.at>
#  
#  Permission to use, copy, modify, and/or distribute this software for any
#  purpose with or without fee is hereby granted, provided that the above
#  copyright notice and this permission notice appear in all copies.
#  
#  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
#  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
#  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
#  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
#  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
#  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#

with_abc=false

if [ $# -ne 1 ]; then
	echo "Usage: $0 <job_name>" >&2
	exit 1
fi

job="$1"
set -ex --

rm -rf temp/syn_yosys_$job
mkdir -p temp/syn_yosys_$job
cd temp/syn_yosys_$job

if $with_abc; then
	yosys -q -l synth.log -b 'verilog -noattr' -o synth.v \
	      -p 'hierarchy; proc; opt; techmap; opt; abc; opt' ../../rtl/$job.v
else
	yosys -q -l synth.log -b 'verilog -noattr' -o synth.v \
	      -p 'hierarchy; proc; opt; techmap; opt' ../../rtl/$job.v
fi

mkdir -p ../../syn_yosys
cp synth.v ../../syn_yosys/$job.v

rm -rf ../syn_yosys_$job
echo READY.
