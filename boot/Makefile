vms: ../vms/win81x64-pro.vdi ../vms/win10x64-pro.vdi

../vms/%x64-pro.vdi: main.cat.pkr.hcl ../floppy/*
	@-VBoxManage controlvm $*x64-pro poweroff 2>/dev/null || true
	@-VBoxManage unregistervm $*x64-pro --delete 2>/dev/null || true
	packer build -timestamp-ui -force -only \*.$* .

main.cat.pkr.hcl: build.in provision.in
	cat $^ > $@
	echo } >> $@
	packer validate .
