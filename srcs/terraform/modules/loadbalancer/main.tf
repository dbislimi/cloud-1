resource "google_compute_global_address" "lb_public_ip" {
  name = "${var.gcp_project_id}-lb-public-ip"
}

resource "google_compute_instance_group" "web_group" {
  name      = "${var.gcp_project_id}-web-group"
  zone      = var.web_server_zone
  instances = [var.web_server_id]

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_health_check" "http_hc" {
  name               = "${var.gcp_project_id}-http-hc"
  check_interval_sec = 5
  timeout_sec        = 5

  http_health_check {
    port = 80
	request_path = "/healthz"
  }
}

resource "google_compute_backend_service" "web_backend" {
  name                  = "${var.gcp_project_id}-web-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_health_check.http_hc.id]

  backend {
    group = google_compute_instance_group.web_group.id
  }
}

resource "google_compute_url_map" "web_map" {
  name            = "${var.gcp_project_id}-web-map"
  default_service = google_compute_backend_service.web_backend.id
}

resource "google_compute_target_http_proxy" "web_proxy" {
  name    = "${var.gcp_project_id}-web-proxy"
  url_map = google_compute_url_map.web_map.id
}

resource "google_compute_global_forwarding_rule" "http_rule" {
  name                  = "${var.gcp_project_id}-http-rule"
  target                = google_compute_target_http_proxy.web_proxy.id
  port_range            = "80"
  ip_address            = google_compute_global_address.lb_public_ip.id
  load_balancing_scheme = "EXTERNAL"
}