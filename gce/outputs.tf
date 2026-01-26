# Outputs for GCE resources

output "instance_name" {
  value = google_compute_instance.minimal_vm.name
}

output "instance_self_link" {
  value = google_compute_instance.minimal_vm.self_link
}

output "private_ip" {
  value = google_compute_instance.minimal_vm.network_interface[0].network_ip
}
