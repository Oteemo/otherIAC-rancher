terraform {

  required_version = ">= 1.8.0"       #field for tf version.  minimum

  #Different fields and requirements for providers
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.16.0"
    }
    kubectl = {
      source  = "alon-dotan-starkware/kubectl"
      version = "1.11.2"
    }
  }
}

resource "aws_lb" "curiosity" {
  client_keep_alive                                            = 3600
  customer_owned_ipv4_pool                                     = null
  desync_mitigation_mode                                       = "defensive"
  drop_invalid_header_fields                                   = false
  enable_cross_zone_load_balancing                             = true
  enable_deletion_protection                                   = false
  enable_http2                                                 = true
  enable_tls_version_and_cipher_suite_headers                  = false
  enable_waf_fail_open                                         = false
  enable_xff_client_port                                       = false
  enforce_security_group_inbound_rules_on_private_link_traffic = null
  idle_timeout                                                 = 60
  internal                                                     = true
  ip_address_type                                              = "ipv4"
  load_balancer_type                                           = "application"
  name                                                         = "curiosity"
  name_prefix                                                  = null
  preserve_host_header                                         = false
  security_groups                                              = [ "sg-029a4d64282e8c252"]
  subnets                                                      = [ "subnet-0430ccd74062f252d", "subnet-00c239cfa0a160dfe"]
  tags                                                         = {
    "waf-type" = "internal-alb"
  }
  tags_all                                                     = {
    "waf-type" = "internal-alb"
  }

  xff_header_processing_mode                                   = "append"
}

resource "aws_lb_listener" "curiosity_https" {
  // This should be for the 'curiosity-dev.lib.harvard.edu' certificate.  BUT using k8-console cert
  certificate_arn   = "arn:aws:acm:us-east-1:086178843174:certificate/4391ddd8-6b34-48bf-aaf8-02be207355b9"
  load_balancer_arn = aws_lb.curiosity.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  tags              = {}
  tags_all          = {}

  default_action {
    order            = 1
    //target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:217428790895:targetgroup/Curiosity-dev-K8S/2458ce9f859596b3"
    target_group_arn = aws_lb_target_group.curiosity-k8.arn
    type             = "forward"
  }

  mutual_authentication {
    ignore_client_certificate_expiry = false
    mode                             = "off"
    trust_store_arn                  = null
  }
}

resource "aws_lb_target_group" "curiosity-k8" {
  deregistration_delay              = "300"
  ip_address_type                   = "ipv4"
  load_balancing_algorithm_type     = "round_robin"
  load_balancing_anomaly_mitigation = "off"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  name                              = "curiosity-sand-k8"
  name_prefix                       = null
  port                              = 32001
  protocol                          = "HTTPS"
  protocol_version                  = "HTTP1"
  slow_start                        = 0
  tags                              = {
    "Name" = "Curiosity dev K8S"
  }
  tags_all                          = {
    "Name" = "Curiosity dev K8S"
  }
  target_type                       = "ip"
  vpc_id                            = "vpc-0d1a887bbc1aef59d"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 10
    matcher             = "200,404"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTPS"
    timeout             = 5
    unhealthy_threshold = 2
  }

  stickiness {
    cookie_duration = 86400
    cookie_name     = null
    enabled         = false
    type            = "lb_cookie"
  }

}

resource "aws_lb_target_group_attachment" "front_end_https" {
  # TODO :  Add ingress variables
  for_each            = toset(["10.140.210.69", "10.140.210.6", "10.140.210.7"])
  target_group_arn    = aws_lb_target_group.curiosity-k8.arn
  target_id           = each.value
}