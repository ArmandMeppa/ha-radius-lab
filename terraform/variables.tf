variable "vm_name" {
  description = "Name of the Multipass VM"
  type        = string
  default     = "k3s"
}

variable "cpus" {
  description = "Number of CPUs for the VM"
  type        = number
  default     = 4
}

variable "memory" {
  description = "RAM allocated to the VM"
  type        = string
  default     = "8G"
}

variable "disk" {
  description = "Disk size for the VM"
  type        = string
  default     = "40G"
}
