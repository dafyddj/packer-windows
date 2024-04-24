.PHONY: all
all:

_makefiles := $(filter %/Makefile,$(MAKEFILE_LIST))
_included_from := $(patsubst $(_ROOT)/%,%,$(if $(_makefiles), \
$(patsubst %/Makefile,%,$(word $(words $(_makefiles)),$(_makefiles)))))
ifeq ($(_included_from),)
_module := $(patsubst $(_ROOT)/%,%,$(CURDIR))
else
_module := $(_included_from)
endif
_module_path := $(_ROOT)/$(_module)
_module_name := $(subst /,_,$(_module))
$(_module_name)_output := $(_module_path)

vdiext = .vdi
snapext := .snapshot
boxext := .box

os_vers := $(shell cat $(_ROOT)/os_vers)

artifact_pre :=
extra_srcs :=

PACKER := packer
PFLAGS := -timestamp-ui -force

VBOXMANAGE := VBoxManage
