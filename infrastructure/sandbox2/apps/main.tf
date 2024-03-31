terraform {

  required_version = ">= 1.5.0"       #field for tf version.  minimum

  #Different fields and requirements for providers
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
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
module "argocd" {
  argocd_version      = "6.7.2"
  source              = "../../../terraform-modules/argocd/"
}

#Modularise in case for future dependencies.  Ref: https://external-secrets.io/latest/
module "eso" {
  eso_version = "0.9.13"             #cleanup version
  source      = "../../../terraform-modules/external-secrets/"
}

#Modularise in case for future dependencies. Ref: https://istio.io/latest/docs/setup/install/helm/
module "istio" {
  istio_version   = "1.21.0"             #cleanup version
  kiali_version   = "1.76.0"
  source        = "../../../terraform-modules/istio-kiali"
}

#Modularise in case for future dependencies. Ref: https://github.com/kubernetes-csi/csi-driver-nfs
module "nfs" {
  nfs_version   = "4.5.0"             #cleanup version
  source        = "../../../terraform-modules/nfs-csi-driver/"
}

#Modularise in case for future dependencies.
# TODO :  Awaiting HUIT team
#module "falcon" {
#  falcon_version   = "1.25.1"             #cleanup version
#  source        = "../../../terraform-modules/crowdstrike-falcon/"
#}
