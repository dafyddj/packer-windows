sp := $(subst ,, )
_walk = $(if $1,$(wildcard /$(subst $(sp),/,$1)/$2) $(call _walk,$(wordlist 2,$(words $1),x $1),$2))
_find = $(firstword $(call _walk,$(strip $(subst /, ,$1)),$2))
_ROOT := $(patsubst %/root.mk,%,$(call _find,$(CURDIR),root.mk))

include $(_ROOT)/root.mk
include $(_ROOT)/pre.mk

srcs := main.cat.pkr.hcl
extra_srcs != find $(_ROOT)/floppy -type f
artifact_ext = $(vdiext)

$(_module_name)_output := $(_ROOT)/vms/virtualbox

include $(_ROOT)/post.mk
