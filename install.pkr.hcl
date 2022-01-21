variable "disable_breakpoint" {
  type    = bool
  default = true
}

variable "headless" {
  type    = string
  default = "true"
}

variable "shutdown_command" {
  type    = string
  default = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
}

variable "vm_name" {
  type    = string
  default = "win81x64-pro"
}

source "virtualbox-vm" "install" {
  boot_wait               = "-1s"
  communicator            = "winrm"
  force_delete_snapshot   = true
  guest_additions_mode    = "disable"
  headless                = "${var.headless}"
  keep_registered         = true
  shutdown_command        = "${var.shutdown_command}"
  skip_export             = true
  target_snapshot         = "installed"
  virtualbox_version_file = ""
  winrm_password          = "vagrant"
  winrm_timeout           = "10000s"
  winrm_username          = "vagrant"
}

build {
  name = "install"

  source "virtualbox-vm.install" {
    name    = "win81"
    vm_name = "win81x64-pro"
  }
  source "virtualbox-vm.install" {
    name    = "win10"
    vm_name = "win10x64-pro"
  }
}
