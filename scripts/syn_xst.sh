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

if [ $# -ne 1 ]; then
	echo "Usage: $0 <job_name>" >&2
	exit 1
fi

job="$1"
set -ex --

test -n "$ISE_SETTINGS"

set +x
. ${ISE_SETTINGS}
set -x

rm -rf temp/syn_xst_$job
mkdir -p temp/syn_xst_$job
cd temp/syn_xst_$job

cat > $job.xst <<- EOT
	run
	-ifn $job.prj -ofn $job -p artix7 -top $job
	-iobuf NO -ram_extract NO -rom_extract NO -use_dsp48 NO
	-fsm_extract YES -fsm_encoding Auto
	-change_error_to_warning "HDLCompiler:226 HDLCompiler:1832"
EOT

cat > $job.prj <<- EOT
	verilog work "../../rtl/$job.v"
EOT

if ! timeout 180 xst -ifn $job.xst > >( tee output.txt ) 2>&1
then
	{
		echo '// [VLOGHAMMER_SYN_ERROR] XST failed, crashed or hung in endless loop!'
		tail -n5 output.txt | sed -e 's,^,// ,;'
		sed -e '/^ *assign/ s,^ *,//,;' ../../rtl/$job.v
	} > xst_failed.v

	mkdir -p ../../syn_xst
	cp xst_failed.v ../../syn_xst/$job.v
else
	netgen -w -ofmt verilog $job.ngc $job
	sed -i '/^`ifndef/,/^`endif/ d; s/ *Timestamp: .*//;' $job.v

	mkdir -p ../../syn_xst
	cp $job.v ../../syn_xst/$job.v
fi

rm -rf ../syn_xst_$job
echo READY.
