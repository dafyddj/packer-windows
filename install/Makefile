win_vers = win81 win10

all: $(win_vers)

$(win_vers): %: .%.snapshot

.SECONDEXPANSION:
.%.snapshot: main.pkr.hcl ../vms/$$*/$$*x64-pro.vdi
	@-VBoxManage controlvm $*x64-pro poweroff 2>/dev/null || true
	packer build -timestamp-ui -force -only \*.$* .
	touch $@
