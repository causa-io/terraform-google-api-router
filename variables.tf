variable "ip_address" {
  type        = string
  description = "The IP address for which the router is set up. This can be a resource URL or the address itself."
}

variable "domain_name" {
  type        = string
  description = "The domain name under which the API is served."
}

variable "name" {
  type        = string
  default     = "api"
  description = "A name for the router, used to name GCP resources. Defaults to `api`."
}

variable "services" {
  type = map(object({
    # The list of URL paths (prefixes) to route to the service.
    # `/abc` will match both `/abc` and `/abc/def`.
    paths = list(string)

    # The type of service being exposed. Only `google.cloudRun` for now.
    type = string

    # Cloud Run specific.
    # The region in which the Cloud Run service is located.
    region = optional(string)
    # The name of the Cloud Run service to expose.
    service = optional(string)
  }))
  description = "A map where values define the services exposed by the router."
}

variable "ssl_policy" {
  type        = string
  default     = null
  description = "An optional SSL policy to set for the API router. This should be the ID of a `google_compute_ssl_policy`."
}

variable "https_redirect" {
  type        = bool
  default     = true
  description = "Whether to redirect HTTP traffic to HTTPS. Defaults to `true`."
}

variable "gcp_project_id" {
  type        = string
  description = "The GCP project ID in which resources will be placed. Defaults to provider project."
  default     = null
}

variable "backend_log_sample_rate" {
  type        = number
  description = "The log sampling rate for backend services. Defaults to `1`."
  default     = 1
}

variable "default_url_redirect" {
  type = object({
    host          = string
    path          = string
    response_code = string
    strip_query   = bool
  })
  default     = null
  description = "An object describing how requests that do not match any rule should be redirected. Defaults to the root of the domain."
}
