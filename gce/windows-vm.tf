resource "google_compute_instance" "windows_vm" {
  count        = var.create_windows_vm ? 1 : 0
  name         = var.windows_instance_name
  machine_type = var.windows_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "windows-cloud/windows-2022"
      size  = 50 # Windows requires larger disk than Linux
    }
  }

  network_interface {
    subnetwork         = var.subnet_name
    subnetwork_project = var.network_project_id

    # No public IP to comply with org policy
  }

  scheduling {
    preemptible        = true
    automatic_restart  = false
    provisioning_model = "SPOT"
  }

  labels = {
    environment = "dev"
    os          = "windows"
  }
}
