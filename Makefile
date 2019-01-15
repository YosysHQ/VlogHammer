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

# All supported SYN_LIST tags: vivado quartus xst yosys verific dc lec
# All supported SIM_LIST tags: xsim isim modelsim icarus verilator yosim

SYN_LIST     := vivado yosys
SIM_LIST     := xsim modelsim icarus verilator yosim
RTL_LIST     := $(shell ls rtl 2> /dev/null | cut -f1 -d.)
REPORT_LIST  := $(shell ls $(addprefix check_,$(SYN_LIST)) 2> /dev/null | grep '\.err$$' | cut -f1 -d. | sort -u)
ISE_SETTINGS := /opt/Xilinx/14.7/ISE_DS/settings64.sh
IVERILOG_DIR := # /home/clifford/Work/iverilog/instdir/bin
MODELSIM_DIR := /opt/intelFPGA_lite/17.0/modelsim_ase/linux
QUARTUS_DIR  := /opt/intelFPGA_lite/17.0/quartus/bin
VIVADO_DIR   := /opt/Xilinx/Vivado/2018.3/bin
VERILATOR    := /usr/local/bin/verilator
MAKE_JOBS    := -j4 -l8
YOSYS_MODE   := default
REPORT_FULL  :=
REPORT_OPTS  :=

ifdef REPORT_FULL
REPORT_LIST := $(RTL_LIST)
REPORT_FILTER := 1
endif

export SYN_LIST SIM_LIST ISE_SETTINGS IVERILOG_DIR MODELSIM_DIR QUARTUS_DIR VIVADO_DIR VERILATOR YOSYS_MODE

help:
	@echo ""
	@echo "  make clean  ..............................  remove temp files"
	@echo "  make mrproper  ...........................  remove output files"
	@echo "  make purge  ..............................  remove output files and rtl"
	@echo ""
	@echo "  make gen_issues  .........................  generate rtl files for known issues"
	@echo "  make gen_samples  ........................  generate small set of autogen rtl files"
	@echo "  make gen_full  ...........................  generate full set of autogen rtl files"
	@echo "  make generate  ...........................  generate all rtl files"
	@echo ""
	@echo "  make syn  ................................  run all synthesis"
	@for x in $(SYN_LIST); do printf '  make syn_%s  %.*s  run only %s\n' $$x $$(expr 32 - $$( echo $$x | wc -c ) ) "................................." $$x; done
	@echo ""
	@echo "  make check  ..............................  check all"
	@for x in $(SYN_LIST); do printf '  make check_%s  %.*s  check only %s\n' $$x $$(expr 30 - $$( echo $$x | wc -c ) ) "..............................." $$x; done
	@echo ""
	@echo "  make report ..............................  generate reports"
	@echo ""
	@echo "  Run 'make world' as an alias for:"
	@echo "    make $(MAKE_JOBS) syn"
	@echo "    make $(MAKE_JOBS) check"
	@echo "    make $(MAKE_JOBS) report"
	@echo ""
	@echo ""
	@echo "Example usage:"
	@echo "  make purge"
	@echo "  make generate"
	@echo "  make world"
	@echo ""

sh:
	FORCE_PS1='<\[\e[1;31m\]VlogHammer\[\e[0m\]> \w\$$ ' bash

update-web:
	python scripts/foundbugs.py foundbugs ../yosys-web/vloghammer_bugs
	cd ../yosys-web && make vloghammer.html

world:
	$(MAKE) $(MAKE_JOBS) syn
	$(MAKE) $(MAKE_JOBS) check
	$(MAKE) $(MAKE_JOBS) report

# -------------------------------------------------------------------------------------------

backup:
	mkdir -p ~/.vloghammer
	tar czf ~/.vloghammer/backup_rtl.tar.gz rtl
	tar czf ~/.vloghammer/backup_syn.tar.gz $(addprefix syn_,$(SYN_LIST))
	tar czf ~/.vloghammer/backup_check.tar.gz $(addprefix check_,$(SYN_LIST))
	tar czf ~/.vloghammer/backup_cache.tar.gz $(addprefix cache_,$(SYN_LIST))
	tar czf ~/.vloghammer/backup_report.tar.gz report

clean:
	rm -f monitor.html monitor.txt monitor.dat
	rm -rf temp ./scripts/generate

mrproper: clean
	rm -rf report report.html
	rm -rf $(addprefix syn_,$(SYN_LIST))
	rm -rf $(addprefix check_,$(SYN_LIST))
	rm -rf $(addprefix cache_,$(SYN_LIST))

purge: mrproper
	rm -rf rtl

# -------------------------------------------------------------------------------------------

gen_issues:
	mkdir -p rtl
	perl -e 'while (<>) { open(F, ">rtl/$$1.v") if /module ([a-z0-9_]*)/; print F $$_; }' < scripts/issues.v

gen_samples:
	clang -DONLY_SAMPLES -Wall -Wextra -ggdb -O0 -o scripts/generate scripts/generate.cc -lstdc++
	./scripts/generate

gen_full:
	clang -Wall -Wextra -ggdb -O0 -o scripts/generate scripts/generate.cc -lstdc++
	./scripts/generate

generate: gen_issues gen_full

# -------------------------------------------------------------------------------------------

syn: $(addprefix syn_,$(SYN_LIST))

define syn_template
syn_$(1): $$(addprefix syn_$(1)/,$$(addsuffix .v,$$(RTL_LIST)))

ifndef DEPS
syn_$(1)/%.v:
else
syn_$(1)/%.v: rtl/%.v
endif
	bash scripts/syn_$(1).sh $$(notdir $$(basename $$@))
endef

$(foreach syn,$(SYN_LIST),$(eval $(call syn_template,$(syn))))

# -------------------------------------------------------------------------------------------

check: $(addprefix check_,$(SYN_LIST))

define check_template
check_$(1): $$(addprefix check_$(1)/,$$(addsuffix .txt,$$(RTL_LIST)))

ifndef DEPS
check_$(1)/%.txt:
else
check_$(1)/%.txt: syn_$(1)/%.v
endif
	bash scripts/check.sh $(1) $$(notdir $$(basename $$@))
endef

$(foreach syn,$(SYN_LIST),$(eval $(call check_template,$(syn))))

# -------------------------------------------------------------------------------------------

report: $(addprefix report/,$(addsuffix .html,$(REPORT_LIST)))
ifdef REPORT_FILTER
	-perl scripts/bigreport.pl `grep -Lr 'LISTS:.* noerror ' report/` > report.html
else
	-perl scripts/bigreport.pl report/* > report.html
endif

ifndef DEPS
report/%.html:
else
report/%.html: $(addprefix check_,$(addsuffix /%.txt,$(SYN_LIST)))
endif
	bash scripts/report.sh $(REPORT_OPTS) $(notdir $(basename $@))

# -------------------------------------------------------------------------------------------

.PHONY: help sh world backup clean purge generate report
.PHONY: syn $(addprefix syn_,$(SYN_LIST))
.PHONY: check $(addprefix check_,$(SYN_LIST))

.PRECIOUS: rtl/%.v report/%.html
.PRECIOUS: $(addprefix syn_,$(addsuffix /%.v,$(SYN_LIST)))
.PRECIOUS: $(addprefix check_,$(addsuffix /%.txt,$(SYN_LIST)))

