$(_MODULE_NAME)_SRCS := $(addprefix $(_MODULE_PATH)/,$(srcs)) $(extra_srcs)
$(_MODULE_NAME)_BINARIES := $(addsuffix $(BINARY_EXT),$(addprefix $($(_MODULE_NAME)_OUTPUT)/$(BINARY_PRE),$(win_vers)))
$(_MODULE_NAME)_TARGETS := $(addprefix $(_MODULE_NAME)-,$(win_vers))

$(foreach win_ver,$(win_vers), \
  $(eval $(_MODULE_NAME)_ARTIFACT_$(win_ver) := $($(_MODULE_NAME)_OUTPUT)/$(BINARY_PRE)$(win_ver)$(BINARY_EXT)))

ifneq ($(_NO_RULES),T)
ifneq ($($(_MODULE_NAME)_DEFINED),T)
all: $($(_MODULE_NAME)_TARGETS)

.PHONY: $(_MODULE_NAME) $($(_MODULE_NAME)_TARGETS) $(win_vers)
$(_MODULE_NAME): $($(_MODULE_NAME)_TARGETS)
$(win_vers): %: $(_MODULE_NAME)-%
$($(_MODULE_NAME)_TARGETS): $(_MODULE_NAME)-%: $($(_MODULE_NAME)_OUTPUT)/$(BINARY_PRE)%$(BINARY_EXT)

_CLEAN := clean-$(_MODULE_NAME)
_CLEAN_2 := $(addprefix $(_CLEAN)-,$(win_vers))
.PHONY: clean $(_CLEAN_1) $(_CLEAN_2)
clean: $(_CLEAN)
$(_CLEAN): %: $(addprefix %-,$(win_vers))
$(_CLEAN_2): clean-$(_MODULE_NAME)-%:
	$(info Cleaning $($(_MODULE_NAME)_OUTPUT)/$*$(BINARY_EXT))

$($(_MODULE_NAME)_BINARIES): _path := $(_MODULE_PATH)

.SECONDEXPANSION:
$($(_MODULE_NAME)_OUTPUT)/$(BINARY_PRE)%$(vdiext): $($(_MODULE_NAME)_SRCS) $$($($(_MODULE_NAME)_DEPENDS_ON))
	$(info Making $@)
	@$(VBOXMANAGE) controlvm $* poweroff 2>/dev/null || true
	@$(VBOXMANAGE) unregistervm $* --delete 2>/dev/null || true
	@$(PACKER) build $(PFLAGS) -only \*.$* $(_path)

.SECONDEXPANSION:
$($(_MODULE_NAME)_OUTPUT)/$(BINARY_PRE)%$(snapext): $($(_MODULE_NAME)_SRCS) $$($($(_MODULE_NAME)_DEPENDS_ON))
	$(info Making $@)
	@$(VBOXMANAGE) controlvm $* poweroff 2>/dev/null || true
	@$(PACKER) build $(PFLAGS) -only \*.$* $(_path)
	@touch $@

.SECONDEXPANSION:
$($(_MODULE_NAME)_OUTPUT)/$(BINARY_PRE)%$(boxext): $($(_MODULE_NAME)_SRCS) $$($($(_MODULE_NAME)_DEPENDS_ON))
	$(info Making $@)
	@$(VBOXMANAGE) controlvm $* poweroff 2>/dev/null || true
	@$(PACKER) build $(PFLAGS) -only \*.$* $(_path)

%.cat.pkr.hcl: %.build %.provision
	$(info Making $@)
	cat $^ > $@
	echo } >> $@

$(_MODULE_NAME)_DEFINED := T
endif
endif
