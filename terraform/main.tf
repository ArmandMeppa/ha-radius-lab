terraform {
  required_providers {
    multipass = {
      source  = "todoroff/multipass"
      version = ">= 1.0.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "multipass" {}

resource "multipass_instance" "k3s" {
  name   = var.vm_name
  image  = "22.04"
  cpus   = var.cpus
  memory = var.memory
  disk   = var.disk
}