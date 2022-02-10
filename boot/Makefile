../vms/win81x64-pro.vdi: main.cat.pkr.hcl ../floppy/*
	@-VBoxManage controlvm win81x64-pro poweroff 2>/dev/null || true
	@-VBoxManage unregistervm win81x64-pro --delete 2>/dev/null || true
	packer build -timestamp-ui -force -only \*.win81 .

main.cat.pkr.hcl: build.in provision.in
	cat $^ > $@
	echo } >> $@
	packer validate .
