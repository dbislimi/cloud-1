resource "google_compute_network" "vpc_network" {
  name                    = "${var.gcp_project_id}-network-01"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "db_subnet" {
  name          = "${var.gcp_project_id}-db-subnet-01"
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = "10.0.1.0/24"
  region        = var.gcp_region
}

resource "google_compute_subnetwork" "web_subnet" {
  name          = "${var.gcp_project_id}-web-subnet-01"
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = "10.0.2.0/24"
  region        = var.gcp_region
}

resource "google_compute_router" "router" {
  name    = "${var.gcp_project_id}-router-01"
  region  = var.gcp_region
  network = google_compute_network.vpc_network.id
}

resource "google_compute_address" "nat_static_ip" {
  name   = "${var.gcp_project_id}-nat-static-ip"
  region = var.gcp_region
}

resource "google_compute_router_nat" "nat" {
  name   = "${var.gcp_project_id}-nat"
  router = google_compute_router.router.name
  region = google_compute_router.router.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = [google_compute_address.nat_static_ip.self_link]

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.db_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
  subnetwork {
    name                    = google_compute_subnetwork.web_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

resource "google_compute_firewall" "allow_internal" {
  name    = "cloud1-allow-internal"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["3306", "2049"]
  }

  source_ranges = [google_compute_subnetwork.web_subnet.ip_cidr_range]
  target_tags   = ["db"]
}

resource "google_compute_firewall" "allow_ssh_iap" {
  name    = "${var.gcp_project_id}-allow-ssh-iap"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["web", "db"]
}

resource "google_compute_firewall" "allow_lb" {
  name    = "${var.gcp_project_id}-allow-lb"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["web"]
}