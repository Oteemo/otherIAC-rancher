
# TODO : Work out the depends for Kubernetes cluster to be available
terraform {

  required_providers {

    kubectl = {
      source  = "alon-dotan-starkware/kubectl"
      version = "1.11.2"
    }
  }
}

###  ArgoCD Upgrade (LD177)
resource "helm_release" "argocd_helm" {
  name       = "argo-cd"
  chart      = "argo-cd"
  create_namespace  = "true"
  version           = var.argocd_version
  namespace         = "argocd"
  repository        = "https://argoproj.github.io/argo-helm"
}

resource "kubectl_manifest" "argocd_nodeport" {
  yaml_body = <<YAML
    apiVersion: v1
    kind: Service
    metadata:
      name: argocd-nodeport-service
      namespace: argocd
    spec:
      type: NodePort
      selector:
        app.kubernetes.io/name: argocd-server
      ports:
      - name: http
        protocol: TCP
        port: 80
        targetPort: 8080
        nodePort: 30083
      - name: https
        protocol: TCP
        port: 443
        targetPort: 8080
        nodePort: 30446
YAML
}