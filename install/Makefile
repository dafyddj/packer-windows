sp := $(subst ,, )
_walk = $(if $1,$(wildcard /$(subst $(sp),/,$1)/$2) $(call _walk,$(wordlist 2,$(words $1),x $1),$2))
_find = $(firstword $(call _walk,$(strip $(subst /, ,$1)),$2))
_ROOT := $(patsubst %/root.mak,%,$(call _find,$(CURDIR),root.mak))

include $(_ROOT)/root.mak

$(call DEPENDS_ON,boot)

include $(_ROOT)/top.mak

SRCS := main.pkr.hcl
BINARY_PRE := .
BINARY_EXT := $(_SNAPEXT)
DEPS := boot-%

include $(_ROOT)/bottom.mak
