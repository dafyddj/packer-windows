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
      @(
        "C:\Recovery",
        "C:\Windows\Logs",
        "C:\Windows\WinSxS\Backup",
        "C:\Windows\WinSxS\ManifestCache",
        "C:\Windows\WinSxS\Temp\PendingDeletes"
      ) | % {
        Get-ChildItem -Recurse -File $_ |
        Select-Object -ExpandProperty FullName | % {
          Write-Host "Removing ""$_"
          takeown /F $_ /A | Out-Null
          icacls $_ /grant:r Administrators:F /Q | Out-Null
          Remove-Item -Recurse -Force $_
        }
      }

      Dism /Online /Cleanup-Image /AnalyzeComponentStore
      EOF
    ]
  }

  provisioner "powershell" {
    inline = [<<-EOF
      $ProgressPreference = 'SilentlyContinue'
      Write-Host "Removing AppX Packages..."
      Get-AppxProvisionedPackage -Online | % {
        Write-Host "==> Deprovisioning:" $_.DisplayName
        $_ | Remove-AppxProvisionedPackage -Online | Out-Null
      }
      Get-AppxPackage | ? { $_.InstallLocation -like "*WindowsApps*" -and
        $_.Name -notlike "*VCLibs*" -and
        $_.Name -notlike "*WinJS*" } | % {
        Write-Host "==> Removing:" $_.Name
        $_ | Remove-AppxPackage | Out-Null
      }
      EOF
    ]
  }

  provisioner "powershell" {
    inline = [<<-EOF
      Write-Host "Zeroing out free space..."
      $FilePath ="C:\zero.tmp"
      $Volume = Get-Volume -DriveLetter C
      $ArraySize = 1MB
      $SpaceToLeave = $Volume.Size * 0.005
      $FileSize = $Volume.SizeRemaining - $SpacetoLeave
      $ZeroArray = New-Object byte[]($ArraySize)

      $Stream= [io.File]::OpenWrite($FilePath)
      try {
        $CurFileSize = 0
        while ($CurFileSize -lt $FileSize) {
          $Stream.Write($ZeroArray, 0, $ZeroArray.Length)
          $CurFileSize += $ZeroArray.Length
        }
      }
      finally {
        if ($Stream) {
          $Stream.Close()
        }
      }
      Remove-Item $FilePath

      defrag C: /O /H /V

      Write-Host "Setting PageFile to clear at Shutdown..."
      Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" `
        -Name "ClearPageFileAtShutdown" -Value 1
      EOF
    ]
  }
}
