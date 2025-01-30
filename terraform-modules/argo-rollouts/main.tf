
# TODO : Work out the depends for Kubernetes cluster to be available
terraform {

  required_providers {

    kubectl = {
      source  = "alon-dotan-starkware/kubectl"
      version = "1.11.2"
    }
  }
}

resource "helm_release" "argo_rollout_helm" {
  name       = "argo-rollouts"
  chart      = "argo-rollouts"
  create_namespace  = "true"
  version           = var.argo_rollout_version
  namespace         = "argo-rollout"
  repository        = "https://argoproj.github.io/argo-helm" # Pass version in if required
  values = [templatefile("${path.module}/values.yaml", {
  })]
}
