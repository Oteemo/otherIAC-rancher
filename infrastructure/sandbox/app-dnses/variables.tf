
# TODO: get from infra variables
variable "istio_private_lb_name" {
  type    = string
  default = "istiolb-private"
}

# TODO: get from infra variables
variable "istio_public_lb_name" {
  type    = string
  default = "istiolb"
}

# TODO: get from infra variables
variable "istio_server_lb_name" {
  type    = string
  default = "istiolb-server"
}