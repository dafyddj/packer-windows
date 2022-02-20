$(_MODULE_NAME)_SRCS := $(addprefix $(_MODULE_PATH)/,$(SRCS)) $(DEPS)
$(_MODULE_NAME)_BINARIES := $(addsuffix $(BINARY_EXT),$(addprefix $($(_MODULE_NAME)_OUTPUT)/$(BINARY_PRE),$(WIN_VERS)))
$(_MODULE_NAME)_TARGETS := $(addprefix $(_MODULE_NAME)-,$(WIN_VERS))

ifneq ($(_NO_RULES),T)
ifneq ($($(_MODULE_NAME)_DEFINED),T)
all: $($(_MODULE_NAME)_TARGETS)

.PHONY: $(_MODULE_NAME) $($(_MODULE_NAME)_TARGETS) $(WIN_VERS)
$(_MODULE_NAME): $($(_MODULE_NAME)_TARGETS)
$(WIN_VERS): %: $(_MODULE_NAME)-%
$($(_MODULE_NAME)_TARGETS): $(_MODULE_NAME)-%: $($(_MODULE_NAME)_OUTPUT)/$(BINARY_PRE)%$(BINARY_EXT)

_CLEAN := clean-$(_MODULE_NAME)
_CLEAN_2 := $(addprefix $(_CLEAN)-,$(WIN_VERS))
.PHONY: clean $(_CLEAN_1) $(_CLEAN_2)
clean: $(_CLEAN)
$(_CLEAN): %: $(addprefix %-,$(WIN_VERS))
$(_CLEAN_2): clean-$(_MODULE_NAME)-%:
	$(info Cleaning $($(_MODULE_NAME)_OUTPUT)/$*$(BINARY_EXT))

$(_MODULE_NAME)-win81: _OS := win81
$(_MODULE_NAME)-win10: _OS := win10
$($(_MODULE_NAME)_BINARIES): _PATH := $(_MODULE_PATH)

$($(_MODULE_NAME)_OUTPUT)/$(BINARY_PRE)%$(_VDIEXT): $($(_MODULE_NAME)_SRCS)
	$(info Making $@)
	@$(VBOXMANAGE) controlvm $(_OS) poweroff 2>/dev/null || true
	@$(VBOXMANAGE) unregistervm $(_OS) --delete 2>/dev/null || true
	@$(PACKER) build $(PFLAGS) -only \*.$(_OS) $(_PATH)

$($(_MODULE_NAME)_OUTPUT)/$(BINARY_PRE)%$(_SNAPEXT): $($(_MODULE_NAME)_SRCS)
	$(info Making $@)
	@$(VBOXMANAGE) controlvm $(_OS) poweroff 2>/dev/null || true
	@$(PACKER) build $(PFLAGS) -only \*.$(_OS) $(_PATH)
	@touch $@

$($(_MODULE_NAME)_OUTPUT)/$(BINARY_PRE)%$(_BOXEXT): $($(_MODULE_NAME)_SRCS)
	$(info Making $@)
	@$(VBOXMANAGE) controlvm $(_OS) poweroff 2>/dev/null || true
	@$(PACKER) build $(PFLAGS) -only \*.$(_OS) $(_PATH)

%.cat.pkr.hcl: %.build %.provision
	$(info Making $@)
	cat $^ > $@
	echo } >> $@

$(_MODULE_NAME)_DEFINED := T
endif
endif
