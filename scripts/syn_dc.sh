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

which dc_shell-t

rm -rf temp/syn_dc_$job
mkdir -p temp/syn_dc_$job
cd temp/syn_dc_$job

ln -s ../../scripts/cells_cmos.lib cells_cmos.lib

# Design Compiler (2009.06) doesn't support "===" and "!==" operators, but
# in the testcases these don't differ from "==" and "!=", so just replace them.
sed -r 's/===/==/g;s/!==/!=/g' "../../rtl/$job.v" > $job.v

cat > $job.tcl <<- EOT
  if { [read_lib cells_cmos.lib               ] != 1 } then { exit 1 }
  set target_library "cells_cmos.db"
  set synthetic_library "dw_foundation.sldb"
  set link_library "* \$target_library \$synthetic_library"
  if { [analyze -format verilog $job.v        ] != 1 } then { exit 1 }
  if { [elaborate $job                        ] != 1 } then { exit 1 }
  if { [link                                  ] != 1 } then { exit 1 }
  if { [uniquify                              ] != 1 } then { exit 1 }
  check_design
  if { [compile                               ] != 1 } then { exit 1 }
  if { [write -format verilog -output synth.v ] != 1 } then { exit 1 }
  exit 0
EOT

if ! timeout 180 dc_shell-t -no_gui -f $job.tcl > >( tee output.txt ) 2>&1
then
	{
		echo '// [VLOGHAMMER_SYN_ERROR] dc failed, crashed or hung in endless loop!'
		tail -n25 output.txt | sed -e 's,^,// ,;'
		sed -e '/^ *assign/ s,^ *,//,;' ../../rtl/$job.v
	} > dc_failed.v

	mkdir -p ../../syn_dc
	cp dc_failed.v ../../syn_dc/$job.v
else
	mkdir -p ../../syn_dc
	cp synth.v ../../syn_dc/$job.v
fi

rm -rf ../syn_dc_$job
echo READY.
