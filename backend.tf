terraform {
  backend "gcs" {
    bucket = "terraform-state-a7s6d"
    prefix = "terraform/state/testing"
  }
}
