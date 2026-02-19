output "vm_name" {
  value = multipass_instance.k3s.name
}

output "vm_ip" {
  value = multipass_instance.k3s.ipv4
}
