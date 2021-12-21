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
source "virtualbox-vm" "provision" {
  attach_snapshot         = "updated"
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
  winrm_password          = "vagrant"
  winrm_timeout           = "10000s"
  winrm_username          = "vagrant"
}

build {
  name = "provision"

  source "virtualbox-vm.provision" {
    name    = "win81"
    vm_name = "win81x64-pro"
  }

  source "virtualbox-vm.provision" {
    name    = "win10"
    vm_name = "win10x64-pro"
  }

  provisioner "powershell" {
    inline = [<<-EOF
      Set-ExecutionPolicy Bypass -Scope Process -Force
      [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
      Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
      choco feature enable -n allowGlobalConfirmation
      choco install choco-cleaner --params /NOTASK:TRUE
      (gc -Raw C:\tools\BCURRAN3\choco-cleaner.ps1) -replace 'Start-Sleep -s 10','Start-Sleep -s 0' `
        | sc C:\tools\BCURRAN3\choco-cleaner.ps1
      choco install git
      choco install wiztree --install-args /MERGETASKS=!desktopicon
      choco install saltminion --version 3003.3 --params /MinionStart:0
      # Salt installer doesn't correctly set Minion service
      Set-Service salt-minion -StartupType Manual
      Stop-Service salt-minion
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
