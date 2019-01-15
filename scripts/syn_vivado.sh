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

test -n "${VIVADO_DIR}"

rm -rf temp/syn_vivado_$job
mkdir -p temp/syn_vivado_$job
cd temp/syn_vivado_$job

sed 's/^module/(* use_dsp48="no" *) module/;' < ../../rtl/$job.v > rtl.v
cat > $job.tcl <<- EOT
	# CRITICAL WARNING: [Synth 8-5821] Potential divide by zero
	set_msg_config -id {Synth 8-5821} -new_severity {WARNING}

	read_verilog rtl.v
	synth_design -part xc7k70t -top $job
	write_verilog -force synth.v
EOT

if ! timeout 180 ${VIVADO_DIR}/vivado -mode batch -source $job.tcl > >( tee output.txt ) 2>&1
then
	{
		echo '// [VLOGHAMMER_SYN_ERROR] Vivado failed, crashed or hung in endless loop!'
		tail -n5 output.txt | sed -e 's,^,// ,;'
		sed -e '/^ *assign/ s,^ *,//,;' ../../rtl/$job.v
	} > vivado_failed.v

	mkdir -p ../../syn_vivado
	cp vivado_failed.v ../../syn_vivado/$job.v
elif egrep 'assign +\\<const0> += +[a-z]' synth.v
then
	{
		echo '// [VLOGHAMMER_SYN_ERROR] Vivado created one of this 'assign to const0' netlists (see issue_010)!'
		sed -e '/^ *assign/ s,^ *,//,;' ../../rtl/$job.v
	} > vivado_failed.v

	mkdir -p ../../syn_vivado
	cp vivado_failed.v ../../syn_vivado/$job.v
else
	mkdir -p ../../syn_vivado
	cp synth.v ../../syn_vivado/$job.v
fi

rm -rf ../syn_vivado_$job
echo READY.
