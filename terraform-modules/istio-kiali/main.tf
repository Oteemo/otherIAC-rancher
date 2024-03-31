# TODO : Work out the depends for Kubernetes cluster to be available
terraform {

  required_providers {

    kubectl = {
      source  = "alon-dotan-starkware/kubectl"
      version = "1.11.2"
    }
  }
}

# ISTIOCTL command
resource "null_resource" "istioctl_uninstall" {

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = "${path.module}"
    command = "chmod +x uninstall-gateway.sh"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = "${path.module}"
    command = "./uninstall-gateway.sh"
  }

}

###  ISTIO Upgrade (LD178)
resource "helm_release" "istio_helm" {
  name             = "istiod"
  chart            = "istiod"
  create_namespace = "true"
  namespace        = "istio-system"
  pass_credentials = true
  repository       = "https://istio-release.storage.googleapis.com/charts"
  version          = var.istio_version

  set {
    name = "pilot.tag"          #Use pilot due to bug https://github.com/istio/istio/issues/35692
    value = var.istio_version
  }

  depends_on       = [null_resource.istioctl_uninstall]
}

##  KIALI Upgrade (LD178)
resource "helm_release" "kiali_helm" {
  name             = "kiali-server"
  chart            = "kiali-server"
  namespace        = "istio-system"
  repository       = "https://kiali.org/helm-charts"
  version          = var.kiali_version
  depends_on       = [helm_release.istio_helm]
}



# ISTIOCTL command
resource "null_resource" "istioctl_install" {

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = "${path.module}"
    command = "chmod +x install-gateway.sh"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = "${path.module}"
    command = "./install-gateway.sh"
  }

  depends_on       = [helm_release.istio_helm, helm_release.kiali_helm, null_resource.istioctl_uninstall]
}