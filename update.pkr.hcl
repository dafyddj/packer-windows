packer {
  required_plugins {
    windows-update = {
      version = "0.14.0"
      source = "github.com/rgl/windows-update"
    }
  }
}

variable "disable_breakpoint" {
  type    = bool
  default = true
}

variable "filters" {
  type    = list(string)
  default = ["include:$true"]
}

variable "headless" {
  type    = string
  default = "true"
}

variable "search_criteria" {
  # Install Important updates only
  type    = string
  default = "AutoSelectOnWebSites=1 and IsInstalled=0"
}

variable "shutdown_command" {
  type    = string
  default = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
}
variable "update_limit" {
  type    = number
  default = 1000
}

variable "vm_name" {
  type    = string
  default = "win81x64-pro"
}

source "virtualbox-vm" "update" {
  attach_snapshot         = "guestadded"
  boot_wait               = "-1s"
  communicator            = "winrm"
  force_delete_snapshot   = true
  guest_additions_mode    = "disable"
  headless                = "${var.headless}"
  keep_registered         = true
  shutdown_command        = "${var.shutdown_command}"
  skip_export             = true
  target_snapshot         = "updated"
  virtualbox_version_file = ""
  winrm_password          = "vagrant"
  winrm_timeout           = "10000s"
  winrm_username          = "vagrant"
}

build {
  name = "update"

  source "virtualbox-vm.update" {
    name    = "win81"
    vm_name = "win81x64-pro"
  }

  source "virtualbox-vm.update" {
    name    = "win10"
    vm_name = "win10x64-pro"
  }

  provisioner "windows-update" {
    filters         = var.filters
    search_criteria = var.search_criteria
    update_limit    = var.update_limit
  }

  provisioner "windows-update" {
    filters         = var.filters
    search_criteria = var.search_criteria
    update_limit    = var.update_limit
  }

  provisioner "breakpoint" {
    disable = var.disable_breakpoint
  }

  provisioner "powershell" {
    inline = [<<-EOF
      $cleanupTypes = @(
        "Update Cleanup",
        "Windows Defender"
      )
      $regKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
      $state = "StateFlags0100"

      Write-Host "Post-Update Cleanup..."
      foreach ($cleanup in $cleanupTypes) {
        Write-Host "==> Setting:" $cleanup
        New-ItemProperty -Path "$regKey\$cleanup" -Name $state -Value 2 -PropertyType DWord -Force | Out-Null
      }
      if (Test-Path "$env:SystemRoot\System32\cleanmgr.exe") {
        Write-Host "==> Running ""cleanmgr"""
        Start-Process -Wait cleanmgr -Args /sagerun:100
      }

      Write-Host "==> Running ""Dism ... /StartComponentCleanup /ResetBase"""
      Dism /Online /Cleanup-Image /StartComponentCleanup /ResetBase

      Dism /Online /Cleanup-Image /AnalyzeComponentStore
      EOF
    ]
  }
}
