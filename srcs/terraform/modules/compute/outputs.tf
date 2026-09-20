output "web_server_id" {
  description = "Web server self_link"
  value       = google_compute_instance.web_server.self_link
}

output "web_server_zone" {
  description = "Web server zone"
  value       = google_compute_instance.web_server.zone
}

output "db_server_zone" {
  description = "Web server zone"
  value       = google_compute_instance.db_server.zone
}

output "web_private_ip" {
  description = "Web server internal IP"
  value       = google_compute_address.web_internal_ip.address
}

output "db_private_ip" {
  description = "Database internal IP"
  value       = google_compute_address.db_internal_ip.address
}

output "web_server_name" {
  description = "Web server name for IAP tunnel"
  value       = google_compute_instance.web_server.name
}

output "db_server_name" {
  description = "Database server name for IAP tunnel"
  value       = google_compute_instance.db_server.name
}