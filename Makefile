stages := boot install guestadd update provision export

.PHONY: all $(stages)
all: $(stages)

$(stages):
	$(MAKE) -C $@ $(OS)

install: boot
guestadd: install
update: guestadd
provision: update
export: provision
