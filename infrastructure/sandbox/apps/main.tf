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
    #https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.23.0"
    }

  }
}

provider "aws" {
  region = "us-east-1"
}

#  TODO :  TO work out cluster dynamically
#provider "helm" {
#  kubernetes {
#    host              = "cluster-console.sand2.harvard.edu"
#    cluster_ca_certificate = base64decode(rke2_cluster.my_cluster.cluster_ca_certificate)
#    exec {
#      api_version = "client.authentication.k8s.io/v1beta1"
#      args        = ["eks", "get-token", "--cluster-name", "local"]
#      command     = "aws"
#    }
#  }
#}

# TODO :  TO work out cluster dynamically
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "sandbox1"
  }
}

#Modularise in case for future dependencies
# Helm repo reference: https://artifacthub.io/packages/helm/argo/argo-cd
module "argocd" {
  # argocd_version      = "7.6.12"
  argocd_version      = "7.7.17"
  source              = "../../../terraform-modules/argocd/"
}

# # Helm repo reference: https://artifacthub.io/packages/helm/argo/argo-rollouts/
# module "argo_rollout" {
#   argo_rollout_version  = "2.38.0"
#   source                = "../../../terraform-modules/argo-rollouts/"
# }
#
# #Modularise in case for future dependencies.  Ref: https://external-secrets.io/latest/
# # Helm repo reference: https://artifacthub.io/packages/helm/external-secrets-operator/external-secrets
# module "eso" {
#   eso_version = "0.10.6"
#   source      = "../../../terraform-modules/external-secrets/"
# }
#
#Modularise in case for future dependencies. Ref: https://istio.io/latest/docs/setup/install/helm/
module "istio" {
  istio_version   = "1.23.4"
  kiali_version   = "1.76.0"
  source        = "../../../terraform-modules/istio-kiali"
}

#Modularise in case for future dependencies. Ref: https://github.com/jaegertracing/jaeger
# Helm repo reference : https://artifacthub.io/packages/helm/jaegertracing/jaeger
# module "jaeger" {
#   jaeger_version   = "3.0.10"
#   source        = "../../../terraform-modules/jaeger"
# }

# #Modularise in case for future dependencies. Ref: https://github.com/kubernetes-csi/csi-driver-nfs
# module "loki" {
#   #TODO : Replace hardcoded with variable
#   database       = "sand-plg-db.cdpnfrydb0hr.us-east-1.rds.amazonaws.com:3306"
#   #TODO : Replace hardcoded with variable
#   env_prefix     = "sand"
#   loki_version   = "2.9.11"             #cleanup version
#   source        = "../../../terraform-modules/loki/"
# }

#Modularise in case for future dependencies. Ref: https://github.com/kubernetes-csi/csi-driver-nfs
module "nfs" {
  nfs_version   = "4.9.0"             #cleanup version
  source        = "../../../terraform-modules/nfs-csi-driver/"
}

#Modularise in case for future dependencies.
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

# module "orca" {
#   source              = "../../../terraform-modules/orca/"
# }