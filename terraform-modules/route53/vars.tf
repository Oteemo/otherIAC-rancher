variable "alias_name" {
  description = "The name of the alias record"
  type        = string
}

variable "aws_route53_record" {
  description = "The DNS name of the alias record"
  type        = string
}
variable "aws_route53_zone_name" {
  description = "The name of the Route 53 hosted zone"
  type        = string
}

# variable "domain_name" {
#   description = "Domain name in AWS"
#   type        = string 
# }
# 
# variable "lb_name" {
#   description = "LB name for A name record"
#   type        = string   
# }

variable "use_cname" {
  description = "Determines whether to use CNAME record or A/AAAA record"
  type        = bool
}

variable "zone_id" {
  description = "zone id for the hosted zone.  Not managed by TF"
  type        = string
}
