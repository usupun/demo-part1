terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.14.1"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "tf_state" {
  name          = "${var.project_id}-tf-state"
  location      = var.region
  storage_class = "STANDARD"

  versioning {
    enabled = true
  }
}

resource "google_compute_network" "vpc" {
  name = "gke-vpc"
}

resource "google_compute_subnetwork" "subnet" {
  count                  = length(var.subnet_ranges)
  name                   = "subnet-${count.index}"
  ip_cidr_range          = var.subnet_ranges[count.index]
  region                 = var.region
  network                = google_compute_network.vpc.self_link
}

resource "google_container_cluster" "gke_cluster" {
  name     = "gke-cluster"
  location = var.region

  network    = google_compute_network.vpc.self_link
  subnetwork = google_compute_subnetwork.subnet[0].self_link

  remove_default_node_pool = true

  initial_node_count = 1

  node_pool {
    name       = "general-pool"
    node_count = var.general_pool_node_count

    node_config {
      machine_type = var.general_pool_machine_type
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform",
      ]
    }
  }

  node_pool {
    name       = "cpu-intensive-pool"
    node_count = var.cpu_pool_node_count

    node_config {
      machine_type = var.cpu_pool_machine_type
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform",
      ]
    }
  }
}

terraform {
  backend "gcs" {
    bucket  = google_storage_bucket.tf_state.name
    prefix  = "terraform/state"
  }
}