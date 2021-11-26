# if Makefile.local exists, include it
ifneq ("$(wildcard Makefile.local)", "")
        include Makefile.local
endif

# Possible values for cm: (nocm | chef | chefdk | salt | puppet)
cm ?= salt
# Possible values for cm_version: (latest | x.y.z | x.y)
# cm_version needs to be empty in the case cm=nocm
cm_version ?=
ifndef cm_version
       ifneq ($(cm),nocm)
               cm_version = latest
       endif
endif

auto_version := $(shell bin/version)
version ?= $(auto_version)
GENERALIZE ?= false
ifndef shutdown_command
ifeq ($(GENERALIZE),true)
	shutdown_command ?= C:/Windows/System32/Sysprep/sysprep.exe /generalize /shutdown /oobe /unattend:A:/Autounattend.xml
endif
endif
ifeq ($(cm),nocm)
	BOX_SUFFIX := -$(cm)-$(version).box
else
	BOX_SUFFIX := -$(cm)$(cm_version)-$(version).box
endif

# Packer does not allow empty variables, so only pass variables that are defined
cli_vars = cm cm_version version update headless shutdown_command update_limit
define build_cli
ifdef $(1)
	PACKER_VARS += -var '$(1)=$(2)'
endif
endef
$(foreach cli_var,$(cli_vars),$(eval $(call build_cli,$(cli_var),$(value $(cli_var)))))

PACKER ?= packer
ifdef PACKER_DEBUG
	PACKER := PACKER_LOG=1 $(PACKER)
else
endif
BUILDER_TYPES ?= vmware virtualbox parallels
ifeq ($(OS),Windows_NT)
	VAGRANT_PROVIDER ?= vmware_workstation
else
	VAGRANT_PROVIDER ?= vmware_fusion
endif
TEMPLATE_FILENAMES := $(wildcard *.pkrvars.hcl)
BOX_FILENAMES := $(TEMPLATE_FILENAMES:.pkrvars.hcl=$(BOX_SUFFIX))
TEST_BOX_FILES := $(foreach builder, $(BUILDER_TYPES), $(foreach box_filename, $(BOX_FILENAMES), test-box/$(builder)/$(box_filename)))
VMWARE_BOX_DIR := box/vmware
VIRTUALBOX_BOX_DIR := box/virtualbox-iso
PARALLELS_BOX_DIR := box/parallels
VMWARE_BOX_FILES := $(foreach box_filename, $(BOX_FILENAMES), $(VMWARE_BOX_DIR)/$(box_filename))
VIRTUALBOX_BOX_FILES := $(foreach box_filename, $(BOX_FILENAMES), $(VIRTUALBOX_BOX_DIR)/$(box_filename))
PARALLELS_BOX_FILES := $(foreach box_filename, $(BOX_FILENAMES), $(PARALLELS_BOX_DIR)/$(box_filename))
BOX_FILES := $(foreach builder, $(BUILDER_TYPES), $(foreach box_filename, $(BOX_FILENAMES), box/$(builder)/$(box_filename)))
VMWARE_OUTPUT := output-vmware-iso
VIRTUALBOX_OUTPUT := output-virtualbox-iso
PARALLELS_OUTPUT := output-parallels-iso
VMWARE_BUILDER := vmware-iso
VIRTUALBOX_BUILDER := virtualbox-iso
PARALLELS_BUILDER := parallels-iso
CURRENT_DIR := $(shell pwd)
UNAME_O := $(shell uname -o 2> /dev/null)
UNAME_P := $(shell uname -p 2> /dev/null)
UNAME_S := $(shell uname -s 2> /dev/null)
ifeq ($(UNAME_O),Cygwin)
	CURRENT_DIR := $(shell cygpath -m $(CURRENT_DIR))
endif

SOURCES := $(wildcard script/*.*) $(wildcard floppy/*.*)

.PHONY: list

all: $(BOX_FILES)

test: $(TEST_BOX_FILES)

###############################################################################
# Target shortcuts
define SHORTCUT

ifeq ($(UNAME_S),Darwin)

$(1): $(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX) $(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX) $(PARALLELS_BOX_DIR)/$(1)$(BOX_SUFFIX)

$(1)-cygwin: $(VMWARE_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX) $(VIRTUALBOX_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX) $(PARALLELS_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

$(1)-ssh: $(VMWARE_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX) $(VIRTUALBOX_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX) $(PARALLELS_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

test-$(1): test-$(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX) test-$(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX) test-$(PARALLELS_BOX_DIR)/$(1)$(BOX_SUFFIX)

test-$(1)-cygwin: test-$(VMWARE_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX) test-$(VIRTUALBOX_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX) test-$(PARALLELS_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

test-$(1)-ssh: test-$(VMWARE_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX) test-$(VIRTUALBOX_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX) test-$(PARALLELS_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

s3cp-$(1): s3cp-$(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX) s3cp-$(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX) s3cp-$(PARALLELS_BOX_DIR)/$(1)$(BOX_SUFFIX)

else

$(1): $(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX) $(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX)

$(1)-cygwin: $(VMWARE_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX) $(VIRTUALBOX_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

$(1)-ssh: $(VMWARE_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX) $(VIRTUALBOX_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

test-$(1): test-$(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX) test-$(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX)

test-$(1)-cygwin: test-$(VMWARE_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX) test-$(VIRTUALBOX_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

test-$(1)-ssh: test-$(VMWARE_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX) test-$(VIRTUALBOX_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

s3cp-$(1): s3cp-$(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX) s3cp-$(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX)

endif

vmware/$(1): $(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX)

vmware/$(1)-cygwin: $(VMWARE_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

vmware/$(1)-ssh: $(VMWARE_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

virtualbox/$(1): $(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX)

virtualbox/$(1)-cygwin: $(VIRTUALBOX_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

virtualbox/$(1)-ssh: $(VIRTUALBOX_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

parallels/$(1): $(PARALLELS_BOX_DIR)/$(1)$(BOX_SUFFIX)

parallels/$(1)-cygwin: $(PARALLELS_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

parallels/$(1)-ssh: $(PARALLELS_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

test-vmware/$(1): test-$(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX)

test-vmware/$(1)-cygwin: test-$(VMWARE_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

test-vmware/$(1)-ssh: test-$(VMWARE_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

test-virtualbox/$(1): test-$(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX)

test-virtualbox/$(1)-cygwin: test-$(VIRTUALBOX_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

test-virtualbox/$(1)-ssh: test-$(VIRTUALBOX_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

test-parallels/$(1): test-$(PARALLELS_BOX_DIR)/$(1)$(BOX_SUFFIX)

test-parallels/$(1)-cygwin: test-$(PARALLELS_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

test-parallels/$(1)-ssh: test-$(PARALLELS_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

ssh-vmware/$(1): ssh-$(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX)

ssh-vmware/$(1)-cygwin: ssh-$(VMWARE_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

ssh-vmware/$(1)-ssh: ssh-$(VMWARE_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

ssh-virtualbox/$(1): ssh-$(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX)

ssh-virtualbox/$(1)-cygwin: ssh-$(VIRTUALBOX_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

ssh-virtualbox/$(1)-ssh: ssh-$(VIRTUALBOX_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

ssh-parallels/$(1): ssh-$(PARALLELS_BOX_DIR)/$(1)$(BOX_SUFFIX)

ssh-parallels/$(1)-cygwin: ssh-$(PARALLELS_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX)

ssh-parallels/$(1)-ssh: ssh-$(PARALLELS_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX)

s3cp-vmware/$(1): s3cp-$(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX)

s3cp-virtualbox/$(1): s3cp-$(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX)

s3cp-parallels/$(1): s3cp-$(PARALLELS_BOX_DIR)/$(1)$(BOX_SUFFIX)
endef

SHORTCUT_TARGETS := $(filter-out pkrvars hcl,$(subst ., ,$(TEMPLATE_FILENAMES)))
$(foreach i,$(SHORTCUT_TARGETS),$(eval $(call SHORTCUT,$(i))))

###############################################################################

win81: win81-winrm win81-openssh win81-cygwin

win81-winrm: win81x64-enterprise win81x64-pro win81x86-enterprise win81x86-pro

win81-openssh: win81x64-enterprise-ssh win81x64-pro-ssh win81x86-enterprise-ssh win81x86-pro-ssh

win81-cygwin: win81x64-enterprise-cygwin win81x64-pro-cygwin win81x86-enterprise-cygwin win81x86-pro-cygwin


test-win81: test-win81-winrm test-win81-openssh test-win81-cygwin

test-win81-winrm: test-win81x64-enterprise test-win81x64-pro test-win81x86-enterprise test-win81x86-pro

test-win81-openssh: test-win81x64-enterprise-ssh test-win81x64-pro-ssh test-win81x86-enterprise-ssh test-win81x86-pro-ssh

test-win81-cygwin: test-win81x64-enterprise-cygwin test-win81x64-pro-cygwin test-win81x86-enterprise-cygwin test-win81x86-pro-cygwin



define BUILDBOX

$(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX): $(1).pkrvars.hcl
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -timestamp-ui -only="$(VIRTUALBOX_BUILDER).*" $(PACKER_VARS) -var-file $(1).pkrvars.hcl winx64-pro.pkr.hcl

$(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX): $(1).json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(1).json

$(PARALLELS_BOX_DIR)/$(1)$(BOX_SUFFIX): $(1).json
	rm -rf $(PARALLELS_OUTPUT)
	mkdir -p $(PARALLELS_BOX_DIR)
	$(PACKER) build -only=$(PARALLELS_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(1).json

$(VIRTUALBOX_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX): $(1)-ssh.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(1)-ssh.json

$(VMWARE_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX): $(1)-ssh.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(1)-ssh.json

$(PARALLELS_BOX_DIR)/$(1)-ssh$(BOX_SUFFIX): $(1)-ssh.json
	rm -rf $(PARALLELS_OUTPUT)
	mkdir -p $(PARALLELS_BOX_DIR)
	$(PACKER) build -only=$(PARALLELS_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(1)-ssh.json

$(VIRTUALBOX_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX): $(1)-cygwin.json
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(1)-cygwin.json

$(VMWARE_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX): $(1)-cygwin.json
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(1)-cygwin.json

$(PARALLELS_BOX_DIR)/$(1)-cygwin$(BOX_SUFFIX): $(1)-cygwin.json
	rm -rf $(PARALLELS_OUTPUT)
	mkdir -p $(PARALLELS_BOX_DIR)
	$(PACKER) build -only=$(PARALLELS_BUILDER) $(PACKER_VARS) -var "iso_url=$(2)" -var "iso_checksum=$(3)" $(1)-cygwin.json

endef

$(eval $(call BUILDBOX,win81x64-pro,$(WIN81_X64_PRO),$(WIN81_X64_PRO_CHECKSUM)))

$(eval $(call BUILDBOX,win10x64-pro,$(WIN10_X64_PRO),$(WIN10_X64_PRO_CHECKSUM)))

# Generic rule - not used currently
#$(VMWARE_BOX_DIR)/%$(BOX_SUFFIX): %.json
#       cd $(dir $<)
#       rm -rf output-vmware-iso
#       mkdir -p $(VMWARE_BOX_DIR)
#       $(PACKER) build -only=vmware-iso $(PACKER_VARS) $<

# Generic rule - not used currently
#$(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX): %.json
#       cd $(dir $<)
#       rm -rf output-virtualbox-iso
#       mkdir -p $(VIRTUALBOX_BOX_DIR)
#       $(PACKER) build -only=virtualbox-iso $(PACKER_VARS) $<

list:
	@echo "To build for all target platforms:"
	@echo "  make win7x64-pro"
	@echo ""
	@echo "Prepend 'vmware/' or 'virtualbox/' or 'parallels/' to build only one target platform:"
	@echo "  make vmware/win7x64-pro"
	@echo ""
	@echo "Append '-cygwin' to use Cygwin's SSH instead of OpenSSH:"
	@echo "  make win7x64-pro-cygwin"
	@echo ""
	@echo "Or to build for vmware only:"
	@echo "  make vmware/win7x64-pro-cygwin"
	@echo ""
	@echo "Targets:"
	@for shortcut_target in $(SHORTCUT_TARGETS) ; do \
		echo $$shortcut_target ; \
	done | sort

validate:
	@for template_filename in $(TEMPLATE_FILENAMES) ; do \
		echo Checking $$template_filename ; \
		$(PACKER) validate $$template_filename ; \
	done

clean: clean-builders clean-output clean-packer-cache

clean-builders:
	@for builder in $(BUILDER_TYPES) ; do \
		if test -d box/$$builder ; then \
			echo Deleting box/$$builder/*.box ; \
			find box/$$builder -maxdepth 1 -type f -name "*.box" ! -name .gitignore -exec rm '{}' \; ; \
		fi ; \
	done

clean-output:
	@for builder in $(BUILDER_TYPES) ; do \
		echo Deleting output-$$builder-iso ; \
		echo rm -rf output-$$builder-iso ; \
	done

clean-packer-cache:
	echo Deleting packer_cache
	rm -rf packer_cache

test-$(VMWARE_BOX_DIR)/%$(BOX_SUFFIX): $(VMWARE_BOX_DIR)/%$(BOX_SUFFIX)
	-test -f .keep_known_hosts || rm -f ~/.ssh/known_hosts
	bin/test-box.sh $< vmware_desktop $(VAGRANT_PROVIDER) $(CURRENT_DIR)/test/*_spec.rb

test-$(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX): $(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX)
	-test -f .keep_known_hosts || rm -f ~/.ssh/known_hosts
	bin/test-box.sh $< virtualbox virtualbox $(CURRENT_DIR)/test/*_spec.rb

test-$(PARALLELS_BOX_DIR)/%$(BOX_SUFFIX): $(PARALLELS_BOX_DIR)/%$(BOX_SUFFIX)
	-test -f .keep_known_hosts || rm -f ~/.ssh/known_hosts
	bin/test-box.sh $< parallels parallels $(CURRENT_DIR)/test/*_spec.rb

S3_STORAGE_CLASS ?= REDUCED_REDUNDANCY
S3_ALLUSERS_ID ?= uri=http://acs.amazonaws.com/groups/global/AllUsers

s3cp-$(VMWARE_BOX_DIR)/%$(BOX_SUFFIX): $(VMWARE_BOX_DIR)/%$(BOX_SUFFIX)
	aws s3 cp $< $(VMWARE_S3_BUCKET) --storage-class $(S3_STORAGE_CLASS) --grants full=$(S3_GRANT_ID) read=$(S3_ALLUSERS_ID)

s3cp-$(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX): $(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX)
	aws s3 cp $< $(VIRTUALBOX_S3_BUCKET) --storage-class $(S3_STORAGE_CLASS) --grants full=$(S3_GRANT_ID) read=$(S3_ALLUSERS_ID)

s3cp-$(PARALLELS_BOX_DIR)/%$(BOX_SUFFIX): $(PARALLELS_BOX_DIR)/%$(BOX_SUFFIX)
	aws s3 cp $< $(PARALLELS_S3_BUCKET) --storage-class $(S3_STORAGE_CLASS) --grants full=$(S3_GRANT_ID) read=$(S3_ALLUSERS_ID)

s3cp-vmware: $(addprefix s3cp-,$(VMWARE_BOX_FILES))
s3cp-virtualbox: $(addprefix s3cp-,$(VIRTUALBOX_BOX_FILES))
s3cp-parallels: $(addprefix s3cp-,$(PARALLELS_BOX_FILES))
