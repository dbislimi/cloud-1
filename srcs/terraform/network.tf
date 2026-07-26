resource "google_compute_network" "vpc_network" {
  name                    = "cloud1-network-01"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "db_subnet" {
  name          = "cloud1-db-subnet-01"
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = "10.0.1.0/24"
  region        = var.gcp_region
}

resource "google_compute_subnetwork" "web_subnet" {
  name          = "cloud1-web-subnet-01"
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = "10.0.2.0/24"
  region        = var.gcp_region
}

resource "google_compute_router" "router" {
  name    = "cloud1-router-01"
  region  = google_compute_subnetwork.db_subnet.region
  network = google_compute_network.vpc_network.id
}

resource "google_compute_address" "nat_static_ip" {
  name   = "cloud1-nat-static-ip"
  region = google_compute_subnetwork.db_subnet.region

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_router_nat" "nat" {
  name   = "cloud1-nat"
  router = google_compute_router.router.name
  region = google_compute_router.router.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = [google_compute_address.nat_static_ip.self_link]

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.db_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
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

  source_ranges = [google_compute_subnetwork.web_subnet.ip_cidr_range]
  target_tags   = ["db"]
}