
Q=@
TESTS := $(shell ls rtl/ | gawk '{ sub("\\.v$$", ""); $$2=$$1; sub(".*_", "B", $$1); } /issue/ { $$1="A"; } { print; }' | sort | cut -f2 -d' ' )
CHECKERS := yosys verific iverilog modelsim verilator vivado xsim

help:
	$(Q)echo; echo "Running checks:"
	$(Q)for mode in $(addprefix check_$(1),$(CHECKERS)); do echo "   make $$mode"; done
	$(Q)echo; echo "Creating reports:"; echo "   make report"; echo
	$(Q)echo "Run 'make' as 'make Q=' for verbose output."; echo

report:
	$(Q)echo "Found $$(ls check_*/*.txt | wc -l) reports, $$(grep -L ++OK++ check_*/*.txt | wc -l) tests failed."
	$(Q)grep -L ++OK++ check_*/*.txt | sed 's,^,Failed: ,'

define check_template
check_$(1): check_$(1)_header $$(addprefix check_$(1)/,$$(addsuffix _$(1).txt,$$(TESTS)))

check_$(1)_header:
	$(Q)echo "Running 'check_$(1)'..."

check_$(1)/%_$(1).txt: rtl/%.v spec/%_spec.v refdat/%_refdat.txt
	$(Q)bash scripts/check_$(1).sh $$(basename $$(notdir $$<))
	$(Q)rm -rf temp/check_$(1)_$$(basename $$(notdir $$<))
	$(Q)printf "%-15s %s %s %s\n" "check_$(1)" "$$(basename $$(notdir $$<))" \
	        "`printf "%20s" "$$(basename $$(notdir $$<))" | tr -d a-zA-Z0-9_ | tr ' ' .`" \
		"`grep -q ++OK++ check_$(1)/$$(basename $$(notdir $$<))_$(1).txt && echo pass. || echo FAIL.`"
ifdef EXIT_ON_ERROR
	$(Q)grep -q ++OK++ check_$(1)/$$(basename $$(notdir $$<))_$(1).txt
endif

.PHONY: check_$(1)
endef

$(foreach checker,$(CHECKERS),$(eval $(call check_template,$(checker))))

clean:
	rm -rf temp $(addprefix check_$(1),$(CHECKERS))

.PHONY: help report clean


#############################################################################

ifdef PREPARE
prepare: $(addprefix refdat/,$(addsuffix _refdat.txt,$(TESTS)))
	tar --transform 's,^,vloghammer_tb/,S' --owner=0 --group=0 -cjf vloghammer_tb.tar.bz2 Makefile rtl spec refdat scripts
	$(Q)du -sh vloghammer_tb.tar.bz2

push: prepare
	scp vloghammer_tb.tar.bz2 clifford@clifford.at:htdocs/clifford/yosys/nogit/

spec/%_spec.v: rtl/%.v
	bash scripts/update_spec.sh $(basename $(notdir $<))
	$(Q)rm -rf temp/update_spec_$(basename $(notdir $<))

refdat/%_refdat.txt: rtl/%.v spec/%_spec.v
	bash scripts/update_refdat.sh $(basename $(notdir $<))
	$(Q)rm -rf temp/update_refdat_$(basename $(notdir $<))

purge: clean
	rm -rf rtl spec refdat

.PHONY: prepare purge
.PRECIOUS: spec/%_spec.v refdat/%_refdat.txt
endif

