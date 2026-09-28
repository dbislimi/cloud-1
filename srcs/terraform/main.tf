data "google_compute_zones" "available" {
  region = var.gcp_region
}

locals {
  gcp_zones = data.google_compute_zones.available.names
}

locals {
  web_hosts = [
    for s in module.compute.web_servers :
    "${s.name} private_ip=${s.network_interface[0].network_ip} gcp_zone=${s.zone}"
  ]
}

module "network" {
  source = "./modules/network"

  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region
}

module "compute" {
  source = "./modules/compute"

  web_count      = var.web_count
  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region
  web_subnet_id  = module.network.web_subnet_id
  db_subnet_id   = module.network.db_subnet_id

  gcp_zones         = local.gcp_zones
  gcp_machine_types = var.gcp_machine_types
  gcp_user          = var.gcp_user
  ssh_pub_path      = var.ssh_pub_path
  ssh_priv_path     = var.ssh_priv_path
  desired_status    = var.desired_status
}

module "loadbalancer" {
  source = "./modules/loadbalancer"

  gcp_project_id = var.gcp_project_id
  web_servers    = module.compute.web_servers
  domain_name    = var.domain_name
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/hosts.ini"

  content = <<-EOT
    [web]
    ${join("\n", local.web_hosts)}

    [db]
    ${module.compute.db_server_name} private_ip=${module.compute.db_private_ip} gcp_zone=${module.compute.db_server_zone}

    [web:vars]
    DOMAIN_NAME=${var.domain_name}

    [all:vars]
    ansible_user=${var.gcp_user}
    ansible_ssh_private_key_file=${var.ssh_priv_path}
    lb_public_ip=${module.loadbalancer.lb_public_ip}
    web_subnet_cidr=${module.network.web_subnet_cidr}
    web_db_host_pattern="${cidrhost(module.network.web_subnet_cidr, 0)}/${cidrnetmask(module.network.web_subnet_cidr)}"
    ansible_ssh_common_args='-o ProxyCommand="gcloud compute start-iap-tunnel %h %p --listen-on-stdin --project=${var.gcp_project_id} --zone={{ gcp_zone }}"'
  EOT
}