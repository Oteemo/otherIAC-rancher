terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.80.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_lb" "istio_private" {
  #  arn  = var.lb_arn
  name = var.istio_private_lb_name
}

data "aws_lb" "istio_public" {
  #  arn  = var.lb_arn
  name = var.istio_public_lb_name
}

data "aws_lb" "istio_server" {
  #  arn  = var.lb_arn
  name = var.istio_server_lb_name
}

output "istio_public_name" {
  description = "AWS ALB name "
  value       = data.aws_lb.istio_public.name
}

output "istio_server_name" {
  description = "AWS ALB name "
  value       = data.aws_lb.istio_server.name
}

# These are the APP DNSes in Route 53
module "route53_app_dns_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-sand.lib.harvard.edu"
  use_cname             = false
  alias_name            = "appdns-test"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z064914927D9U8MUM38IN"
}

# BOOKLABELER DNS
module "booklabeler_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-sand.lib.harvard.edu"
  use_cname             = false
  alias_name            = "booklabeler-sand"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z064914927D9U8MUM38IN"
}