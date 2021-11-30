# Pass specific variables from the environment
cli_vars = skip_export cm_version
define build_cli
ifdef $(1)
        PACKER_VARS += -var '$(1)=$(2)'
endif
endef
$(foreach cli_var,$(cli_vars),$(eval $(call build_cli,$(cli_var),$(value $(cli_var)))))

poweroff := @-VBoxManage controlvm win81x64-pro poweroff 2>/dev/null || true
unregister := @-VBoxManage unregistervm win81x64-pro --delete 2>/dev/null || true

stage_files := $(wildcard *.pkr.hcl)
stages := $(stage_files:.pkr.hcl=)

provision_depends_on := .snapshots/install
install_depends_on := output-boot/win81x64-pro.vdi

output-export/win81x64-pro-disk001.vmdk: export.pkr.hcl .snapshots/provision
	$(poweroff)
	packer build -timestamp-ui -force $(PACKER_VARS) -var-file win81x64-pro.pkrvars.hcl $<

.SECONDEXPANSION:
$(foreach stage,$(filter-out boot export,$(stages)),.snapshots/$(stage)): .snapshots/% : %.pkr.hcl $$($$*_depends_on) | setup
	$(poweroff)
	packer build -timestamp-ui -var-file win81x64-pro.pkrvars.hcl $<
	touch $@

output-boot/win81x64-pro.vdi: boot.pkr.hcl floppy/*
	$(poweroff)
	$(unregister)
	packer build -timestamp-ui -force -var-file win81x64-pro.pkrvars.hcl $<

setup: .snapshots

.snapshots:
	mkdir -p $@

