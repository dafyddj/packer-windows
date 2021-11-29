variable "headless" {
  type    = string
  default = "true"
}

variable "iso_checksum" {
}

variable "iso_url" {
}

variable "shutdown_command" {
  type    = string
  default = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
}

variable "skip_export" {
  type    = bool
  default = false
}

variable "vm_name" {
  type    = string
  default = "win81x64-pro"
}
source "virtualbox-vm" "export" {
  attach_snapshot         = "provisioned"
  boot_wait               = "-1s"
  communicator            = "winrm"
  guest_additions_mode    = "disable"
  headless                = "${var.headless}"
  keep_registered         = true
  shutdown_command        = "${var.shutdown_command}"
  skip_export             = "${var.skip_export}"
  virtualbox_version_file = ""
  vm_name                 = "${var.vm_name}"
  winrm_password          = "vagrant"
  winrm_timeout           = "10000s"
  winrm_username          = "vagrant"
}

build {
  sources = ["source.virtualbox-vm.export"]

  provisioner "powershell" {
    inline = [<<-EOF
      "Testing!"
      "Testing!"
      "123"
      EOF
    ]
  }

  provisioner "powershell" {
    inline = [
      "defrag C: /O /H /V",
    ]
  }
}
