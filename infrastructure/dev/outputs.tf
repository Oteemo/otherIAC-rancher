#Added AMI output
output "AMI_image" {
  description = "AMI image name "
  value       = data.aws_ami.latest_patched_ami.id
}

output "ssm_start_session_command_agents" {
  description = "AWS CLI commands to start SSM sessions for rke2 agents"
  value       = module.rke2.ssm_start_session_command_agents
}

output "ssm_start_session_command_server" {
  description = "AWS CLI command to start SSM session for rke2 server"
  value       = module.rke2.ssm_start_session_command_server
}

output "ssm_start_session_other_server" {
  description = "AWS CLI command to start SSM session for rke2 server"
  value       = module.rke2.ssm_start_session_other_server
}