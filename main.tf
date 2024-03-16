# Define provider and authenticate with GCP
provider "google" {
  credentials = file("key.json")
  project     = "your-project-id"
  region      = "us-central1"
}

# Define variables
variable "instance_type" {
  description = "Machine type for the instances"
  default     = "f1-micro"
}

variable "master_name" {
  description = "Name for the K3s master node"
  default     = "k3s-master"
}

variable "worker_name" {
  description = "Name for the K3s worker node"
  default     = "k3s-worker"
}

# Create network
resource "google_compute_network" "network" {
  name = "k3s-network"
}

# Create firewall rule to allow ingress traffic
resource "google_compute_firewall" "firewall" {
  name    = "k3s-firewall"
  network = google_compute_network.network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "6443", "10250-10255"]
  }
}

# Create master instance
resource "google_compute_instance" "master" {
  name         = var.master_name
  machine_type = var.instance_type
  zone         = "us-central1-a"
  network_interface {
    network = google_compute_network.network.name
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    curl -sfL https://get.k3s.io | K3S_URL="https://server-ip:6443" K3S_TOKEN="your-token" sh -
  EOF
}

# Create worker instance
resource "google_compute_instance" "worker" {
  name         = var.worker_name
  machine_type = var.instance_type
  zone         = "us-central1-a"
  network_interface {
    network = google_compute_network.network.name
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    curl -sfL https://get.k3s.io | K3S_URL="https://server-ip:6443" K3S_TOKEN="your-token" sh -
  EOF
}
