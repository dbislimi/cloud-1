variable "desired_status" {
  type    = string
  default = "RUNNING"
  # to close: TERMINATED
}

variable "gcp_project" {
  type = string
}

variable "gcp_user" {
  type = string
}

variable "ssh_pub_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "ssh_priv_path" {
  type    = string
  default = "~/.ssh/id_rsa"
}

locals {
  web_public_ip  = google_compute_address.web_static_ip.address
  web_private_ip = google_compute_instance.web_server.network_interface[0].network_ip
  db_private_ip  = google_compute_address.db_internal_ip.address
}