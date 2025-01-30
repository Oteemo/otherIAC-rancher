# data "aws_lb" "existing_lb" {
#   name  = var.lb_name
# }
# 
# data "aws_route53_zone" "selected" {
#   name        = var.domain_name
# }

data "aws_lb_hosted_zone_id" "main" {}

resource "aws_route53_record" "istio_alias" { 
	name            = var.alias_name                 # Your desired DNS record name
	type            = "A"
	zone_id         = var.zone_id
 
    allow_overwrite = true          #New attribute after 1.5.0
	  alias { 
		#name                   = data.aws_lb.existing_lb.dns_name  # Istio load balancer's DNS name or endpoint 
		name                   = var.aws_route53_record   # Istio load balancer's DNS name or endpoint 
        zone_id                = data.aws_lb_hosted_zone_id.main.id  #lb zone ID not the route53 zone id. Z35SXDOTRQ7X7K
		evaluate_target_health = false      # Set to true if you want Route 53 to evaluate target health 
		} 
}