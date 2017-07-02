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
#
# Usage example:
#	watch -n20 bash scripts/monitor.sh
#

{
	sum=0
	function stat_line()
	{
		for dir; do
			printf "%5s|%5s" "" ""
			if [ "$dir" = "" ]; then
				printf "%-15s%5s" "" ""
				continue
			fi
			if ! test -d $dir && [ "$dir" != "total" -a "$dir" != "failed" ]; then
				printf "%-15s%5s" "$dir" "----"
				continue
			fi
			if [ $dir == "failed" ]; then
				count=$( ls check_vivado check_quartus check_verific check_yosys 2> /dev/null | grep '\.err$' | sort -u | wc -l )
			elif [ $dir == "total" ]; then
				count=$sum
			else
				count=$( ls $dir | grep -v '\.err$' | wc -l )
			fi
			printf "%-15s%5s" $dir $count
			if [ $dir != "rtl" -a $dir != "total" -a $dir != "failed" ]; then
				sum=$((sum+count))
			fi
		done
		printf "%5s|\n" ""
	}
	echo "     +------------------------------+------------------------------+------------------------------+"
	stat_line {syn,check}_vivado   rtl
	stat_line {syn,check}_quartus  failed
	stat_line {syn,check}_verific  report
	stat_line {syn,check}_yosys    total
	echo "     +------------------------------+------------------------------+------------------------------+"

	mkdir -p ~/.vloghammer
	{ tail -n100 monitor.dat 2> /dev/null; date "+%s $sum"; } > monitor.dat_new
	mv monitor.dat_new monitor.dat

	echo
	echo -n "$(uptime),  floating avg. sec/job: "
	gawk 'ARGIND == 1 { mintm = $1; maxtm = $1; mincnt = $2; maxcnt = $2; }
	      ARGIND == 2 && $1 > maxtm-120 && $1 < mintm { mintm = $1; mincnt = $2; }
	      END { printf "%.2f\n", (maxtm - mintm) / (maxcnt - mincnt + 1); }' \
	      monitor.dat monitor.dat

	echo

	statuslen=$((sum % 50))
	if [ $statuslen -gt 25 ]; then
		statusbar="$( printf "%.*slllllllllllllllllllllllll" $((statuslen-25)) "........................." )"
	else
		statusbar="$( printf "%.*s........................." $statuslen "lllllllllllllllllllllllll" )"
	fi
	statusbar="$( echo "$statusbar" | sed -r '
		s/^(.{4})\./\1,/; s/^(.{4})l/\1|/;
		s/^(.{9})\./\1,/; s/^(.{9})l/\1|/;
		s/^(.{14})\./\1,/; s/^(.{14})l/\1|/;
		s/^(.{19})\./\1,/; s/^(.{19})l/\1|/;
		s/^(.{24})\./\1,/; s/^(.{24})l/\1|/;
	' )"
	printf "   %.25s     $(echo $sum | sed 's/./\0 /g;')" "$statusbar" | figlet -w160

	echo
	for pid in $( ps h -o pid,ppid $( pidof make ) | gawk '{ d[$1]=$2; } END { for (p in d) if (!(d[p] in d)) print p; }' ); do
		pstree $pid
	done
} | tee monitor.txt_new

{
	echo '<html>'
	echo '<meta http-equiv="refresh" content="60"/>'
	echo '<script language="JavaScript"><!--'
	echo 'var bgfadecount = 0;'
	echo 'function bgfade() {'
	echo '	if (bgfadecount++ < 30) {'
	echo '		var k = (1+Math.cos(bgfadecount*2*Math.PI/30)) * 0.3 + 0.4;'
	echo '		var s = (255*k+256).toString(16).slice(1, 3);'
	echo '		document.bgColor = "#" + s + s + s;'
	echo '		window.setTimeout(bgfade, 10);'
	echo '	} else'
	echo '		document.bgColor = "#ffffff";'
	echo '}'
	echo 'bgfade();'
	echo '//--></script>'
	echo "<pre>$( perl -pe 's/([<>&])/"&#".ord($1).";"/eg;' < monitor.txt_new )</pre>"
	echo '</html>'
} > monitor.html_new

mv monitor.txt_new monitor.txt
mv monitor.html_new monitor.html

