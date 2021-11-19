
variable "cm" {
  type    = string
  default = "salt"
}

variable "cm_version" {
  type    = string
  default = ""
}

variable "cpus" {
  type    = string
  default = "1"
}

variable "disk_size" {
  type    = string
  default = "20480"
}

variable "headless" {
  type    = string
  default = "false"
}

variable "iso_checksum" {
  type    = string
  default = "e50a6f0f08e933f25a71fbc843827fe752ed0365"
}

variable "iso_url" {
  type    = string
  default = "iso/en_windows_8.1_professional_vl_with_update_x64_dvd_4065194.iso"
}

variable "memory" {
  type    = string
  default = "1536"
}

variable "shutdown_command" {
  type    = string
  default = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
}

variable "update" {
  type    = string
  default = "true"
}

variable "version" {
  type    = string
  default = "0.1.0"
}

source "virtualbox-iso" "win" {
  communicator         = "winrm"
  cpus                 = "${var.cpus}"
  disk_size            = "${var.disk_size}"
  floppy_files         = ["floppy/00-run-all-scripts.cmd", "floppy/01-install-wget.cmd", "floppy/02-wsus-settings.cmd", "floppy/_download.cmd", "floppy/_packer_config.cmd", "floppy/disablewinupdate.bat", "floppy/_disable-autologon.cmd", "floppy/fixnetwork.ps1", "floppy/install-winrm.cmd", "floppy/oracle-cert.cer", "floppy/passwordchange.bat", "floppy/powerconfig.bat", "floppy/win81x64-pro/Autounattend.xml", "floppy/zz-start-sshd.cmd"]
  guest_additions_mode = "attach"
  guest_os_type        = "Windows8_64"
  hard_drive_interface = "sata"
  headless             = "${var.headless}"
  iso_checksum         = "${var.iso_checksum}"
  iso_url              = "${var.iso_url}"
  memory               = "${var.memory}"
#  output_directory     = "/Volumes/512Gb/${build.name}-output/${var.version}"
  post_shutdown_delay  = "1m"
  shutdown_command     = "${var.shutdown_command}"
#  vboxmanage           = [["setextradata", "{{ .Name }}", "VBoxInternal/CPUM/CMPXCHG16B", "1"]]
  vm_name              = "win81x64-pro"
  winrm_password       = "vagrant"
  winrm_timeout        = "10000s"
  winrm_username       = "vagrant"
}

source "vmware-iso" "win" {
  communicator        = "winrm"
  cores               = "1"
  cpus                = "${var.cpus}"
  disk_size           = "${var.disk_size}"
  floppy_files        = ["floppy/00-run-all-scripts.cmd", "floppy/01-install-wget.cmd", "floppy/_download.cmd", "floppy/_packer_config.cmd", "floppy/fixnetwork.ps1", "floppy/install-winrm.cmd", "floppy/passwordchange.bat", "floppy/powerconfig.bat", "floppy/win81x64-pro/Autounattend.xml", "floppy/zz-start-sshd.cmd"]
  guest_os_type       = "windows8-64"
  headless            = "${var.headless}"
  iso_checksum        = "${var.iso_checksum}"
  iso_url             = "${var.iso_url}"
  memory              = "${var.memory}"
#  output_directory    = "/Volumes/512Gb/${build.name}-output/${var.version}"
  shutdown_command    = "${var.shutdown_command}"
  tools_upload_flavor = "windows"
  vm_name             = "win81x64-pro"
  vmx_data = {
    "scsi0.virtualDev" = "lsisas1068"
  }
  winrm_password = "vagrant"
  winrm_timeout  = "10000s"
  winrm_username = "vagrant"
}

build {
  sources = ["source.virtualbox-iso.win"]

  provisioner "windows-shell" {
    environment_vars = ["CM=${var.cm}", "CM_VERSION=${var.cm_version}", "UPDATE=${var.update}"]
    scripts          = ["script/vagrant.bat", "script/cmtool.bat", "script/vmtool.bat"]
  }

  provisioner "breakpoint" {
    disable = true
  }

  provisioner "powershell" {
    elevated_password = "vagrant"
    elevated_user     = "vagrant"
    environment_vars  = ["CM=${var.cm}", "CM_VERSION=${var.cm_version}", "UPDATE=${var.update}"]
    script            = "script/windows-updates.ps1"
  }

  provisioner "windows-restart" {
    restart_timeout = "60m"
  }

  provisioner "powershell" {
    elevated_password = "vagrant"
    elevated_user     = "vagrant"
    environment_vars  = ["CM=${var.cm}", "CM_VERSION=${var.cm_version}", "UPDATE=${var.update}"]
    scripts           = ["script/after-reboot.ps1", "script/chocolatey.ps1"]
  }

  provisioner "windows-restart" {
    restart_timeout = "60m"
  }

  provisioner "powershell" {
    elevated_password = "vagrant"
    elevated_user     = "vagrant"
    environment_vars  = ["CM=${var.cm}", "CM_VERSION=${var.cm_version}", "UPDATE=${var.update}"]
    scripts           = ["script/clean.ps1"]
  }

  provisioner "windows-shell" {
    environment_vars = ["CM=${var.cm}", "CM_VERSION=${var.cm_version}", "UPDATE=${var.update}"]
    scripts          = ["script/unset-wsus-settings.cmd", "script/git.bat", "script/ultradefrag.bat", "script/uninstall-7zip.bat", "script/sdelete.bat"]
  }

  provisioner "windows-restart" {
    restart_timeout = "60m"
  }

  post-processor "vagrant" {
    keep_input_artifact  = false
    compression_level    = 1
    output               = "box/${source.type}/win81x64-pro-${var.cm}${var.cm_version}-${var.version}.box"
    vagrantfile_template = "tpl/vagrantfile-win81x64-pro.tpl"
  }
}
