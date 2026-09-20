terraform {
  required_version = "1.15.8"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.40.0"
    }
  }
  backend "gcs" {
    bucket = "cloud1-tfstate-dren42"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}
