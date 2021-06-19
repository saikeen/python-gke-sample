locals {
  env_resource_prefix = "${var.app_name}-${var.env}"
}

resource "google_container_cluster" "primary" {
  name     = "${local.env_resource_prefix}-cluster"
  location = var.location

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.vpc_id
  subnetwork = var.subnet_id

  ip_allocation_policy {
    cluster_secondary_range_name  = "services-range"
    services_secondary_range_name = var.subnet_range_name
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "${local.env_resource_prefix}-node-pool"
  location   = var.location
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    service_account = var.gke_node_pool_sa_email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
