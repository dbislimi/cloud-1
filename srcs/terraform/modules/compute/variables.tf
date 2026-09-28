variable "gcp_project_id" {
  description = "Unique Id of the Google Cloud project"
  type        = string
}

variable "gcp_region" {
  description = "Network computes region"
  type        = string
}

variable "web_subnet_id" {
  description = "Web subnet ID"
  type        = string
}

variable "db_subnet_id" {
  description = "Database subnet ID"
  type        = string
}

variable "gcp_zones" {
  description = "GCP zones list"
  type        = list(string)
}

variable "gcp_machine_types" {
  description = "GCP Machine types"
  type        = list(string)
}

variable "desired_status" {
  description = "Desired machine status"
  type        = string
  default     = "RUNNING"
}

variable "gcp_user" {
  description = "SSH username"
  type        = string
}

variable "ssh_pub_path" {
  description = "SSH public key path"
  type        = string
}

variable "ssh_priv_path" {
  description = "SSH private key path"
  type        = string
}

variable "web_count" {
  description = "Number of identical web servers behind the load balancer"
  type        = number
  default     = 1
}
