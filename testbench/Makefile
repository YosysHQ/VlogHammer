
TESTS := $(shell ls rtl/ | sed 's,\.v$$,,' )
CHECKERS := yosys iverilog modelsim

help:
	@echo; echo "Running checks:"
	@for mode in $(addprefix check_$(1),$(CHECKERS)); do echo "   make $$mode"; done
	@echo; echo "Creating reports:"; echo "   make report"; echo

report:
	@grep -L ++OK++ check_*/*.txt | sed 's,^,Failed: ,'

ENABLE_PREPARE := 0
ifeq ($(ENABLE_PREPARE),1)
prepare: $(addprefix refdat/,$(addsuffix _refdat.txt,$(TESTS)))

spec/%_spec.v: rtl/%.v
	bash scripts/update_spec.sh $(basename $(notdir $<))

refdat/%_refdat.txt: rtl/%.v spec/%_spec.v
	bash scripts/update_refdat.sh $(basename $(notdir $<))
endif

define check_template
check_$(1): $$(addprefix check_$(1)/,$$(addsuffix _$(1).txt,$$(TESTS)))

check_$(1)/%_$(1).txt: rtl/%.v spec/%_spec.v refdat/%_refdat.txt
	@bash scripts/check_$(1).sh $$(basename $$(notdir $$<))
	@printf "%-15s %s %s %s\n" "check_$(1)" "$$(basename $$(notdir $$<))" \
	        "`printf "%20s" "$$(basename $$(notdir $$<))" | tr -d a-zA-Z0-9_ | tr ' ' .`" \
		"`grep -q ++OK++ check_$(1)/$$(basename $$(notdir $$<))_$(1).txt && echo pass. || echo FAIL.`"

.PHONY: check_$(1)
endef

$(foreach checker,$(CHECKERS),$(eval $(call check_template,$(checker))))

clean:
	rm -rf temp $(addprefix check_$(1),$(CHECKERS))

.PHONY: help report prepare clean
.PRECIOUS: spec/%_spec.v refdat/%_refdat.txt

