terraform {
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

resource "google_compute_address" "web_static_ip" {
  name   = "cloud1-web-static-ip"
  region = google_compute_subnetwork.web_subnet.region
}

resource "google_compute_instance" "web_server" {
  name           = "cloud1-web-01"
  machine_type   = "e2-micro"
  zone           = var.gcp_zones[1]
  desired_status = var.desired_status
  metadata = {
    ssh-keys = "${var.gcp_user}:${file(var.ssh_pub_path)}"
  }
  tags = ["web"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      type  = "pd-standard"
      size  = 10
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.web_subnet.id
    access_config {
      nat_ip = google_compute_address.web_static_ip.address
    }
  }
}

resource "google_compute_address" "db_internal_ip" {
  name         = "cloud1-db-internal-ip"
  address_type = "INTERNAL"
  region       = google_compute_subnetwork.db_subnet.region
  subnetwork   = google_compute_subnetwork.db_subnet.id
}

resource "google_compute_instance" "db_server" {
  name           = "cloud1-db-01"
  machine_type   = "e2-micro"
  zone           = var.gcp_zones[0]
  desired_status = var.desired_status
  metadata = {
    ssh-keys = "${var.gcp_user}:${file(var.ssh_pub_path)}"
  }
  tags = ["db"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      type  = "pd-standard"
      size  = 10
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.db_subnet.id
    network_ip = google_compute_address.db_internal_ip.address
  }

}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/hosts.ini"

  content = <<-EOT
			[web]
			${local.web_public_ip}

			[db]
			${local.db_private_ip}

			[all:vars]
			ansible_user=${var.gcp_user}
			ansible_ssh_private_key_file=${var.ssh_priv_path}
			
			[db:vars]
			ansible_ssh_common_args='-o ProxyJump=dren@${local.web_public_ip}'
		EOT

}