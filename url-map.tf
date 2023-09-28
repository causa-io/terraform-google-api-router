locals {
  default_url_redirect = coalesce(var.default_url_redirect, {
    host          = var.domain_name
    path          = "/"
    response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query   = true
  })
}

# The URL map, pointing to the correct backend based on the path.
resource "google_compute_url_map" "api" {
  project = var.gcp_project_id
  name    = var.name

  default_url_redirect {
    host_redirect          = local.default_url_redirect.host
    path_redirect          = local.default_url_redirect.path
    redirect_response_code = local.default_url_redirect.response_code
    strip_query            = local.default_url_redirect.strip_query
  }

  host_rule {
    hosts        = [var.domain_name]
    path_matcher = "api"
  }

  path_matcher {
    name = "api"

    default_url_redirect {
      host_redirect          = local.default_url_redirect.host
      path_redirect          = local.default_url_redirect.path
      redirect_response_code = local.default_url_redirect.response_code
      strip_query            = local.default_url_redirect.strip_query
    }

    dynamic "path_rule" {
      for_each = local.cloud_run_path_rules
      iterator = rule

      content {
        # Paths are expected not to be suffixed by `/`, such that a service mapped for `/endpoint` receives requests for
        # both `/endpoint` and `/endpoint/abc`.
        paths   = flatten([for p in rule.value.paths : [p, "${p}/*"]])
        service = rule.value.service
      }
    }
  }
}
