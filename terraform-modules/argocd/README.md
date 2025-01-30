<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | 1.11.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | 1.11.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.argocd_helm](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubectl_manifest.argocd_nodeport](https://registry.terraform.io/providers/alon-dotan-starkware/kubectl/1.11.2/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argocd_version"></a> [argocd\_version](#input\_argocd\_version) | argoCD version | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->