
# TODO : Work out the depends for Kubernetes cluster to be available
terraform {

  required_providers {

    kubectl = {
      source  = "alon-dotan-starkware/kubectl"
      version = "1.11.2"
    }
  }
}

###  SOLR (LD671)
resource "helm_release" "solr_operator_helm" {
  name       = "solr-operator"
  chart      = "solr-operator"
  create_namespace  = "true"
  timeout           = "600"
  version           = var.solr_operator_version
  namespace         = "solr-operator"
  repository        = "https://solr.apache.org/charts"
}

