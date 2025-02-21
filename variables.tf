
# Variables with default values
variable "billing_account_id" {
  type = string
}

variable "create_project" {
  type = bool
  default = true
}
variable "image" {
  type    = string
  default = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts"
}

variable "enable_lb" {
  type    = bool
  default = true
}

variable "enable_nat" {
  type    = bool
  default = true
}

variable "enable_oslogin" {
  type    = bool
  default = true
}
variable "enable_oslogin_2fa" {
  type    = bool
  default = true
}

variable "folder_id" {
  description = "The folder ID where the project will be created"
  type        = string
}

variable "gcp_service_list" {
  type = list(string)
  default = [
    "compute.googleapis.com",
    "monitoring.googleapis.com"
  ]
}

variable "instance_name" {
  type    = string
  default = "grafana"
}

variable "instance_type" {
  type    = string
  default = "e2-micro"
}

variable "network" {
  type = string
}

variable "org_id" {
  type = string
}

variable "project_id" {
  description = "The unique ID of the project to be created"
  type        = string
}

variable "project_name" {
  description = "The name of the project to be created"
  type        = string
}

variable "region" {
  type    = string
  default = "europe-west1"
}

variable "subnet" {
  type = string
}

variable "subnet_cidr" {
  type    = string
  default = "10.10.10/24"
}

variable "zone_letter" {
  type    = string
  default = "b"
}