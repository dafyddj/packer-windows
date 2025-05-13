variable "arch" {
  type    = string
  default = "x64"
}

variable "box_dir" {
  type    = string
  default = "../box/virtualbox"
}

variable "cm" {
  type    = string
  default = "nocm"
}

variable "cm_version" {
  type    = string
  default = ""
}

variable "no_release" {
  type    = bool
  default = true
}

variable "prefix" {
  type    = string
  default = "test-"
}

variable "vagrant_cloud_org" {
  type    = string
  default = "techneg"
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
    name    = "alpine318"
  }

  post-processors {
    post-processor "artifice" {
      files = [ "${var.box_dir}/${source.name}.box" ]
    }

    post-processor "vagrant-registry" {
      box_tag = "${var.vagrant_cloud_org}/${var.prefix}${source.name}-x64-${var.cm}"
      version = "${var.version}"
      no_release = var.no_release
    }
  }
}
