variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "terraform_service_account" {
  description = "The service account to impersonate for Terraform operations"
  type        = string
}

variable "instance_name" {
  description = "The name of the GCE instance"
  type        = string
  default     = "minimal-linux-vm"
}

variable "machine_type" {
  description = "The machine type for the instance (e2-micro is cheapest)"
  type        = string
  default     = "e2-micro"
}

variable "network_project_id" {
  description = "The ID of the project that owns the shared VPC"
  type        = string
}

variable "subnet_name" {
  description = "The name of the shared subnet"
  type        = string
}
