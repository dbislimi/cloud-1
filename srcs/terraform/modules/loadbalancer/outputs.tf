output "lb_public_ip" {
  description = "Load Balancer public IP"
  value       = google_compute_global_address.lb_public_ip.address
}