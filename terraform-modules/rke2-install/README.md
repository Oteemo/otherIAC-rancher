<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.s3_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.s3_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.s3_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.rke2_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.rke2_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_key_pair.quickstart_key_pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_s3_bucket.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_security_group.allow_vpn_ingress_to_rke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [local_file.ssh_public_key_openssh](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_sensitive_file.ssh_private_key_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [tls_private_key.global_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [template_file.user_data](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agent_private_ips"></a> [agent\_private\_ips](#input\_agent\_private\_ips) | ip address of the agent (the instance would pick from the list based on the current index of the array) | `list(string)` | n/a | yes |
| <a name="input_ami_filter_name"></a> [ami\_filter\_name](#input\_ami\_filter\_name) | Name filter for the AWS AMI | `string` | n/a | yes |
| <a name="input_ami_filter_virtualization_type"></a> [ami\_filter\_virtualization\_type](#input\_ami\_filter\_virtualization\_type) | Virtualization type filter for the AWS AMI | `string` | n/a | yes |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | hostname of the rancher ui | `string` | n/a | yes |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of RKE2 agent instances to create | `number` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type | `string` | n/a | yes |
| <a name="input_key_pair_name_prefix"></a> [key\_pair\_name\_prefix](#input\_key\_pair\_name\_prefix) | Prefix for the key pair name | `string` | n/a | yes |
| <a name="input_node_agent_subnet_id"></a> [node\_agent\_subnet\_id](#input\_node\_agent\_subnet\_id) | subnet id to deploy the server | `string` | n/a | yes |
| <a name="input_rsa_bits"></a> [rsa\_bits](#input\_rsa\_bits) | Number of bits for RSA key generation | `number` | n/a | yes |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Name of the S3 bucket | `string` | n/a | yes |
| <a name="input_server_private_ip"></a> [server\_private\_ip](#input\_server\_private\_ip) | ip address of the server | `string` | n/a | yes |
| <a name="input_server_subnet_id"></a> [server\_subnet\_id](#input\_server\_subnet\_id) | subnet id to deploy the server | `string` | n/a | yes |
| <a name="input_userdata_agent_template_file"></a> [userdata\_agent\_template\_file](#input\_userdata\_agent\_template\_file) | Path to the userdata\_agent.sh template file | `string` | n/a | yes |
| <a name="input_userdata_server_template_file"></a> [userdata\_server\_template\_file](#input\_userdata\_server\_template\_file) | Path to the userdata\_server.sh template file | `string` | n/a | yes |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | Size of the EBS volume in GB | `number` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rancher_server_public_dns"></a> [rancher\_server\_public\_dns](#output\_rancher\_server\_public\_dns) | Public DNS of the Rancher server |
| <a name="output_rke2_agent_ssh_commands"></a> [rke2\_agent\_ssh\_commands](#output\_rke2\_agent\_ssh\_commands) | SSH commands to connect to the RKE2 agent instances |
| <a name="output_rke2_server_ssh_command"></a> [rke2\_server\_ssh\_command](#output\_rke2\_server\_ssh\_command) | SSH command to connect to the RKE2 server instance |
<!-- END_TF_DOCS -->