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

vdiext = /$(win_ver).vdi
snapext := .snapshot
boxext := .box

win_vers := win81 win10

artifact_pre :=
extra_srcs :=

PACKER := packer
PFLAGS := -timestamp-ui -force

VBOXMANAGE := VBoxManage
