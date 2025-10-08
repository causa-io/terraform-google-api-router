locals {
  cloud_run_services = {
    for name, definition in var.services :
    name => definition
    if definition.type == "google.cloudRun" && length(definition.paths) > 0
  }

  cloud_run_path_rules = {
    for name, backend_service in google_compute_backend_service.cloud_run_service :
    name => {
      paths   = local.cloud_run_services[name].paths
      service = backend_service.id
    }
  }
}

# The serverless NEG for each Cloud Run service.
resource "google_compute_region_network_endpoint_group" "cloud_run_service" {
  for_each = local.cloud_run_services

  project               = var.gcp_project_id
  name                  = "run-${each.key}"
  network_endpoint_type = "SERVERLESS"
  region                = each.value.region

  cloud_run {
    service = each.value.service
  }
}

# The backend services referenced by the URL map.
# Each one simply points to the corresponding serverless NEG.
resource "google_compute_backend_service" "cloud_run_service" {
  for_each = google_compute_region_network_endpoint_group.cloud_run_service

  project               = var.gcp_project_id
  name                  = "run-${each.key}"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  # Although optional, not explicitly disabling the Identity-Aware Proxy can cause unnecessary diffs in Terraform plans.
  # https://github.com/hashicorp/terraform-provider-google/issues/19273
  iap {
    enabled = false
  }

  custom_request_headers = try(local.cloud_run_services[each.key].custom_request_headers, [])

  backend {
    group = each.value.id
  }

  log_config {
    enable      = var.backend_log_sample_rate > 0
    sample_rate = var.backend_log_sample_rate
  }
}
