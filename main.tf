# The SSL certificate for HTTPS traffic to the API.
resource "google_compute_managed_ssl_certificate" "api" {
  project = var.gcp_project_id
  name    = var.name

  managed {
    domains = [var.domain_name]
  }
}

# The HTTPS proxy, terminating TLS traffic and forwarding it to the URL map.
resource "google_compute_target_https_proxy" "api" {
  project          = var.gcp_project_id
  name             = var.name
  url_map          = google_compute_url_map.api.id
  ssl_certificates = [google_compute_managed_ssl_certificate.api.id]
  ssl_policy       = var.ssl_policy
}

# The forwarding rule (load balancer) for HTTPS traffic.
resource "google_compute_global_forwarding_rule" "api_load_balancer" {
  project               = var.gcp_project_id
  name                  = var.name
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_target_https_proxy.api.id
  ip_address            = var.ip_address
}
