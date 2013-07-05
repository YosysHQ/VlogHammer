#!/bin/bash

date
uptime

echo
for pid in $( pidof make ); do
	pstree -p $pid
done

echo
for dir in rtl {syn,check}_{vivado,quartus,xst,yosys} report; do
	test -d $dir || continue
	printf "%-20s%5s\n" $dir $( ls $dir | wc -l )
done

