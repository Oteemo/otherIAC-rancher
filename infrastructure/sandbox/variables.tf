variable "istio_version" {
  description = "Istio version for Service Mesh "
  type        = string
}

variable "rancher_secret_name" {
  default = "sandbox1_rancher_secret_name"
}