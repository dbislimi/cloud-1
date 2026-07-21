resource "google_compute_network" "vpc_network" {
  name = "cloud1-network-01"
}

resource "google_compute_firewall" "allow_external" {
  name    = "cloud1-allow-external"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}

resource "google_compute_firewall" "allow_internal" {
  name    = "cloud1-allow-internal"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "3306"]
  }

  source_tags = ["web"]
  target_tags = ["db"]
}