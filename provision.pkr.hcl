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

variable "vm_name" {
  type    = string
  default = "win81x64-pro"
}
source "virtualbox-vm" "provision" {
  attach_snapshot         = "installed"
  boot_wait               = "-1s"
  communicator            = "winrm"
  force_delete_snapshot   = true
  guest_additions_mode    = "disable"
  headless                = "${var.headless}"
  keep_registered         = true
  shutdown_command        = "${var.shutdown_command}"
  skip_export             = true
  target_snapshot         = "provisioned"
  virtualbox_version_file = ""
  vm_name                 = "${var.vm_name}"
  winrm_password          = "vagrant"
  winrm_timeout           = "10000s"
  winrm_username          = "vagrant"
}

build {
  sources = ["source.virtualbox-vm.provision"]

  provisioner "powershell" {
    inline = [<<-EOF
      Set-ExecutionPolicy Bypass -Scope Process -Force
      [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
      Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
      choco feature enable -n allowGlobalConfirmation
      choco install choco-cleaner --params /NOTASK:TRUE
      choco install git
      choco install wiztree --install-args /MERGETASKS=!desktopicon
      EOF
    ]
  }
  provisioner "powershell" {
    inline = [
      "choco-cleaner.ps1",
      "exit 0",
    ]
  }
}
