
# TODO: get from infra variables
variable "istio_qpiprivate_lb_name" {
  type    = string
  default = "dev-istiolb-apiprivate"
}

variable "istio_private_lb_name" {
  type    = string
  default = "dev-istiolb-private"
}

# TODO: get from infra variables
variable "istio_public_lb_name" {
  type    = string
  default = "dev-istiolb"
}

# TODO: get from infra variables
variable "istio_server_lb_name" {
  type    = string
  default = "dev-istiolb-server"
}