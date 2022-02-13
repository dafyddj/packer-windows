win_vers = win81 win10

all: $(win_vers)

$(win_vers): %: ../box/virtualbox-vm/%x64-pro-salt.box

.SECONDEXPANSION:
../box/virtualbox-vm/%x64-pro-salt.box: main.cat.pkr.hcl ../provision/.$$*.snapshot
	@-VBoxManage controlvm $*x64-pro poweroff 2>/dev/null || true
	packer build -timestamp-ui -force -only \*.$* .

main.cat.pkr.hcl: build.in provision.in
	cat $^ > $@
	echo } >> $@ 
	packer validate .
