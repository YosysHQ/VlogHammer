#!/bin/bash
#
#  Vlog-Hammer -- A Verilog Synthesis Regression Test
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

test -n "${VIVADO_BIN}"

rm -rf temp/syn_vivado_$job
mkdir -p temp/syn_vivado_$job
cd temp/syn_vivado_$job

sed 's/^module/(* use_dsp48="no" *) module/;' < ../../rtl/$job.v > rtl.v
cat > $job.tcl <<- EOT
	read_verilog rtl.v
	synth_design -part xc7k70t -top $job
	write_verilog -force synth.v
EOT

${VIVADO_BIN} -mode batch -source $job.tcl > output.txt 2>&1 &
vivado_pid=$!

set +x
for ((i = 0; i < 600; i++)); do
	sleep 1
	test -d /proc/$vivado_pid || break
done

test -d /proc/$vivado_pid && kill -9 $vivado_pid
set -x

if ! wait $vivado_pid
then
	{
		echo '// [VLOGHAMMER_SYN_ERROR] Vivado failed or hung in endless loop!'
		tail -n5 output.txt | sed -e 's,^,// ,;'
		sed -e '/^ *assign/ s,^ *,//,;' rtl.v
	} > vivado_failed.v

	mkdir -p ../../syn_vivado
	cp vivado_failed.v ../../syn_vivado/$job.v
else
	mkdir -p ../../syn_vivado
	cp synth.v ../../syn_vivado/$job.v
fi

rm -rf ../syn_vivado_$job
echo READY.
