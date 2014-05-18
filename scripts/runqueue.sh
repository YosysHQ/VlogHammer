#!/bin/bash
while [ -n "$( ls rtl_queue/ )" ]; do
	mv $( find rtl_queue/ -type f | sort -R | head -n10 ) rtl/
	make world
done
