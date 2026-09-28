output "load_balancer_ip" {
  description = "Public IP of the Load Balancer (Website URL)"
  value       = module.loadbalancer.lb_public_ip
}

output "web_private_ips" {
  description = "Internal IP of the Web Server"
  value       = module.compute.web_private_ips
}

output "db_private_ip" {
  description = "Internal IP of the Database"
  value       = module.compute.db_private_ip
}

output "nat_public_ip" {
  description = "Public IP of the NAT (for outbound traffic)"
  value       = module.network.nat_public_ip
}

output "domain_name" {
  value = var.domain_name
}