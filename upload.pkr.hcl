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

variable "vm_name" {
  type    = string
  default = "win81x64-pro"
}

source "null" "upload" {
  communicator = "none"
}

build {
  sources = ["sources.null.upload"]
 
  post-processors {
    post-processor "artifice" {
      files = [ "box/virtualbox-vm/${var.vm_name}-${var.cm}${var.cm_version}.box" ]
    }

    post-processor "vagrant-cloud" {
      box_tag = "techneg/${var.prefix}${var.vm_name}-${var.cm}"
      version = "${var.version}"
      no_release = true
    }
  }
}
