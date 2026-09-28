resource "google_compute_global_address" "lb_public_ip" {
  name = "${var.gcp_project_id}-lb-public-ip"
}

locals {
  zones = toset([for s in var.web_servers : s.zone])
}

resource "google_compute_instance_group" "web_group" {
  for_each  = local.zones
  name      = "${var.gcp_project_id}-web-group-${each.key}"
  zone      = each.key
  instances = [for s in var.web_servers : s.self_link if s.zone == each.key]

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
    port         = 80
    request_path = "/healthz"
  }
}

resource "google_compute_backend_service" "web_backend" {
  name                  = "${var.gcp_project_id}-web-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_health_check.http_hc.id]

  # phpMyAdmin keeps its session inside each server's container: pin a browser
  # to one backend with a LB cookie (GCLB), otherwise logins fail half the time
  session_affinity = "GENERATED_COOKIE"

  dynamic "backend" {
    for_each = google_compute_instance_group.web_group
    content {
      group = backend.value.id
    }
  }
}
