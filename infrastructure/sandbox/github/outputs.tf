#Added AMI output
output "AMI_image" {
  description = "AMI image name "
  value       = data.aws_ami.latest_patched_ami.id
}

output "ssm_start_session_command_server" {
  description = "AWS CLI command to start SSM session for rke2 server"
  value       = module.github_runner_rhel.ssm_start_session_command_server
}