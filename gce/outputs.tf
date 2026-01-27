# Outputs for GCE resources

output "instance_name" {
  value = var.create_linux_vm ? google_compute_instance.minimal_vm[0].name : null
}

output "instance_self_link" {
  value = var.create_linux_vm ? google_compute_instance.minimal_vm[0].self_link : null
}

output "private_ip" {
  value = var.create_linux_vm ? google_compute_instance.minimal_vm[0].network_interface[0].network_ip : null
}

output "windows_private_ip" {
  value = var.create_windows_vm ? google_compute_instance.windows_vm[0].network_interface[0].network_ip : null
}
