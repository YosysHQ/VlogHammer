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

# Synthesis with verific is performed via the 'verifitest' example program.
# The sourcecode for this program can be downloaded from:
#
#     http://svn.clifford.at/handicraft/2014/verifitest
#
# Visit http://verific.com/ for more information on the verific library.

if [ $# -ne 1 ]; then
	echo "Usage: $0 <job_name>" >&2
	exit 1
fi

job="$1"
set -ex --

rm -rf temp/syn_verific_$job
mkdir -p temp/syn_verific_$job
cd temp/syn_verific_$job

cp ../../rtl/$job.v rtl.v
if ! timeout 180 verifitest -o synth.v rtl.v; then
	{
		echo '// [VLOGHAMMER_SYN_ERROR] Verific failed, crashed or hung in endless loop!'
		tail -n5 output.txt | sed -e 's,^,// ,;'
		sed -e '/^ *assign/ s,^ *,//,;' ../../rtl/$job.v
	} > verific_failed.v

	mkdir -p ../../syn_verific
	cp verific_failed.v ../../syn_verific/$job.v
else
	mkdir -p ../../syn_verific
	cp synth.v ../../syn_verific/$job.v
fi

rm -rf ../syn_verific_$job
echo READY.
