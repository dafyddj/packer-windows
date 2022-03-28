sp := $(subst ,, )
_walk = $(if $1,$(wildcard /$(subst $(sp),/,$1)/$2) $(call _walk,$(wordlist 2,$(words $1),x $1),$2))
_find = $(firstword $(call _walk,$(strip $(subst /, ,$1)),$2))
_ROOT := $(patsubst %/root.mk,%,$(call _find,$(CURDIR),root.mk))

include $(_ROOT)/root.mk

$(call depends_on,export)

include $(_ROOT)/pre.mk

srcs := main.cat.pkr.hcl
artifact_pre := .
artifact_ext := $(snapext)

auto_version := $(shell $(_ROOT)/bin/version)
VERSION ?= $(auto_version)
_module_pvars :=  -var version=$(VERSION)

$(_module_name)_depends_on := export_artifact_$$*

include $(_ROOT)/post.mk
