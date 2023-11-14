
resource "aws_lb" "alb" {
  name                       = var.lb_name
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = var.alb_subnet_id
  enable_deletion_protection = false

  tags = {
    Name = "Customer load balancer"
  }
 lifecycle {
 ignore_changes = [
  tags["waf-type"],
  ]
 }

}

# group for HTTP
resource "aws_lb_listener" "front_end_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end_http.arn
  }

}

# group for HTTPS
resource "aws_lb_listener" "front_end_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn           #Discuss multiple certs referring to same LB

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
  port     = 32001
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
    matcher             = "200"
  }

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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["128.103.24.79/32","128.103.224.79/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
