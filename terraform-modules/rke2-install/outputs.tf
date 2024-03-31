#output "rke2_server_ssh_command" {
 # value       = "ssh -i ${local_sensitive_file.ssh_private_key_pem.filename} ubuntu@${aws_instance.rke2_server.public_ip}"
 # description = "SSH command to connect to the RKE2 server instance"
#}

#output "rke2_agent_ssh_commands" {
  #value = [
  #  for i in aws_instance.rke2_agent :
  #  "ssh -i ${local_sensitive_file.ssh_private_key_pem.filename} ubuntu@${i.public_ip}"
 # ]
  #description = "SSH commands to connect to the RKE2 agent instances"
#}

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

output "ssm_start_session_other_server" {
  description = "AWS CLI command to start SSM session for rke2 server"
  value       = [for id in aws_instance.rke2_other_server[*].id : "aws ssm start-session --target ${id}"]
}