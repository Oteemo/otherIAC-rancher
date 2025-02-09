terraform {

  required_version = ">= 1.8.0"       #field for tf version.  minimum

  #Different fields and requirements for providers
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.16.0"
    }
    kubectl = {
      source  = "alon-dotan-starkware/kubectl"
      version = "1.11.2"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "3.2.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# TODO :  TO work out cluster dynamically
#provider "helm" {
#  kubernetes {
#    host                   = "cluster-console.dev.harvard.edu"
#    cluster_ca_certificate = base64decode(rke2_cluster.my_cluster.cluster_ca_certificate)
#    exec {
#      api_version = "client.authentication.k8s.io/v1beta1"
#      args        = ["eks", "get-token", "--cluster-name", "local"]
#      command     = "aws"
#    }
#  }
#}

## TODO :  TO work out cluster dynamically
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "dev"
  }
}

#Modularise in case for future dependencies
module "argocd" {
  #argocd_version      = "7.6.12"
  argocd_version      = "7.7.10"      # New argoCD - check OIDC
  source              = "../../../terraform-modules/argocd/"
}

# Helm repo reference: https://artifacthub.io/packages/helm/argo/argo-rollouts/
module "argo_rollout" {
  argo_rollout_version  = "2.38.0"
  source                = "../../../terraform-modules/argo-rollouts/"
}

#Modularise in case for future dependencies.  Ref: https://external-secrets.io/latest/
module "eso" {
  eso_version = "0.11.0"
  source      = "../../../terraform-modules/external-secrets/"
}

#Modularise in case for future dependencies. Ref: https://istio.io/latest/docs/setup/install/helm/
module "istio" {
  istio_version   = "1.22.6"
  kiali_version   = "1.76.0"
  source        = "../../../terraform-modules/istio-kiali"
}

#Modularise in case for future dependencies. Ref: https://github.com/jaegertracing/jaeger
# Helm repo reference : https://artifacthub.io/packages/helm/jaegertracing/jaeger
module "jaeger" {
  jaeger_version   = "3.0.10"
  source        = "../../../terraform-modules/jaeger"
}

#Modularise in case for future dependencies. Ref: https://github.com/kubernetes-csi/csi-driver-nfs
module "nfs" {
  nfs_version   = "4.8.0"             #cleanup version
  source        = "../../../terraform-modules/nfs-csi-driver/"
}

# module "solr-operator" {
#   solr_operator_version = "0.8.1"
#   source = "../../../terraform-modules/solr-operator/"
# }

#Modularise in case for future dependencies.
# TODO :  Awaiting HUIT team
#module "falcon" {
#  falcon_version   = "1.25.1"             #cleanup version
#  source        = "../../../terraform-modules/crowdstrike-falcon/"
#}
