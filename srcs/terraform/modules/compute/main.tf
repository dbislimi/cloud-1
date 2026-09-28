resource "google_compute_address" "web_internal_ip" {
  count        = var.web_count
  name         = format("%s-web-internal-ip-%02d", var.gcp_project_id, count.index + 1)
  address_type = "INTERNAL"
  region       = var.gcp_region
  subnetwork   = var.web_subnet_id
}

resource "google_compute_address" "db_internal_ip" {
  name         = "${var.gcp_project_id}-db-internal-ip"
  address_type = "INTERNAL"
  region       = var.gcp_region
  subnetwork   = var.db_subnet_id
}

resource "google_compute_instance" "web_server" {
  count          = var.web_count
  name           = format("%s-web-vm-%02d", var.gcp_project_id, count.index + 1)
  machine_type   = var.gcp_machine_types[0]
  zone           = var.gcp_zones[count.index % length(var.gcp_zones)]
  desired_status = var.desired_status
  tags           = ["web"]

  metadata = {
    ssh-keys = "${var.gcp_user}:${file(var.ssh_pub_path)}"
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      type  = "pd-standard"
      size  = 10
    }
  }

  network_interface {
    subnetwork = var.web_subnet_id
    network_ip = google_compute_address.web_internal_ip[count.index].address
  }
}

resource "google_compute_instance" "db_server" {
  name           = "${var.gcp_project_id}-db-vm-01"
  machine_type   = var.gcp_machine_types[0]
  zone           = var.gcp_zones[0]
  desired_status = var.desired_status
  tags           = ["db"]

  metadata = {
    ssh-keys = "${var.gcp_user}:${file(var.ssh_pub_path)}"
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      type  = "pd-standard"
      size  = 10
    }
  }

  network_interface {
    subnetwork = var.db_subnet_id
    network_ip = google_compute_address.db_internal_ip.address
  }

  lifecycle {
    ignore_changes = [attached_disk]
  }
}

resource "google_compute_disk" "db_disk" {
  name = "cloud1-db-disk-01"
  type = "pd-standard"
  zone = google_compute_instance.db_server.zone
  size = 10
}

resource "google_compute_attached_disk" "attach_db" {
  disk        = google_compute_disk.db_disk.id
  instance    = google_compute_instance.db_server.id
  device_name = "data-mariadb"
}

resource "google_compute_disk" "wp_disk" {
  name = "cloud1-wp-disk-01"
  type = "pd-standard"
  zone = google_compute_instance.db_server.zone
  size = 10
}

resource "google_compute_attached_disk" "attach_wp" {
  disk        = google_compute_disk.wp_disk.id
  instance    = google_compute_instance.db_server.id
  device_name = "data-wordpress"
}