
output "ssm_start_session_command_server" {
  description = "AWS CLI command to start SSM session for rke2 server"
  value       = "aws ssm start-session --target ${aws_instance.file_server.id}"
}

