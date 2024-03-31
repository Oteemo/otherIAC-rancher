#!/bin/bash -xe

####to do make the sample yaml an seperate file that can be copied to the ec2 instead of using bash and hardcoding it
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Update SSM agent
dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

### Register with Sat server
katello_version=$(rpm -qa | grep katello-ca-consumer)
rpm -e $katello_version

curl --insecure --output katello-ca-consumer-latest.noarch.rpm https://rhsatprd-master.huit.harvard.edu/pub/katello-ca-consumer-latest.noarch.rpm
yum -y localinstall katello-ca-consumer-latest.noarch.rpm
subscription-manager register --org="LTS" --activationkey="RHEL 8" --force
subscription-manager refresh
subscription-manager config --rhsm.manage_repos=1

### Get updates, install nfs, install snmp, and apply
yum -y update
yum -y install nfs-utils
yum -y install net-snmp net-snmp-utils net-snmp-libs net-snmp-devel

# Adding pub key for patching
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC1R48RInVL/ktexb2i5+1FwlyFyRMjhdAyJtcSYlpG/IX/7yakozJTVMrDiUg957s28ssw0ucdDGS1yTEm1qFKL44svLStodqUimZK/eTnFl74XRQQQJv4AAJsPcc11IDJNVR995T9hpHoDnqCaKl7SY1AYiScIf0M18VXZ7hmFDGp5NJ2BpDVFWaCb5B0dlHd7Lr2RUvvIBqLm4W9dx30r9pjbVcpSrcAiDnF5G8TywAfRjIgilHO/I0xqzwlmGsK2c4qNLOfmuniTB4yKWr2gENVOYwJAauEdQ3kuNTcTJwcEYORSuuSUPGQ3RXtIfFi15OGZs/8oWyTKEi0eRBwwcJEKz+TbgQHlkGOATF8L431c5MSR+NlbHRq50gLFQjDZAj6n2M0ZfmzsvJ9gNfxQnMDzp8zMaSFdVUnOacAL3cd11ZPZqJ8+PYp+qDLrpaZP2LgLnB1mFHHxDvUWDHlBeyI5FXQkhC87MdZNLIow6wUXz+4Y/ZF2OBiCyOMjeOWoRli+NGrs6Ds58A2fjZyV4a5/fMyIxpIEDROBlBlD6mStrvyHyEyGPDUJjqKhKPNXsotEWFHZdbeUfeq4jJ71eiWDgRM1evJD2pPq9QJcS8Bozq6N6dPBX8LgaP6HkwQt6pSMZdUOYDBVQ8aFmZdIlPBan5+lHzWkBXbn+botw==" > /opt/ansible_rw/.ssh/authorized_keys

# Blanking HUIT account key.
echo "" > /opt/ansible_ro/.ssh/authorized_keys

### Configure SNMP config
echo "rwcommunity  public
syslocation  LTS-AWS-PROD
syscontact lts-prodops@calists.harvard.edu
sysservices 0
trap2sink
informsink
trapcommunity  public" > /etc/snmp/snmpd.conf

chmod 600 /etc/snmp/snmpd.conf
systemctl enable snmpd
systemctl restart snmpd

# Add EFS mount point and mount EFS volume. 
mkdir /docker
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,soft,timeo=600,retrans=2,noresvport ${efs_mount}:/ docker
sudo echo "${efs_mount}:/ /docker nfs4  rw    0     0" >> /etc/fstab

# TEMP FIX before PVCs
groupadd appcommon -g ${group_id1}
groupadd appadmin -g ${group_id2}

### Register with NESSUS server
/sbin/service nessusagent stop

FILE=/etc/tenable_tag
if test -f "$FILE"; then
    rm -rf /etc/tenable_tag
fi

/sbin/service nessusagent start

/opt/nessus_agent/sbin/nessuscli agent link --key=ba71d5afb7819defd6d3c469aaf29dcd35964c6664b71955a9b7bf2529844d75 --host=ns-manager.itsec.harvard.edu --port=8834 --groups=LTS-AWS-Linux --name=$(hostname)

### Install RKE2 (rke_version)
curl -sfL https://get.rke2.io | INSTALL_RKE2_CHANNEL=${rke_version} INSTALL_RKE2_TYPE=server sh -

# Comment out broken command of unit file
sed -ie  "s/\(.*nm-cloud-setup.service.*\)/#\1/" /usr/lib/systemd/system/rke2-server.service 

# Enable the RKE2 server service
systemctl enable --now rke2-server.service

# Symlink all the things - kubectl
ln -s $(find /var/lib/rancher/rke2/data/ -name kubectl) /usr/local/sbin/kubectl

# Add kubectl conf
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml 

# Save this for rancher2 and rancher3
cat /var/lib/rancher/rke2/server/node-token

sudo cat /var/lib/rancher/rke2/server/node-token > /tmp/node-token
aws s3 cp --region us-east-1 /tmp/node-token s3://${s3_bucket_name}/node-token

# Wait for all nodes to be ready
kubectl wait --for=condition=Ready nodes --all --timeout=6m

### Install helm and cert-manager
curl -#L https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
sleep 10
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
sleep 10
helm repo add jetstack https://charts.jetstack.io
sleep 10
### New Cert Manager - add certmanager_version
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v${certmanager_version}/cert-manager.crds.yaml
sleep 10
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version=v${certmanager_version}
sleep 10

### Add HELM repos
helm repo add argocd https://argoproj.github.io/argo-helm
helm repo add istiod https://istio-release.storage.googleapis.com/charts

###  Install Rancher Backup Operator
helm repo add rancher-charts https://charts.rancher.io
helm upgrade --install=true --version=${rancher_backup_version} rancher-backup-crd rancher-charts/rancher-backup-crd -n cattle-resources-system --create-namespace
helm upgrade --install=true --version=${rancher_backup_version} rancher-backup rancher-charts/rancher-backup -n cattle-resources-system

### Install Rancher Monitoring
helm upgrade --install=true --version=${rancher_monitoring_version} --wait=true --timeout=10m0s rancher-monitoring-crd rancher-charts/rancher-monitoring-crd -n cattle-monitoring-system --create-namespace
helm upgrade --install=true --version=${rancher_monitoring_version} --wait=true --timeout=10m0s rancher-monitoring rancher-charts/rancher-monitoring -n cattle-monitoring-system

# Get the bootstrap password from Secrets Manager & install Rancher UI with the retrieved password (rancher_version)
helm upgrade -i rancher rancher-latest/rancher --create-namespace --namespace cattle-system --version ${rancher_version} --set hostname=${hostname} --set bootstrapPassword="${rancher_password}" --set replicas=1

# Create SSL Certificate Kubernetes Secrets
aws secretsmanager get-secret-value --region us-east-1 --secret-id ${env_prefix}-ssl-cert --query SecretString --output text|tr -d '"' > /tmp/tls.crt
aws secretsmanager get-secret-value --region us-east-1 --secret-id ${env_prefix}-ssl-key --query SecretString --output text|tr -d '"' > /tmp/tls.key
kubectl -n cattle-system create secret tls tls-rancher-ingress --cert=/tmp/tls.crt --key=/tmp/tls.key

# Update Rancher with SSL Certificate
helm upgrade -i rancher rancher-latest/rancher --create-namespace --namespace cattle-system --version ${rancher_version} --set hostname=${hostname} --set bootstrapPassword="${rancher_password}" --set ingress.tls.source=secret --set replicas=1

### Install ARGOCD
kubectl create namespace argocd

### Install ESO version
kubectl create namespace external-secrets

# PLACEHOLDER ArgoCD NODEPORT - Removed to Helm Provider
kubectl create namespace istio-system

## ISTIO INSTALL
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${istio_version} TARGET_ARCH=x86_64 sh -
cd istio-*
export PATH=$PWD/bin:$PATH

#create the Istio config file
cat <<EOF > istio-config.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  components:
    ingressGateways:
      - name: istio-ingressgateway
        enabled: true
        k8s:
          service:
            type: NodePort
            ports:
              - port: 80
                targetPort: 8080
                name: http2
                nodePort: 31380
              - port: 443
                nodePort: 32001
                name: https
  values:
    gateways:
      istio-ingressgateway:
        runAsRoot: true
        type: NodePort
EOF

istioctl install -f istio-config.yaml -y
kubectl label namespace default istio-injection=enabled
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/kiali.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/prometheus.yaml

echo "--------------------------------------------------"
echo "          DEPLOYMENT COMPLETE"
echo "--------------------------------------------------"