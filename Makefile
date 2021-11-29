# Pass specific variables from the environment
cli_vars = skip_export
define build_cli
ifdef $(1)
        PACKER_VARS += -var '$(1)=$(2)'
endif
endef
$(foreach cli_var,$(cli_vars),$(eval $(call build_cli,$(cli_var),$(value $(cli_var)))))

output-export/win81x64-pro-disk001.vmdk: export.pkr.hcl .snapshots/provision | poweroff
	packer build -timestamp-ui -force$(PACKER_VARS) -var-file win81x64-pro.pkrvars.hcl $<

.snapshots/provision: provision.pkr.hcl .snapshots/install | setup
	packer build -timestamp-ui -var-file win81x64-pro.pkrvars.hcl $<
	touch $@

.snapshots/install: install.pkr.hcl output-win/win81x64-pro.vdi | setup
	packer build -timestamp-ui -var-file win81x64-pro.pkrvars.hcl $<
	touch $@

output-win/win81x64-pro.vdi: boot.pkr.hcl floppy/* | unregister
	packer build -timestamp-ui -force -var-file win81x64-pro.pkrvars.hcl $<

setup: | poweroff .snapshots

.snapshots:
	mkdir -p $@

.PHONY: poweroff unregister

poweroff:
	@-VBoxManage controlvm win81x64-pro poweroff 2>/dev/null || true

unregister: poweroff
	@-VBoxManage unregistervm win81x64-pro --delete 2>/dev/null || true
