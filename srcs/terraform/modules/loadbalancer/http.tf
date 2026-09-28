resource "google_compute_url_map" "https_redirect" {
  name = "${var.gcp_project_id}-https-redirect-map"
  default_url_redirect {
    strip_query    = false
    https_redirect = true
  }
}

resource "google_compute_target_http_proxy" "http_web_proxy" {
  name    = "${var.gcp_project_id}-web-proxy"
  url_map = google_compute_url_map.https_redirect.id
}

resource "google_compute_global_forwarding_rule" "http_rule" {
  name                  = "${var.gcp_project_id}-http-rule"
  target                = google_compute_target_http_proxy.http_web_proxy.id
  port_range            = "80"
  ip_address            = google_compute_global_address.lb_public_ip.id
  load_balancing_scheme = "EXTERNAL"
}
