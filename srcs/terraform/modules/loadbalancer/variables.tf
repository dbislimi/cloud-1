variable "gcp_project_id" {
  description = "Unique Id of the Google Cloud project"
  type        = string
}

variable "web_servers" {
  description = "Web servers self_links and zones"
  type = list(object({
    self_link = string
    zone      = string
  }))
}

variable "domain_name" {
  type = string
}