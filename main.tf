terraform {
  backend "gcs" {
    bucket = "terraform-state-a7s6d"
    prefix = "terraform/state/testing"
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

provider "google" {
    project = "dark-axe-359021"
}

resource "google_compute_network" "custom-test" {
  name                    = "test-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  name          = "test-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.custom-test.id
  secondary_ip_range {
    range_name    = "tf-test-secondary-range-update1"
    ip_cidr_range = "192.168.10.0/24"
  }
}
