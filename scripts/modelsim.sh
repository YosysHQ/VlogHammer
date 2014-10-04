#!/bin/bash
#
# simple helper script to run stuff with modelsim
# (useful during troubleshooting)
#
# Usage example:
#
#  1.) add an initial-block with $display statements to rtl/test.v
#  2,) run "bash scripts/modelsim.sh test"
#

MODELSIM_DIR=$( grep ^MODELSIM_DIR Makefile | cut -f2 -d= )
$MODELSIM_DIR/vlib work
$MODELSIM_DIR/vlog rtl/$1.v
$MODELSIM_DIR/vsim -c -do "run -all; exit" work.$1
rm -rf work transcript

