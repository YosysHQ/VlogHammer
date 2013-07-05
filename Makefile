
help:
	@echo ""
	@echo "  make clean  ..............................  remove temp files"
	@echo "  make purge  ..............................  remove results"
	@echo ""
	@echo "  make generate  ...........................  generate rtl files"
	@echo ""
	@echo "  make syn  ................................  run all synthesis"
	@echo "  make syn_vivado  .........................  run only vivado"
	@echo "  make syn_quartus  ........................  run only quartus"
	@echo "  make syn_xst  ............................  run only xst"
	@echo "  make syn_yosys  ..........................  run only yosys"
	@echo ""
	@echo "  make check  ..............................  check all"
	@echo "  make check_vivado  .......................  check only vivado"
	@echo "  make check_quartus  ......................  check only quartus"
	@echo "  make check_xst  ..........................  check only xst"
	@echo "  make check_yosys  ........................  check only yosys"
	@echo ""
	@echo "  make report ..............................  generate reports"
	@echo ""
	@echo ""
	@echo "Example usage:"
	@echo "  make purge generate ONLY_SAMPLES=1"
	@echo "  make -j4 -l6 syn"
	@echo "  make -j4 -l6 check"
	@echo "  make -j4 -l6 report"
	@echo ""

# -------------------------------------------------------------------------------------------

clean:
	rm -rf temp ./scripts/generate

purge: clean
	rm -rf rtl report
	rm -rf syn_vivado syn_quartus syn_xst syn_yosys
	rm -rf check_vivado check_quartus check_xst check_yosys
	rm -rf cache_vivado cache_quartus cache_xst cache_yosys

# -------------------------------------------------------------------------------------------

generate:
ifdef ONLY_SAMPLES
	clang -DONLY_SAMPLES -Wall -Wextra -O2 -o scripts/generate scripts/generate.cc -lstdc++
else
	clang -Wall -Wextra -O2 -o scripts/generate scripts/generate.cc -lstdc++
endif
	./scripts/generate

# -------------------------------------------------------------------------------------------

syn: syn_vivado syn_quartus syn_xst syn_yosys

syn_vivado: $(shell ls rtl | sort -u | cut -f1 -d. | gawk '{ print "syn_vivado/" $$0 ".v"; }')

syn_vivado/%.v:
	bash scripts/syn_vivado.sh $(notdir $(basename $@))

syn_quartus: $(shell ls rtl | sort -u | cut -f1 -d. | gawk '{ print "syn_quartus/" $$0 ".v"; }')

syn_quartus/%.v:
	bash scripts/syn_quartus.sh $(notdir $(basename $@))

syn_xst: $(shell ls rtl | sort -u | cut -f1 -d. | gawk '{ print "syn_xst/" $$0 ".v"; }')

syn_xst/%.v:
	bash scripts/syn_xst.sh $(notdir $(basename $@))

syn_yosys: $(shell ls rtl | sort -u | cut -f1 -d. | gawk '{ print "syn_yosys/" $$0 ".v"; }')

syn_yosys/%.v:
	bash scripts/syn_yosys.sh $(notdir $(basename $@))

# -------------------------------------------------------------------------------------------

check: check_vivado check_quartus check_xst check_yosys

check_vivado: $(shell ls rtl | sort -u | cut -f1 -d. | gawk '{ print "check_vivado/" $$0 ".txt"; }')

check_vivado/%.txt:
	bash scripts/check.sh vivado $(notdir $(basename $@))

check_quartus: $(shell ls rtl | sort -u | cut -f1 -d. | gawk '{ print "check_quartus/" $$0 ".txt"; }')

check_quartus/%.txt:
	bash scripts/check.sh quartus $(notdir $(basename $@))

check_xst: $(shell ls rtl | sort -u | cut -f1 -d. | gawk '{ print "check_xst/" $$0 ".txt"; }')

check_xst/%.txt:
	bash scripts/check.sh xst $(notdir $(basename $@))

check_yosys: $(shell ls rtl | sort -u | cut -f1 -d. | gawk '{ print "check_yosys/" $$0 ".txt"; }')

check_yosys/%.txt:
	bash scripts/check.sh yosys $(notdir $(basename $@))

# -------------------------------------------------------------------------------------------

report: $(shell ls check_vivado check_quartus check_xst check_yosys | grep '\.err$$' | sort -u | cut -f1 -d. | gawk '{ print "report/" $$0 ".html"; }')

report/%.html:
	bash scripts/report.sh $(notdir $(basename $@))

# -------------------------------------------------------------------------------------------

.PHONY: help clean purge generate
.PHONY: syn syn_vivado syn_quartus syn_xst syn_yosys
.PHONY: check check_vivado check_quartus check_xst check_yosys

