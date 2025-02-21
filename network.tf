resource "google_compute_network" "network" {
  project                 = google_project.project.project_id
  name                    = var.network
  auto_create_subnetworks = false

  depends_on = [ time_sleep.wait_project_init ]
}

resource "google_compute_subnetwork" "subnet" {
  project       = google_project.project.project_id
  name          = var.subnet
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.network.id
}