ifeq ($(origin prefix), command line)
	PACKER_VARS += -var 'prefix=$(prefix)'
endif

# Pass specific variables from the environment
cli_vars = cm_version disable_breakpoint search_criteria skip_export update_limit
define build_cli
ifdef $(1)
        PACKER_VARS += -var '$(1)=$(2)'
endif
endef
$(foreach cli_var,$(cli_vars),$(eval $(call build_cli,$(cli_var),$(value $(cli_var)))))

auto_version := $(shell bin/version)
VERSION ?= $(auto_version)

stage_files := $(wildcard *.pkr.hcl)
stages := $(stage_files:.pkr.hcl=)
snapshots := $(foreach stage,$(filter-out boot export upload,$(stages)),$(stage))

win_vers := win81 win10

define build_win_vers
$(1)_poweroff   := @-VBoxManage controlvm $(1)x64-pro poweroff 2>/dev/null || true
$(1)_unregister := @-VBoxManage unregistervm $(1)x64-pro --delete 2>/dev/null || true

$(1)_install_depends_on   := output-boot/$(1)/$(1)x64-pro.vdi
$(1)_guestadd_depends_on  := install/$(1)
$(1)_update_depends_on    := guestadd/$(1)
$(1)_provision_depends_on := update/$(1)

export/$(1): box/virtualbox-vm/$(1)x64-pro-salt.box
box/virtualbox-vm/$(1)x64-pro-salt.box: export.pkr.hcl provision/$(1)
	$(poweroff)
	packer build -timestamp-ui -force -only \*.$(1) $(PACKER_VARS) $$<

.SECONDEXPANSION:
$(foreach snapshot,$(snapshots),$(snapshot)/$(1)): %/$(1) : %.pkr.hcl $$$$($(1)_$$$$*_depends_on) | setup
	$(poweroff)
	packer build -timestamp-ui -force -only \*.$(1) $(PACKER_VARS) $$<
	touch $$@

output-boot/$(1)/$(1)x64-pro.vdi: boot.pkr.hcl floppy/*
	$$($(1)_poweroff)
	$$($(1)_unregister)
	packer build -timestamp-ui -force -only \*.$(1) $(PACKER_VARS) $$<

upload/$(1): upload.pkr.hcl box/virtualbox-vm/$(1)x64-pro-salt.box | setup
	packer build -timestamp-ui -only \*.$(1) $(PACKER_VARS) -var version=$(VERSION) $$<
	touch $$@
endef

$(foreach win_ver,$(win_vers),$(eval $(call build_win_vers,$(win_ver))))

setup: | $(snapshots) upload

$(snapshots) upload:
	mkdir -p $@

.PHONY: list
list:
	@echo "Targets:"
	@for stage in $(stages) ; do \
                echo $$stage; \
        done
