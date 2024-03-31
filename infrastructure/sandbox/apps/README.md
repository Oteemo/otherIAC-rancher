
## Apps

This is the folder, where the Kubernetes applications are installed from.

Whilst these apps are currently included, future work may include NeuVector and/or Crowdstrike.

Each app is correlated to via its app_version.

For example:   argocd_version refers to the argo CD helm chart version.

1. Argo CD
* This is the Continuous Delivery tool for Kubernetes.
Ref: https://github.com/argoproj/argo-cd

2. ESO (External Secrets Operator)
* This is the secrets operator to retrieve secret/s from the AWS Secrets Manager. 
Ref: https://external-secrets.io/latest/

3. Istio 
* This is the service mesh we are using in Kubernetes. 
Ref:https://istio.io/

4. Kiali
Kiali is simply the console for the Istio Service Mesh
Ref: https://kiali.io/

5. NFS CSI
This is the default Kubernetes NFS CSI driver
Ref : https://github.com/kubernetes-csi/csi-driver-nfs

NOTE:  Falcon Crowdstrike is added however we having meeting with HUIT in Feb 2024