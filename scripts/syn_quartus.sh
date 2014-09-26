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

test -n "$QUARTUS_DIR"

rm -rf temp/syn_quartus_$job
mkdir -p temp/syn_quartus_$job
cd temp/syn_quartus_$job

sed 's/^module/(* multstyle = "logic" *) module/;' < ../../rtl/$job.v > $job.v
if ! timeout 120 ${QUARTUS_DIR}/quartus_map $job --source=$job.v --family="Cyclone V"
then
	if test ! -f $job.map.rpt; then
		echo "TIMEOUT" > $job.map.rpt
	fi

	{
		echo '// [VLOGHAMMER_SYN_ERROR] Quartus failed!'
		sed -e '/^Error/ ! d; s,^,// ,;' $job.map.rpt
		sed -e '/^ *assign/ s,^ *,//,;' $job.v
	} > quartus_failed.v

	mkdir -p ../../syn_quartus
	cp quartus_failed.v ../../syn_quartus/$job.v
else
	${QUARTUS_DIR}/quartus_fit $job --part=5CGXFC7D6F27C6
	${QUARTUS_DIR}/quartus_eda $job --simulation --tool=vcs

	sed -ri 's,^// DATE.*,,; s,^tri1 (.*);,wire \1 = 1;,; /^\/\/ +synopsys/ d;' simulation/vcs/$job.vo

	mkdir -p ../../syn_quartus
	cp simulation/vcs/$job.vo ../../syn_quartus/$job.v
fi

rm -rf ../syn_quartus_$job
echo READY.
