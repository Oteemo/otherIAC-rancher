output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.alb.dns_name
}

output "alb_security_group_id" {
  description = "The ID of the security group created for ALB"
  value       = aws_security_group.alb.id
}
