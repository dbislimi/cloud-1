data "google_compute_zones" "available" {
  region = var.gcp_region
}

locals {
  gcp_zones = data.google_compute_zones.available.names
}

module "network" {
  source = "./modules/network"

  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region
}

module "compute" {
  source = "./modules/compute"

  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region
  web_subnet_id  = module.network.web_subnet_id
  db_subnet_id   = module.network.db_subnet_id

  gcp_zones         = local.gcp_zones
  gcp_machine_types = var.gcp_machine_types
  gcp_user          = var.gcp_user
  ssh_pub_path      = var.ssh_pub_path
  ssh_priv_path     = var.ssh_priv_path
}

module "loadbalancer" {
  source = "./modules/loadbalancer"

  gcp_project_id  = var.gcp_project_id
  web_server_id   = module.compute.web_server_id
  web_server_zone = module.compute.web_server_zone
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/hosts.ini"

  content = <<-EOT
    [web]
    ${module.compute.web_server_name} private_ip=${module.compute.web_private_ip}

    [db]
    ${module.compute.db_server_name} private_ip=${module.compute.db_private_ip}

    [all:vars]
    ansible_user=${var.gcp_user}
    ansible_ssh_private_key_file=${var.ssh_priv_path}
    lb_public_ip=${module.loadbalancer.lb_public_ip}
    
    [web:vars]
    ansible_ssh_common_args='-o ProxyCommand="gcloud compute start-iap-tunnel %h %p --listen-on-stdin --project=${var.gcp_project_id} --zone=${module.compute.web_server_zone}"'

    [db:vars]
    ansible_ssh_common_args='-o ProxyCommand="gcloud compute start-iap-tunnel %h %p --listen-on-stdin --project=${var.gcp_project_id} --zone=${module.compute.db_server_zone}"'
  EOT
}