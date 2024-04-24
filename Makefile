subdirs := $(shell cat stages)

include $(addsuffix /Makefile,$(subdirs))
