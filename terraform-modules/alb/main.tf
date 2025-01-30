
resource "aws_lb" "alb" {
  name                       = var.lb_name
  internal                   = var.internal
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = var.alb_subnet_id
  enable_deletion_protection = false
  idle_timeout               = 120
 
  #tags = merge(var.additional_tags, {Name = "LTS load balancer"}, {environment = "Development"},)
  tags = var.additional_tags
  lifecycle {
  ignore_changes = [
  tags["waf-type"],
  ]
  }
}

resource "aws_lb_listener" "front_end_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.front_end_http.arn
#   }
  default_action {
    type = "redirect"
    target_group_arn = aws_lb_target_group.front_end_http.arn

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "front_end_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn           #Default cert for listener, additional added later. 

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end_https.arn
  }

}

resource "aws_lb_target_group" "front_end_http" {
  name     = var.target_group_name
  port     = var.target_group_port
  protocol = var.listener_protocol
  vpc_id   = var.alb_vpc_id
  target_type = "ip"
    health_check {
      enabled             = true
      interval            = var.health_check_interval
      timeout             = var.health_check_timeout
      path                = var.health_check_path
      port                = var.health_check_port
      protocol            = var.listener_protocol
      healthy_threshold   = var.healthy_threshold
      unhealthy_threshold = var.unhealthy_threshold
      matcher             = "200"
    }
  
}

resource "aws_lb_target_group" "front_end_https" {
  name     = var.target_group_name_https
  port     = var.target_group_port_https
  protocol = "HTTPS"
  vpc_id   = var.alb_vpc_id
  target_type = "ip"
  health_check {
    enabled             = true
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    path                = var.health_check_path
    port                = var.health_check_port
    protocol            = "HTTPS"
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    matcher             = "200,404"
  }

}

resource "aws_lb_listener_certificate" "https_additional_certs" {
  count           = length(var.additional_certs)
  listener_arn    = aws_lb_listener.front_end_https.arn
  certificate_arn = var.additional_certs[count.index]
}


resource "aws_lb_target_group_attachment" "front_end_attachment" {
  for_each            = toset(var.ingress_ip)
  target_group_arn    = aws_lb_target_group.front_end_http.arn
  target_id           = each.value
}

resource "aws_lb_target_group_attachment" "front_end_https" {
  for_each            = toset(var.ingress_ip)
  target_group_arn    = aws_lb_target_group.front_end_https.arn
  target_id           = each.value
}

resource "aws_security_group" "alb" {
  name        = var.security_group_name
  description = "Allow incoming traffic to ALB"
  vpc_id      = var.alb_vpc_id

  ingress {
    description = "Allow all inbound traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks =  var.allowed_subnets
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}