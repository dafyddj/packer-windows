../box/virtualbox-vm/win81x64-pro-salt.box: main.cat.pkr.hcl ../provision/.snapshot
	@-VBoxManage controlvm win81x64-pro poweroff 2>/dev/null || true
	packer build -timestamp-ui -force -only \*.win81 .

main.cat.pkr.hcl: build.in provision.in
	cat $^ > $@
	echo } >> $@ 
	packer validate .
