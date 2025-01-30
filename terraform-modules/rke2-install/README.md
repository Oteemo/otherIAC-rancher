<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.agent_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.secrets_manager_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.server_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ssm_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.agent_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.server_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.agent_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.agent_ssm_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.s3_policy_attachment_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.s3_policy_attachment_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.secrets_manager_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.server_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.server_ssm_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.rke2_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.rke2_other_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.rke2_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_s3_bucket.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_versioning.versioning_example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_security_group.allow_vpn_ingress_to_rke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [random_integer.random_resource](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [template_file.other_data_server](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.user_data_agent](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.user_data_server](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agent_private_ips"></a> [agent\_private\_ips](#input\_agent\_private\_ips) | ip address of the agent (the instance would pick from the list based on the current index of the array) | `list(string)` | n/a | yes |
| <a name="input_alb_sg_id"></a> [alb\_sg\_id](#input\_alb\_sg\_id) | Security group ID for the ALB | `string` | n/a | yes |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | AMI ID for the instance | `string` | `""` | no |
| <a name="input_certmanager_version"></a> [certmanager\_version](#input\_certmanager\_version) | certmanager version | `string` | n/a | yes |
| <a name="input_efs_mount"></a> [efs\_mount](#input\_efs\_mount) | EFS Mount | `string` | n/a | yes |
| <a name="input_env_prefix"></a> [env\_prefix](#input\_env\_prefix) | Env prefix for EC2 instance | `string` | n/a | yes |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Tag for the environment deployment | `string` | n/a | yes |
| <a name="input_group_id1"></a> [group\_id1](#input\_group\_id1) | Group id for mount points | `string` | n/a | yes |
| <a name="input_group_id2"></a> [group\_id2](#input\_group\_id2) | Group id for mount points | `string` | n/a | yes |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | hostname of the rancher ui | `string` | n/a | yes |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of RKE2 agent instances to create | `number` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type | `string` | n/a | yes |
| <a name="input_istio_version"></a> [istio\_version](#input\_istio\_version) | Istio version for Service Mesh | `string` | n/a | yes |
| <a name="input_key_pair_name_prefix"></a> [key\_pair\_name\_prefix](#input\_key\_pair\_name\_prefix) | Prefix for the key pair name | `string` | n/a | yes |
| <a name="input_loadbalancer_subnets"></a> [loadbalancer\_subnets](#input\_loadbalancer\_subnets) | subnets per environment | `list` | n/a | yes |
| <a name="input_loki_version"></a> [loki\_version](#input\_loki\_version) | LOKI PLG stack version | `string` | n/a | yes |
| <a name="input_node_agent_subnet_id"></a> [node\_agent\_subnet\_id](#input\_node\_agent\_subnet\_id) | subnet id to deploy the server | `string` | n/a | yes |
| <a name="input_rancher_monitoring_version"></a> [rancher\_monitoring\_version](#input\_rancher\_monitoring\_version) | Rancher Monitoring version | `string` | n/a | yes |
| <a name="input_rancher_password"></a> [rancher\_password](#input\_rancher\_password) | Rancher password this is just placeholder for the password. The password will be called from teh module that created it so it is not exposed to the script | `string` | `""` | no |
| <a name="input_rancher_version"></a> [rancher\_version](#input\_rancher\_version) | Rancher version | `string` | n/a | yes |
| <a name="input_rke_version"></a> [rke\_version](#input\_rke\_version) | RKE version for server | `string` | `"v1.24"` | no |
| <a name="input_rsa_bits"></a> [rsa\_bits](#input\_rsa\_bits) | Number of bits for RSA key generation | `number` | n/a | yes |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Name of the S3 bucket | `string` | n/a | yes |
| <a name="input_server_instance_count"></a> [server\_instance\_count](#input\_server\_instance\_count) | Number of RKE2 server instances to create | `number` | n/a | yes |
| <a name="input_server_instance_type"></a> [server\_instance\_type](#input\_server\_instance\_type) | EC2 instance type | `string` | n/a | yes |
| <a name="input_server_other_ips"></a> [server\_other\_ips](#input\_server\_other\_ips) | ip address of the server | `list(string)` | n/a | yes |
| <a name="input_server_private_ip"></a> [server\_private\_ip](#input\_server\_private\_ip) | ip address of the server | `string` | n/a | yes |
| <a name="input_server_subnet_id"></a> [server\_subnet\_id](#input\_server\_subnet\_id) | subnet id to deploy the server | `string` | n/a | yes |
| <a name="input_tower_subnets"></a> [tower\_subnets](#input\_tower\_subnets) | subnets for Ansible Tower | `list` | n/a | yes |
| <a name="input_userdata_agent_template_file"></a> [userdata\_agent\_template\_file](#input\_userdata\_agent\_template\_file) | Path to the userdata\_agent.sh template file | `string` | n/a | yes |
| <a name="input_userdata_server_template_file"></a> [userdata\_server\_template\_file](#input\_userdata\_server\_template\_file) | Path to the userdata\_server.sh template file | `string` | n/a | yes |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | Size of the EBS volume in GB | `number` | n/a | yes |
| <a name="input_volume_type"></a> [volume\_type](#input\_volume\_type) | Type of the EBS volume in GB | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id for or per environment | `string` | n/a | yes |
| <a name="input_worker_subnets"></a> [worker\_subnets](#input\_worker\_subnets) | subnets per environment | `list` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rancher_server_public_dns"></a> [rancher\_server\_public\_dns](#output\_rancher\_server\_public\_dns) | Public DNS of the Rancher server |
| <a name="output_ssm_start_session_command_agents"></a> [ssm\_start\_session\_command\_agents](#output\_ssm\_start\_session\_command\_agents) | AWS CLI commands to start SSM sessions for rke2 agents |
| <a name="output_ssm_start_session_command_server"></a> [ssm\_start\_session\_command\_server](#output\_ssm\_start\_session\_command\_server) | AWS CLI command to start SSM session for rke2 server |
| <a name="output_ssm_start_session_other_server"></a> [ssm\_start\_session\_other\_server](#output\_ssm\_start\_session\_other\_server) | AWS CLI command to start SSM session for rke2 server |
<!-- END_TF_DOCS -->