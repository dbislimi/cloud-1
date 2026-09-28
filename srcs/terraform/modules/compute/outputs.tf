output "web_servers" {
  description = "Web server instances (self_link, zone, ...)"
  value       = google_compute_instance.web_server
}

output "db_server_zone" {
  description = "Web server zone"
  value       = google_compute_instance.db_server.zone
}

output "web_private_ips" {
  description = "Web servers internal IPs"
  type        = list(string)
  value       = google_compute_address.web_internal_ip[*].address
}

output "db_private_ip" {
  description = "Database internal IP"
  value       = google_compute_address.db_internal_ip.address
}

output "db_server_name" {
  description = "Database server name for IAP tunnel"
  value       = google_compute_instance.db_server.name
}