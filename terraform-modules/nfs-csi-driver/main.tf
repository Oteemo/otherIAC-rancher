
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
resource "helm_release" "nfs_driver" {
  name              = "csi-driver-nfs"
  chart             = "csi-driver-nfs"
  create_namespace  = "false"
  namespace         = "kube-system"
  version           = var.nfs_version
  repository        = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts"

  #  # TODO : Workout the depends
  # depends_on = data.kubernetes_cluster_name
}