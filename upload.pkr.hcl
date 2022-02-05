variable "cm" {
  type    = string
  default = "salt"
}

variable "cm_version" {
  type    = string
  default = ""
}
variable "prefix" {
  type    = string
  default = "test-"
}

variable "version" {
  type    = string
  default = "0.0.1pre"
}

source "null" "upload" {
  communicator = "none"
}

build {
  name = "upload"

  source "null.upload" {
    name    = "win81"
  }

  source "null.upload" {
    name    = "win10"
  }
 
  post-processors {
    post-processor "artifice" {
      files = [ "box/virtualbox-vm/${source.name}x64-pro-${var.cm}${var.cm_version}.box" ]
    }

    post-processor "vagrant-cloud" {
      box_tag = "techneg/${var.prefix}${source.name}x64-pro-${var.cm}"
      version = "${var.version}"
      no_release = true
    }
  }
}
