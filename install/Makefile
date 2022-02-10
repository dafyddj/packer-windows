.DEFAULT_GOAL := .snapshot

.snapshot: main.pkr.hcl ../vms/win81x64-pro.vdi
	@-VBoxManage controlvm win81x64-pro poweroff 2>/dev/null || true
	packer build -timestamp-ui -force -only \*.win81 .
	touch $@
