variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
}

variable "gcp_user" {
  description = "SSH username"
  type        = string
}

variable "gcp_machine_types" {
  description = "Machine types list"
  type        = list(string)
}

variable "ssh_pub_path" {
  description = "SSH public key path"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_priv_path" {
  description = "SSH private key path"
  type        = string
  default     = "~/.ssh/id_rsa"
}