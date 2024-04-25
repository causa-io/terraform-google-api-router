# Terraform module for Google Cloud Load Balancing

This module manages Cloud Load Balancing resources to expose several services as a unified API on a single domain name. This module is meant to integrate with other Causa Terraform modules for GCP. It can for example be used to expose several [Cloud Run `serviceContainer`](https://github.com/causa-io/terraform-google-service-container-cloud-run) projects.

## ➕ Requirements

This module depends on the [google Terraform provider](https://registry.terraform.io/providers/hashicorp/google/latest).

## 🎉 Installation

Copy the following in your Terraform configuration, and run `terraform init`:

```terraform
module "my_api_router" {
  source  = "causa-io/api-router/google"
  version = "<insert the most recent version number here>"

  ip_address  = google_compute_global_address.api.id
  domain_name = "example.com"

  services = {
    service1 = {
      paths   = ["/abc", "/def"]
      type    = "google.cloudRun"
      region  = "europe-west1"
      service = "my-cloud-run-service"
    }
  }
}
```

## ✨ Features

### Cloud Run services

The only type of services that can be exposed for now is Cloud Run services:

```terraform
module "my_api_router" {
  services = {
    service1 = {
      # Matches `/abc`, `/def`, but also `/abc/suffix`.
      paths   = ["/abc", "/def"]

      type    = "google.cloudRun"

      # The region / location where the Cloud Run service is deployed.
      region  = "europe-west1"

      # The name of the Cloud Run service.
      service = "my-cloud-run-service"

      # A list of custom headers added by the Google Front End to all incoming requests.
      # See https://cloud.google.com/load-balancing/docs/https/custom-headers.
      custom_request_headers = [
        "X-My-Header:{client_protocol}",
      ]
    }
  }
}
```

### HTTP to HTTPS redirect

By default, HTTP requests on port 80 will be redirected to HTTPS. This can be disabled by setting to `false` the `https_redirect` variable.

### Custom SSL policy

The `ssl_policy` variable can be set to a `google_compute_ssl_policy` resource ID to define the SSL policy for the HTTPS proxy.

### Request logging

By default, all requests to backend services are logged, which can generate an undesirable amount of logs and costs. This can be adjusted by setting the `backend_log_sample_rate` variable. (Setting it to `0` completely disables logs.)

### Default URL redirection

When a request does not match any rule, the default behavior is to redirect it to the root of the `domain_name`. This can be changed by setting the `default_url_redirect` variable.
