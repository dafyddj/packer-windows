sp := $(subst ,, )
_walk = $(if $1,$(wildcard /$(subst $(sp),/,$1)/$2) $(call _walk,$(wordlist 2,$(words $1),x $1),$2))
_find = $(firstword $(call _walk,$(strip $(subst /, ,$1)),$2))
_ROOT := $(patsubst %/root.mak,%,$(call _find,$(CURDIR),root.mak))

include $(_ROOT)/root.mak

$(call DEPENDS_ON,provision)

include $(_ROOT)/top.mak

srcs := main.cat.pkr.hcl
BINARY_EXT := $(boxext)

$(_MODULE_NAME)_DEPENDS_ON := provision_ARTIFACT_$$*
$(_MODULE_NAME)_OUTPUT := $(_ROOT)/box

include $(_ROOT)/bottom.mak
