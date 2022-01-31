# Packer templates for Windows

### Overview

This repository contains templates for Windows that can create
Vagrant boxes using Packer.

## Core Boxes

64-bit boxes:

* win81x64-pro-salt
* win10x64-pro-salt

## Building the Vagrant boxes

To build all the boxes, you will need both VirtualBox and VMware Fusion or Workstation installed.

A GNU Make `Makefile` drives the process via the following targets:

    make        # Build all the box types (VirtualBox & VMware)
    make test   # Run tests against all the boxes
    make list   # Print out individual targets
    make clean  # Clean up build detritus

To build one particular box, e.g. `eval-win7x86-enterprise`, for just one provider, e.g. VirtualBox, first run `make list` subcommand:
```
make list
```

This command prints the list of available boxes. Then you can build one particular box for choosen provider:
```
make virtualbox/eval-win7x86-enterprise
```

## References

* (Creating windows base images using Packer and Boxstarter)[http://www.hurryupandwait.io/blog/creating-windows-base-images-for-virtualbox-and-hyper-v-using-packer-boxstarter-and-vagrant]
* (Why does the Disk Cleanup tool’s Windows Update Cleanup take so long and consume so much CPU?)[https://devblogs.microsoft.com/oldnewthing/20200922-00/?p=104252]
* (How big is Windows 10?)[https://oofhours.com/2021/03/16/how-big-is-windows-10/]
* (Creating the smallest Windows 10 image)[https://oofhours.com/2021/04/03/creating-the-smallest-windows-10-image/]
