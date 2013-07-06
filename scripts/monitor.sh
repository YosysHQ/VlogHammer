#!/bin/bash

uptime
echo

sum=0
for dir in rtl {syn,check}_{vivado,quartus,xst,yosys} report; do
	test -d $dir || continue
	count=$( ls $dir | wc -l )
	printf "%-20s%5s\n" $dir $count
	sum=$((sum+count))
done

date "+$sum   [%H:%M:%S]" | figlet -W -w160
statuslen=$((sum % 20 + (sum % 20 - 1) / 5))
[ $statuslen -eq 0 ] && statuslen=160
printf "%.*s" $statuslen "XXXXX,XXXXX,XXXXX,XXXXX" | figlet -fsmall -w160

echo
for pid in $( pidof make ); do
	pstree $pid
done

