main.cat.pkr.hcl: build.in ../boot/provision.in ../provision/provision.in ../export/provision.in
	cat $^ > $@
	echo } >> $@
	packer validate .
