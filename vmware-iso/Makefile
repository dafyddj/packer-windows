stages := boot guestadd update provision export
stages := $(addprefix ../, $(addsuffix /provision.in,$(stages)))

main.cat.pkr.hcl: build.in $(stages)
	cat $^ > $@
	echo } >> $@
	packer validate .
