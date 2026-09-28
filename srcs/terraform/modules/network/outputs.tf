output "network_id" {
  description = "ID of the main VPC network"
  value       = google_compute_network.vpc_network.id
}

output "network_name" {
  description = "Name of the main VPC network"
  value       = google_compute_network.vpc_network.name
}

output "web_subnet_id" {
  description = "ID of web subnet"
  value       = google_compute_subnetwork.web_subnet.id
}

output "db_subnet_id" {
  description = "ID of db subnet"
  value       = google_compute_subnetwork.db_subnet.id
}

output "nat_public_ip" {
  description = "Public static ip for NAT network exit"
  value       = google_compute_address.nat_static_ip.address
}

output "web_subnet_cidr" {
  description = "CIDR range of web subnet"
  value       = google_compute_subnetwork.web_subnet.ip_cidr_range
}