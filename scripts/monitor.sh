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
#
# Usage example:
#	watch -n20 bash scripts/monitor.sh
#

sum=0
function stat_line()
{
	for dir; do
		printf "%5s|%5s" "" ""
		if [ "$dir" = "" ]; then
			printf "%-15s%5s" "" ""
			continue
		fi
		if ! test -d $dir && [ "$dir" != "total" ]; then
			printf "%-15s%5s" "$dir" "----"
			continue
		fi
		if [ $dir != "total" ]; then
			count=$( ls $dir | grep -v '\.err$' | wc -l )
		else
			count=$sum
		fi
		printf "%-15s%5s" $dir $count
		if [ $dir != "total" ]; then
			sum=$((sum+count))
		fi
	done
	printf "%5s|\n" ""
}
echo "     +------------------------------+------------------------------+------------------------------+"
stat_line {syn,check}_vivado   rtl
stat_line {syn,check}_quartus  report
stat_line {syn,check}_xst      ""
stat_line {syn,check}_yosys    total
echo "     +------------------------------+------------------------------+------------------------------+"

mkdir -p ~/.vloghammer
{ tail -n100 ~/.vloghammer/monitordata.txt 2> /dev/null;
		date "+%s $sum"; } > ~/.vloghammer/monitordata.new
mv ~/.vloghammer/monitordata.new ~/.vloghammer/monitordata.txt

echo
echo -n "$(uptime),  avg. seconds per out file: "
gawk 'ARGIND == 1 { mintm = $1; maxtm = $1; mincnt = $2; maxcnt = $2; }
      ARGIND == 2 && $1 > maxtm-600 && $1 < mintm { mintm = $1; mincnt = $2; }
      END { printf "%.2f\n", (maxtm - mintm) / (maxcnt - mincnt + 1); }' \
      ~/.vloghammer/monitordata.txt ~/.vloghammer/monitordata.txt

echo
date "+ $sum   [%H:%M:%S]" | figlet -W -w160
statuslen=$((sum % 20 + (sum % 20 - 1) / 5))
[ $statuslen -eq 0 ] && statuslen=160
printf "   %.*s" $statuslen "ooooo|ooooo|ooooo|ooooo" | figlet -fsmall -w160

echo
for pid in $( pidof make ); do
	pstree $pid
done

