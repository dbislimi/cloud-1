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
    }
  }
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
    network = google_compute_network.vpc_network.name
  }

}

resource "terraform_data" "ansible_inventory" {
  triggers_replace = [
    google_compute_instance.web_server.id,
    google_compute_instance.db_server.id
  ]

  provisioner "local-exec" {
    command = <<-EOT
			mkdir -p ${path.module}/../ansible &&
			cat <<EOF > ${path.module}/../ansible/inventory.ini
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

			EOF
		EOT
  }
}