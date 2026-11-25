terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

provider "google" {
  project      = "lab-project"
  region       = "us-central1"
  zone         = "us-central1-a"
  access_token = "dummy-token"

  compute_custom_endpoint = "http://localhost:8443/compute/v1/"
}

resource "google_compute_network" "vpc" {
  name                    = "lab-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name          = "lab-subnet"
  network       = google_compute_network.vpc.id
  region        = "us-central1"
  ip_cidr_range = "10.10.0.0/24"
}

resource "google_compute_firewall" "allow_ssh_iap" {
  name    = "lab-allow-ssh-iap"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}
