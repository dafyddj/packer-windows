win_vers := win81 win10

all: $(win_vers)

$(win_vers): %: .%.snapshot

.%.snapshot: main.cat.pkr.hcl
	@-VBoxManage controlvm $*x64-pro poweroff 2>/dev/null || true
	packer build -timestamp-ui -force -only \*.$* .
	touch $@

main.cat.pkr.hcl: build.in provision.in
	cat $^ > $@
	echo } >> $@
