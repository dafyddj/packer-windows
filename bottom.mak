$(_MODULE_NAME)_SRCS := $(addprefix $(_MODULE_PATH)/,$(SRCS)) $(DEPS)
$(_MODULE_NAME)_BINARIES := $(addsuffix $(BINARY_EXT),$(addprefix $($(_MODULE_NAME)_OUTPUT)/$(BINARY_PRE),$(WIN_VERS)))

ifneq ($(_NO_RULES),T)
ifneq ($($(_MODULE_NAME)_DEFINED),T)
all: $($(_MODULE_NAME)_BINARIES)

$(_MODULE_NAME)_2 := $(addprefix $(_MODULE_NAME)-,$(WIN_VERS))
.PHONY: $(_MODULE_NAME) $($(_MODULE_NAME)_2) $(WIN_VERS)
$(_MODULE_NAME): $($(_MODULE_NAME)_2)
$(WIN_VERS): %: $(_MODULE_NAME)-%
$($(_MODULE_NAME)_2): $(_MODULE_NAME)-%: $($(_MODULE_NAME)_OUTPUT)/$(BINARY_PRE)%$(BINARY_EXT)

_CLEAN := clean-$(_MODULE_NAME)
_CLEAN_2 := $(addprefix $(_CLEAN)-,$(WIN_VERS))
.PHONY: clean $(_CLEAN_1) $(_CLEAN_2)
clean: $(_CLEAN)
$(_CLEAN): %: $(addprefix %-,$(WIN_VERS))
$(_CLEAN_2): clean-$(_MODULE_NAME)-%:
	$(info Cleaning $($(_MODULE_NAME)_OUTPUT)/$*$(BINARY_EXT))

$($(_MODULE_NAME)_BINARIES): _PATH := $(_MODULE_PATH)
$(BINARY_PRE)%$(_VDIEXT): $($(_MODULE_NAME)_SRCS)
	$(info Making $@)
	@$(VBOXMANAGE) controlvm $(*F) poweroff 2>/dev/null || true
	@$(VBOXMANAGE) unregistervm $(*F) --delete 2>/dev/null || true
	@$(PACKER) build $(PFLAGS) -only \*.$(*F) $(_PATH)

$(BINARY_PRE)%$(_SNAPEXT): $($(_MODULE_NAME)_SRCS)
	$(info Making $@)
	@-$(VBOXMANAGE) controlvm $(*F) poweroff 2>/dev/null
	@$(PACKER) build $(PFLAGS) -only \*.$(*F) $(_PATH)
	@touch $@

$(BINARY_PRE)%$(_BOXEXT): $($(_MODULE_NAME)_SRCS)
	$(info Making $@)
	@-$(VBOXMANAGE) controlvm $(*F) poweroff 2>/dev/null
	@$(PACKER) build $(PFLAGS) -only \*.$(*F) $(_PATH)

%.cat.pkr.hcl: %.build %.provision
	$(info Making $@)
	cat $^ > $@
	echo } >> $@

$(_MODULE_NAME)_DEFINED := T
endif
endif
