packer {
  required_plugins {
    windows-update = {
      version = "0.14.0"
      source = "github.com/rgl/windows-update"
    }
  }
}

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
  default = "2"
}

variable "disk_size" {
  type    = string
  default = "20480"
}

variable "guest_os_type" {
  type    = string
  default = "Windows81_64"
}

variable "headless" {
  type    = string
  default = "true"
}

variable "iso_checksum" {
  type    = string
  default = "de3d15afbda350f77c27aad76844477e396e947302d7402c09a16f3fa7254c68"
}

variable "iso_url" {
  type    = string
  default = "iso/Win8.1_EnglishInternational_x64.iso"
}

variable "memory" {
  type    = string
  default = "1536"
}

variable "shutdown_command" {
  type    = string
  default = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
}

variable "update_limit" {
  type    = number
  default = 1000
}

variable "version" {
  type    = string
  default = "0.1.0"
}

variable "vm_name" {
  type    = string
  default = "win81x64-pro"
}

source "virtualbox-iso" "boot" {
  communicator         = "winrm"
  cpus                 = "${var.cpus}"
  disk_size            = "${var.disk_size}"
  floppy_files         = ["floppy/00-run-all-scripts.cmd",
                          "floppy/01-install-wget.cmd",
                          "floppy/_download.cmd",
                          "floppy/_packer_config.cmd",
                          "floppy/disablewinupdate.bat",
                          "floppy/install-winrm.cmd",
                          "floppy/oracle-cert.cer",
                          "floppy/powerconfig.bat",
                          "floppy/${var.vm_name}/Autounattend.xml",
                          "floppy/zz-start-sshd.cmd"]
  guest_additions_mode = "disable"
  guest_os_type        = "${var.guest_os_type}"
  headless             = "${var.headless}"
  hard_drive_discard   = true
  hard_drive_nonrotational = true
  iso_checksum         = "${var.iso_checksum}"
  iso_url              = "${var.iso_url}"
  keep_registered      = true
  memory               = "${var.memory}"
  shutdown_command     = "${var.shutdown_command}"
  skip_export          = true
  virtualbox_version_file = ""
  vm_name              = "${var.vm_name}"
  winrm_password       = "vagrant"
  winrm_timeout        = "10000s"
  winrm_username       = "vagrant"
}
build {
  sources = ["source.virtualbox-iso.boot"]


  provisioner "powershell" {
    inline = ["Get-Content $env:TEMP/00-run-all-scripts.log.txt"]
  }

  provisioner "breakpoint" {
    disable = true
  }
}
