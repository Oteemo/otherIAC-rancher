
# TODO : Work out the depends for Kubernetes cluster to be available
terraform {

  required_providers {

    kubectl = {
      source  = "alon-dotan-starkware/kubectl"
      version = "1.11.2"
    }
  }
}

###  Jaeger
resource "helm_release" "jaeger_helm" {
  name       = "jaegertracing"
  chart      = "jaeger"
  create_namespace  = "true"
  version           = var.jaeger_version
  namespace         = "observability"
  repository        = "https://jaegertracing.github.io/helm-charts"

}

# TODO: Create VS later or add to argoCD-INFRA
# resource "kubectl_manifest" "jaeger_virtualport" {
#   yaml_body = <<YAML
#     apiVersion: networking.istio.io/v1
#     kind: VirtualService
#     metadata:
#       name: jaeger-vs
#       namespace: observability
#     spec:
#       gateways:
#         - istio-system/public-gateway
#       hosts:
#         - tracing-sand.lib.harvard.edu
#       http:
#         - match:
#             - uri:
#                 prefix: /
#           route:
#             - destination:
#                 host: jaeger
#                 port:
#                   number: 4000
# YAML
# }