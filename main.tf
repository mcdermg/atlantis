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
