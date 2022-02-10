STAGES = boot install guestadd update provision export

.PHONY: stages $(STAGES)

stages: $(STAGES)

$(STAGES):
	$(MAKE) -C $@

install: boot
guestadd: install
update: guestadd
provision: update
export: provision
