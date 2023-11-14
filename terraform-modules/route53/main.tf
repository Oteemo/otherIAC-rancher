data "aws_lb" "existing_lb" {
  name  = var.lb_name
}

data "aws_route53_zone" "selected" {
  name        = var.domain_name
}

resource "aws_route53_record" "istio_alias" { 
	name          = var.alias_name                 # Your desired DNS record name
	type          = "A"
	zone_id       = data.aws_route53_zone.selected.zone_id
 
  allow_overwrite = true          #New attribute after 1.5.0
	alias { 
		name        = data.aws_lb.existing_lb.dns_name     # Istio load balancer's DNS name or endpoint 
		zone_id     = var.zone_id
		evaluate_target_health = false                     # Set to true if you want Route 53 to evaluate target health 
		} 
}