<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route53_record.istio_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_lb_hosted_zone_id.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb_hosted_zone_id) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alias_name"></a> [alias\_name](#input\_alias\_name) | The name of the alias record | `string` | n/a | yes |
| <a name="input_aws_route53_record"></a> [aws\_route53\_record](#input\_aws\_route53\_record) | The DNS name of the alias record | `string` | n/a | yes |
| <a name="input_aws_route53_zone_name"></a> [aws\_route53\_zone\_name](#input\_aws\_route53\_zone\_name) | The name of the Route 53 hosted zone | `string` | n/a | yes |
| <a name="input_use_cname"></a> [use\_cname](#input\_use\_cname) | Determines whether to use CNAME record or A/AAAA record | `bool` | n/a | yes |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | zone id for the hosted zone.  Not managed by TF | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->