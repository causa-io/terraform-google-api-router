# This file contains all the resources to define a redirection from HTTP to HTTPS:
# - A forwarding rule for the 80 port (on the same IP address as the HTTPS API).
# - An HTTP proxy, pointing to the URL map.
# - A URL map with a single default redirect rule.

resource "google_compute_url_map" "https_redirect" {
  count = var.https_redirect ? 1 : 0

  project = var.gcp_project_id
  name    = "${var.name}-https-redirect"

  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }
}

resource "google_compute_target_http_proxy" "https_redirect" {
  count = var.https_redirect ? 1 : 0

  project = var.gcp_project_id
  name    = "${var.name}-https-redirect"
  url_map = google_compute_url_map.https_redirect[0].id
}

resource "google_compute_global_forwarding_rule" "api_load_balancer_https_redirect" {
  count = var.https_redirect ? 1 : 0

  project               = var.gcp_project_id
  name                  = "${var.name}-https-redirect"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.https_redirect[0].id
  ip_address            = var.ip_address
}
