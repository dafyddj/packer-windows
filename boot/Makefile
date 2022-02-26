sp := $(subst ,, )
_walk = $(if $1,$(wildcard /$(subst $(sp),/,$1)/$2) $(call _walk,$(wordlist 2,$(words $1),x $1),$2))
_find = $(firstword $(call _walk,$(strip $(subst /, ,$1)),$2))
_ROOT := $(patsubst %/root.mak,%,$(call _find,$(CURDIR),root.mak))

include $(_ROOT)/root.mak
include $(_ROOT)/top.mak

srcs := main.cat.pkr.hcl
extra_srcs != find $(_ROOT)/floppy -type f
BINARY_EXT := $(vdiext)

$(_MODULE_NAME)_OUTPUT := $(_ROOT)/vms

include $(_ROOT)/bottom.mak
