
# Variables with default values
variable "project" {}
variable "region" {}
variable "zone" {}
variable "instance_type" {
  default = "e2-micro"
}
variable "image" {
  default = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts"
}
variable "instance_name" {
  default = "grafana"
}
variable "network" {}
variable "subnet" {}

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

variable "enable_lb" {
  type    = bool
  default = true
}

