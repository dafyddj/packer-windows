# Pass specific variables from the environment
cli_vars = cm_version disable_breakpoint prefix search_criteria skip_export update_limit
define build_cli
ifdef $(1)
        PACKER_VARS += -var '$(1)=$(2)'
endif
endef
$(foreach cli_var,$(cli_vars),$(eval $(call build_cli,$(cli_var),$(value $(cli_var)))))

auto_version := $(shell bin/version)
VERSION ?= $(auto_version)

poweroff   := @-VBoxManage controlvm win81x64-pro poweroff 2>/dev/null || true
unregister := @-VBoxManage unregistervm win81x64-pro --delete 2>/dev/null || true

stage_files := $(wildcard *.pkr.hcl)
stages := $(stage_files:.pkr.hcl=)
snapshots := $(foreach stage,$(filter-out boot export,$(stages)),$(stage))

install_depends_on   := output-boot/win81x64-pro.vdi
guestadd_depends_on  := .snapshots/install
update_depends_on   := .snapshots/guestadd
provision_depends_on := .snapshots/update

box/virtualbox-vm/win81x64-pro-salt.box: export.pkr.hcl .snapshots/provision
	$(poweroff)
	packer build -timestamp-ui -force $(PACKER_VARS) -var-file win81x64-pro.pkrvars.hcl $<

.SECONDEXPANSION:
$(foreach snapshot,$(snapshots),.snapshots/$(snapshot)): .snapshots/% : %.pkr.hcl $$($$*_depends_on) | setup
	$(poweroff)
	packer build -timestamp-ui -force $(PACKER_VARS) -var-file win81x64-pro.pkrvars.hcl $<
	touch $@

output-boot/win81x64-pro.vdi: boot.pkr.hcl floppy/*
	$(poweroff)
	$(unregister)
	packer build -timestamp-ui -force -var-file win81x64-pro.pkrvars.hcl $<

.upload: upload.pkr.hcl box/virtualbox-vm/win81x64-pro-salt.box
	packer build -timestamp-ui $(PACKER_VARS) -var version=$(VERSION) $<
	touch $@

setup: .snapshots

.snapshots:
	mkdir -p $@

.PHONY: list
list:
	@echo "Targets:"
	@for stage in $(stages) ; do \
                echo $$stage; \
        done
