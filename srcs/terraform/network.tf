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
}

resource "google_compute_firewall" "allow_internal" {
  name    = "cloud1-allow-internal"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
  }

  source_ranges = ["10.0.0.0/8"]
}