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
set -e
set -o pipefail

mkdir -p syn_circt

if ! timeout 180 circt-verilog rtl/$job.v -o syn_circt/$job.mlir 2>syn_circt/$job.txt
then
	{
		echo '// [VLOGHAMMER_SYN_ERROR] circt-verilog crashed'
		echo "/*"
		cat syn_circt/$job.txt
		echo "*/"
		sed -e '/^ *assign/ s,^ *,//,;' rtl/$job.v
	} >  syn_circt/$job.v
elif ! timeout 180 circt-opt --lower-seq-to-sv --export-verilog syn_circt/$job.mlir -o /dev/null >syn_circt/$job.v 2>syn_circt/$job.txt
then
	{
		echo '// [VLOGHAMMER_SYN_ERROR] circt-opt crashed'
		echo "/*"
		cat syn_circt/$job.txt
		echo "*/"
		sed -e '/^ *assign/ s,^ *,//,;' rtl/$job.v
	} >  syn_circt/$job.v
fi

rm -f syn_circt/$job.mlir
rm -f syn_circt/$job.txt
