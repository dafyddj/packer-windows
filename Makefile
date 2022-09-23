subdirs = boot install guestadd update provision export

include $(addsuffix /Makefile,$(subdirs))
