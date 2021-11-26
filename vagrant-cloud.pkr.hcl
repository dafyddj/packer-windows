variable "cm" {
  type    = string
  default = "salt"
}

variable "cm_version" {
  type    = string
  default = ""
}

variable "version" {
  type    = string
  default = "0.1.0"
}

variable "vm_name" {
  type    = string
  default = "win81x64-pro"
}

source "null" "basic-example" {
  communicator = "none"
}

build {
  sources = ["sources.null.basic-example"]
 
  post-processor "artifice" {
    files = [ "box/virtualbox-iso/${var.vm_name}-${var.cm}${var.cm_version}-${var.version}.box" ]
  }
  
  post-processor "vagrant-cloud" {
    box_tag = "techneg/${var.vm_name}-${var.cm}"
    version = "${var.version}"
    no_release = true
  }
}
