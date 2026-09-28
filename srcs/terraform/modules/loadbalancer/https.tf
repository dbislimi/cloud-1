resource "tls_private_key" "rsa-4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "tls_self" {
  private_key_pem = tls_private_key.rsa-4096.private_key_pem

  subject {
    common_name  = var.domain_name
    organization = "Dr.bis, Corp"
  }

  validity_period_hours = 1000

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "google_compute_ssl_certificate" "default" {
  name_prefix = "${var.gcp_project_id}-certificate-"
  description = "a description"
  private_key = tls_private_key.rsa-4096.private_key_pem
  certificate = tls_self_signed_cert.tls_self.cert_pem

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_url_map" "web_map" {
  name            = "${var.gcp_project_id}-web-map"
  default_service = google_compute_backend_service.web_backend.id
}

resource "google_compute_target_https_proxy" "https_web_proxy" {
  name             = "${var.gcp_project_id}-web-proxy"
  url_map          = google_compute_url_map.web_map.id
  ssl_certificates = [google_compute_ssl_certificate.default.id]
}

resource "google_compute_global_forwarding_rule" "https_rule" {
  name                  = "${var.gcp_project_id}-https-rule"
  target                = google_compute_target_https_proxy.https_web_proxy.id
  port_range            = "443"
  ip_address            = google_compute_global_address.lb_public_ip.id
  load_balancing_scheme = "EXTERNAL"
}
