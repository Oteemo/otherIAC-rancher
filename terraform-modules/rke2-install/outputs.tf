
output "rancher_server_public_dns" {
  value       = aws_instance.rke2_server.public_dns
  description = "Public DNS of the Rancher server"
}


output "ssm_start_session_command_server" {
  description = "AWS CLI command to start SSM session for rke2 server"
  value       = "aws ssm start-session --target ${aws_instance.rke2_server.id}"
}

output "ssm_start_session_command_agents" {
  description = "AWS CLI commands to start SSM sessions for rke2 agents"
  value       = [for id in aws_instance.rke2_agent[*].id : "aws ssm start-session --target ${id}"]
}
