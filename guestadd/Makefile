.DEFAULT_GOAL := .snapshot

.snapshot: main.cat.pkr.hcl ../install/.snapshot
	@-VBoxManage controlvm win81x64-pro poweroff 2>/dev/null || true
	packer build -timestamp-ui -force -only \*.win81 .
	touch $@

main.cat.pkr.hcl: build.in provision.in
	cat $^ > $@
	echo } >> $@
	packer validate .
