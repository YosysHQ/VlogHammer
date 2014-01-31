#!/bin/bash
#
#  VlogHammer -- A Verilog Synthesis Regression Test
#
#  Copyright (C) 2013  Clifford Wolf <clifford@clifford.at>
#  Copyright (C) 2013  Johann Glaser <Johann.Glaser@gmx.at>
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

which lec

rm -rf temp/syn_lec_$job
mkdir -p temp/syn_lec_$job
cd temp/syn_lec_$job

cat > $job.do <<- EOT
  read design -golden -verbose -verilog2k "../../rtl/$job.v"
  report rule check -verbose
  flatten -golden
  write design -golden -used "synth.v"
  set exit code -verbose
  exit -force
EOT

set +e
# LEC returns exit code 2 because of "No equivalent points during comparison"
# which is because we didn't do any comparison. So we check for exit code = 2.
timeout 180 lec -lpgxl -64 -nogui $job.do > >( tee output.txt ) 2>&1
ExitCode=$?
set -e
if [ $ExitCode -ne 2 ] ; then
	{
		echo '// [VLOGHAMMER_SYN_ERROR] lec failed, crashed or hung in endless loop!'
		tail -n25 output.txt | sed -e 's,^,// ,;'
		sed -e '/^ *assign/ s,^ *,//,;' ../../rtl/$job.v
	} > lec_failed.v

	mkdir -p ../../syn_lec
	cp lec_failed.v ../../syn_lec/$job.v
else
	mkdir -p ../../syn_lec
	cp synth.v ../../syn_lec/$job.v
fi

rm -rf ../syn_lec_$job
echo READY.
