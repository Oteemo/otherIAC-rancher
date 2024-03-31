
# TODO : Work out the depends for Kubernetes cluster to be available
terraform {

  required_providers {

    kubectl = {
      source  = "alon-dotan-starkware/kubectl"
      version = "1.11.2"
    }
  }
}

####  ESO Upgrade (LD179)
resource "helm_release" "eso_helm" {
  name             = "external-secrets"
  chart            = "external-secrets"
  create_namespace = "true"
  version          = var.eso_version
  namespace        = "external-secrets"
  repository       = "https://charts.external-secrets.io/"

  #  # TODO : Workout the depends
  # depends_on = data.kubernetes_cluster_name
}