sp := $(subst ,, )
_walk = $(if $1,$(wildcard /$(subst $(sp),/,$1)/$2) $(call _walk,$(wordlist 2,$(words $1),x $1),$2))
_find = $(firstword $(call _walk,$(strip $(subst /, ,$1)),$2))
_ROOT := $(patsubst %/root.mak,%,$(call _find,$(CURDIR),root.mak))

include $(_ROOT)/root.mak
include $(_ROOT)/top.mak

$(_MODULE_NAME)_OUTPUT := $(_ROOT)/vms

SRCS := main.cat.pkr.hcl
DEPS != find $(_ROOT)/floppy -type f
BINARY_EXT := $(_VDIEXT)

include $(_ROOT)/bottom.mak
