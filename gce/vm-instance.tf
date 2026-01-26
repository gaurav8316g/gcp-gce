resource "google_compute_instance" "minimal_vm" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10 # Minimal disk size
    }
  }

  network_interface {
    subnetwork         = var.subnet_name
    subnetwork_project = var.network_project_id

    # Removed access_config to comply with constraints/compute.vmExternalIpAccess
  }

  # Minimal cost: ensure it's preemptible/spot if acceptable, 
  # but e2-micro is already very cheap.
  scheduling {
    preemptible        = true
    automatic_restart  = false
    provisioning_model = "SPOT"
  }

  metadata = {
    foo = "bar"
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt update
    sudo apt install -y telnet
    sudo apt install -y nginx
    sudo systemctl enable nginx
    sudo chmod -R 755 /var/www/html
    HOSTNAME=$(hostname)
    sudo echo "<!DOCTYPE html> <html> <body style='background-color:rgb(250, 210, 210);'> <h1>Welcome to Client demo - WebVM App1 </h1> <p><strong>VM Hostname:</strong> $HOSTNAME</p> <p><strong>VM IP Address:</strong> $(hostname -I)</p> <p><strong>Application Version:</strong> V1</p> <p>Google Cloud Platform - Compute Demos</p> </body></html>" | sudo tee /var/www/html/index.html
  EOT

  labels = {
    environment = "dev"
    cost-center = "education"
  }
}
