
variable "alb_subnet_id" {
  description = "Subnet ID for ALB"
  type        = list(string)
}

variable "alb_vpc_id" {
  description = "VPC ID for ALB"
  type        = string
}

variable "certificate_arn" {
  description = "Certificate arn for ALB"
  type = string
}

variable "additional_certs" {
  description = "Secondary cert arns for ALB"
  type = list(string)
}

variable "health_check_interval" {
  description = "Health check interval"
  type        = number
  default     = 30
}

variable "health_check_path" {
  description = "health check path for ALB"
  type = string
  default = "/productpage"
}

variable "health_check_port" {
  description = "Health check port"
  type        = string
  default     = "31380"
}

variable "health_check_timeout" {
  description = "Health check timeout"
  type        = number
  default     = 5
}


variable "internal" {
  description = "Private or Public Balancer"
  type        = bool
  default     = false
}

variable "healthy_threshold" {
  description = "Healthy threshold"
  type        = number
  default     = 5
}

variable "ingress_ip" {
  description = "Ingress IP for ALB"
  type = list(string)
}

variable "allowed_subnets" {
  description = "Ingress IP for ALB"
  type = list(string)
}
 

variable "lb_name" {
  description = "Load balancer name"
  type        = string
  default     = "alb-huit"
}

variable "listener_port" {
  description = "Listener port"
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "Listener protocol"
  type        = string
  default     = "HTTP"
}

variable "security_group_name" {
  description = "Security group name for ALB"
  type        = string
  default     = "alb_sg"
}

variable "target_group_name" {
  description = "Target group name"
  type        = string
  default     = "istio-target-group"
}

variable "target_group_name_https" {
  description = "Target group name https"
  type        = string
  default     = "istio-target-group"
}

variable "target_group_port" {
  description = "Target group port"
  type        = number
  default     = 80
}


variable "target_group_port_https" {
  description = "Target group port" 
  type        = number
  default     = 32001
}

variable "unhealthy_threshold" {
  description = "Unhealthy threshold"
  type        = number
  default     = 2
}

variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}

variable "additional_ports" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}

variable "feedback_url" {
  description = "Feedback redirect URL"
  type        = string
  default     = "feedback_url"
}

variable "id_url" {
  description = "ID redirect URL"
  type        = string
  default     = "id_url"
}


