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
  name = "cloud1-web-static-ip"
}

resource "google_compute_instance" "web_server" {
  name           = "cloud1-web-01"
  machine_type   = "e2-micro"
  zone           = "us-east1-b"
  desired_status = var.desired_status
  metadata = {
    ssh-keys = "${var.gcp_user}:${file(var.ssh_pub_path)}"
  }
  tags = ["web"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      type  = "pd-standard"
      size  = 10
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      nat_ip = google_compute_address.web_static_ip.address
    }
  }
}

resource "google_compute_address" "db_internal_ip" {
  name         = "cloud1-db-internal-ip"
  address_type = "INTERNAL"
  region       = "us-east1"
  subnetwork      = google_compute_network.vpc_network.id
}

resource "google_compute_instance" "db_server" {
  name           = "cloud1-db-01"
  machine_type   = "e2-micro"
  zone           = "us-east1-c"
  desired_status = var.desired_status
  metadata = {
    ssh-keys = "${var.gcp_user}:${file(var.ssh_pub_path)}"
  }
  tags = ["db"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      type  = "pd-standard"
      size  = 10
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.name
    network_ip = google_compute_address.db_internal_ip.address
  }

}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"

  content = <<-EOT
			[web]
			${local.web_public_ip}

			[db]
			${local.db_private_ip}

			[all:vars]
			ansible_user=${var.gcp_user}
			ansible_ssh_private_key_file=${var.ssh_priv_path}
			ansible_ssh_common_args='-o StrictHostKeyChecking=no'
			
			[db:vars]
			ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyJump=dren@${local.web_public_ip}'
		EOT

}