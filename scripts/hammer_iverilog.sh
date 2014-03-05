#!/bin/bash

process_job()
{
	job=$1
	rm -f testbench.v testbench.ys rtl.v iverilog_testbench
	rm -f results_iverilog.txt results_yosys.txt output_iverilog.txt output_yosys.txt
	cp ../../rtl/$job.v rtl.v

	input_bits=$( grep '^ *input' rtl.v | tr '[:];' ' ' | sed 's, signed , ,;' | awk '{bits += $2+1;} END {print bits;}' )
	output_bits=$( grep '^ *output' rtl.v | tr '[:];' ' ' | sed 's, signed , ,;' | awk '{bits += $2+1;} END {print bits;}' )
	input_list=$( grep '^ *input' rtl.v | tr '[:];' ' ' | sed 's, signed , ,;' | awk '{print $4;}' | tr '\n' ' ' | sed 's, *$,,' )

	echo "Testing $job ($input_bits input bits, $output_bits output bits) .."
	echo "hierarchy; proc;; cd $job" > testbench.ys

	{
		echo "module testbench;"
		grep '^ *input' rtl.v | sed 's,input,reg,'
		grep '^ *output' rtl.v | sed 's,output,wire,'
		echo "$job uut ("
		for input in $input_list; do
			echo "  .$input($input),"
		done
		echo "  .y(y)"
		echo ");"
		echo "initial begin"
	} > testbench.v

	for ((i = 0; i < 100; i++)); do
		pattern="'h$( echo $job_$i | sha256sum | awk '{ print $1; }')"
		[ $i == 0 ] && pattern="0"
		[ $i == 1 ] && pattern="~0"
		echo "  #10; {$( echo $input_list | tr ' ' , )} <= $pattern;" >> testbench.v
		echo "  #10; \$display(\"Eval result: \\\\y = $output_bits'%b.\", y);" >> testbench.v
		[ $i -gt 1 ] && pattern="$input_bits$pattern"
		echo "eval -show y -set $( echo $input_list | tr ' ' , ) $pattern" >> testbench.ys
	done

	echo "end" >> testbench.v
	echo "endmodule" >> testbench.v

	( ulimit -v 1048576; timeout 120 iverilog -o iverilog_testbench rtl.v testbench.v; )
	( ulimit -v 1048576; timeout 120 ./iverilog_testbench > output_iverilog.txt; )
	yosys -ql output_yosys.txt rtl.v testbench.ys

	grep '^Eval result:' output_iverilog.txt > results_iverilog.txt
	grep '^Eval result:' output_yosys.txt > results_yosys.txt

	if ! diff -u results_iverilog.txt results_yosys.txt; then
		if [ "$job" != "test" ]; then echo "$job ERROR" >> ../../hammer_iverilog.txt; fi
		rm -rf ${job}_files; mkdir -p ${job}_files
		mv rtl.v testbench.* output_* results_* ${job}_files
	else
		if [ "$job" != "test" ]; then echo "$job OK" >> ../../hammer_iverilog.txt; fi
	fi
}

if [ $# = 0 ]; then
	touch hammer_iverilog.txt
	mkdir -p temp/hammer_iverilog
	cd temp/hammer_iverilog

	while read job; do
		if grep -q "^$job " ../../hammer_iverilog.txt; then
			echo "Skipping $job."
		else
			process_job $job
		fi
	done < <( cd ../../rtl; ls *.v | sed 's,\.v$,,' | sort -R )
else
	mkdir -p temp/hammer_iverilog
	cd temp/hammer_iverilog

	for job; do
		if grep -q "^$job " ../../hammer_iverilog.txt; then
			echo "Skipping $job."
		else
			process_job $job
		fi
	done
fi

exit 0
