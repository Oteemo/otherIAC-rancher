#!/bin/bash -xe

####to do make the sample yaml an seperate file that can be copied to the ec2 instead of using bash and hardcoding it
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Update SSM agent
dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# Register with Sat server
rpm -e katello-ca-consumer-rhsatprd02.cloudservices.customer.com-1.0-5.noarch
curl --insecure --output katello-ca-consumer-latest.noarch.rpm https://rhsatprd-master.customer.com/pub/katello-ca-consumer-latest.noarch.rpm
yum -y localinstall katello-ca-consumer-latest.noarch.rpm
# TODO: Change org and activation
subscription-manager register --org="CUSTOMER" --activationkey="RHEL 8" --force
subscription-manager refresh
subscription-manager config --rhsm.manage_repos=1

# Get updates, install nfs, install snmp, and apply
yum -y update
yum -y install nfs-utils
yum -y install net-snmp net-snmp-utils net-snmp-libs net-snmp-devel

# Configure SNMP config
echo "rwcommunity  public
syslocation  CUSTOMER-AWS-PROD
# Contact email for RHEL images
syscontact CUSTOMER-prodops@calists.customer.com
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

# Register with NESSUS server
/opt/nessus_agent/sbin/nessuscli agent link --key=ba71d5afb7819defd6d3c469aaf29dcd35964c6664b71955a9b7bf2529844d75 --host=ns-manager.customer.com --port=8834 --groups=CUSTOMER-AWS-Linux --name=$(hostname)

# Install RKE2 (rke_version)
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
aws s3 cp /tmp/node-token s3://${s3_bucket_name}/node-token
# Get public DNS
aws s3 cp /tmp/node-token s3://${s3_bucket_name}/node-token

# Wait for all nodes to be ready
kubectl wait --for=condition=Ready nodes --all --timeout=6m

# Install helm and cert-manager
sleep 10 #we need to run checks instead of sleep 
curl -#L https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
sleep 10
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
sleep 10
helm repo add jetstack https://charts.jetstack.io
sleep 10
# New Cert Manager - add certmanager_version
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v${certmanager_version}/cert-manager.crds.yaml
# kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.crds.yaml
sleep 10
helm upgrade -i cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace
sleep 10

# Install Rancher Backup Operator
helm repo add rancher-charts https://charts.rancher.io
helm upgrade --install=true --version=${rancher_backup_version} rancher-backup-crd rancher-charts/rancher-backup-crd -n cattle-resources-system --create-namespace
helm upgrade --install=true --version=${rancher_backup_version} rancher-backup rancher-charts/rancher-backup -n cattle-resources-system

# Get the bootstrap password from Secrets Manager
# Install Rancher UI with the retrieved password (rancher_version)
helm upgrade -i rancher rancher-latest/rancher --create-namespace --namespace cattle-system --version ${rancher_version} --set hostname=${hostname} --set bootstrapPassword="${rancher_password}" --set replicas=1

# Create SSL Certificate Kubernetes Secrets
aws secretsmanager get-secret-value --region us-east-1 --secret-id ${env_prefix}-ssl-cert --query SecretString --output text|tr -d '"' > /tmp/tls.crt
aws secretsmanager get-secret-value --region us-east-1 --secret-id ${env_prefix}-ssl-key --query SecretString --output text|tr -d '"' > /tmp/tls.key
kubectl -n cattle-system create secret tls tls-rancher-ingress --cert=/tmp/tls.crt --key=/tmp/tls.key

# Update Rancher with SSL Certificate
helm upgrade -i rancher rancher-latest/rancher --create-namespace --namespace cattle-system --version ${rancher_version} --set hostname=${hostname} --set bootstrapPassword="${rancher_password}" --set ingress.tls.source=secret --set replicas=1

####### make sure password are not written to the log file
#also remove the spacial character in the password
#we can also use aws secrets manager to fetch the password
### Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/${argocd_version}/manifests/install.yaml
sleep 10


## Install argocd-nodeport-service #use a load balancer for this or istio
kubectl apply -f - <<EOF
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
EOF

#
# TODO: Test ESO version
#
#helm repo add external-secrets https://charts.external-secrets.io
helm repo add external-secrets-operator https://charts.external-secrets.io/
kubectl create namespace external-secrets
helm install external-secrets external-secrets-operator/external-secrets --version ${eso_version} -n external-secrets

## SJ
kubectl -n argocd patch secret argocd-secret -p '{"stringData": {"admin.password": "$2a$04$mCudBx0tcRzmXDf5uE8hi.7oVW.suKjP8zLsM.FrbKcxhMn3N.XaG", "admin.passwordMtime": "'$(date +%FT%T%Z)'"}}'

###
### ISTIO INSTALL
###
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${istio_version} TARGET_ARCH=x86_64 sh -
cd istio-*
export PATH=$PWD/bin:$PATH

# create the Istio config file
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
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.18/samples/addons/kiali.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.18/samples/addons/prometheus.yaml

###
### PLG STACK INSTALL
###

# Create loki namespace
kubectl create namespace loki

# Create Rancher Storage Secret
# Note: The AWS Secret Prereq needs to be created before running this. The secret-id is listed below.
# The secret should contain the plg_key and plg_private_key for the IAM S3 user that was created.

output=`aws secretsmanager get-secret-value --region us-east-1 --secret-id ${env_prefix}_plg_s3_secret_name --query SecretString|tr -d '"'`
key=$(echo "$output" | sed 's/\\/"/g')

# Extract values using grep and string manipulation
plg_key=$(echo "$key" | grep -o '"plg_key":"[^"]*' | cut -d '"' -f 4)
plg_private_key=$(echo "$key" | grep -o '"plg_private_key":"[^"]*' | cut -d '"' -f 4)

kubectl create secret generic iam-loki-s3 --from-literal=AWS_ACCESS_KEY_ID="$plg_key" --from-literal=AWS_SECRET_ACCESS_KEY="$plg_private_key" -n loki

# Enable Istio Injection for loki namespace
kubectl label namespace loki istio-injection=enabled

# Add Grafana Repo
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Create Istio Virtualservice and Gateway
helm install loki grafana/loki-stack -n loki --version=${loki_version} --values - <<EOF
loki:
  env:
    - name: AWS_ACCESS_KEY_ID
      valueFrom:
        secretKeyRef:
          name: iam-loki-s3
          key: AWS_ACCESS_KEY_ID
    - name: AWS_SECRET_ACCESS_KEY
      valueFrom:
        secretKeyRef:
          name: iam-loki-s3
          key: AWS_SECRET_ACCESS_KEY
  config:
    schema_config:
      configs:
        - from: 2021-05-12
          store: boltdb-shipper
          object_store: s3
          schema: v11
          index:
            prefix: loki_index_
            period: 24h
    storage_config:
      aws:
        s3: s3://us-east-1/CUSTOMER-plg-stack-${env_prefix}
        s3forcepathstyle: true
        bucketnames: CUSTOMER-plg-stack-${env_prefix}
        region: us-east-1
        insecure: false
        sse_encryption: false
      boltdb_shipper:
        active_index_directory: "/data/loki/index"
        cache_location: "/data/loki/index_cache"
        shared_store: s3
        cache_ttl: 24h
grafana:
  enabled: true
  sidecar:
    datasources:
      enabled: true
  image:
    tag: latest
  grafana.ini:
    users:
      default_theme: light

promtail:
  enabled: true
  config:
    logLevel: info
    serverPort: 3101
    clients:
      - url: http://{{ .Release.Name }}:3100/loki/api/v1/push
EOF

# Create ISTIO Virtual Service and Gateway
kubectl apply -n loki -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: loki-gateway

spec:
  selector:
    istio: ingressgateway # use istio default controller
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - logs.${env_prefix}.lib.customer.edu
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: loki-service
spec:
  hosts:
  - "*"
  gateways:
  - loki-gateway
  http:
    - match:
        - uri:
            prefix: /test
      rewrite:
        uri: /
      route:
        - destination:
            host: loki-grafana
            port:
              number: 80
    - match:
        - uri:
            prefix: /
      route:
        - destination:
            host: loki-grafana
            port:
              number: 80
EOF

# Add Grafana Password to Secrets Manager

password=`kubectl get secret loki-grafana --namespace=loki -o jsonpath="{.data.admin-password}" | base64 --decode ; echo`

echo "Checking if secret key exists.."
verify=`aws secretsmanager describe-secret --region us-east-1 --secret-id ${env_prefix}_customer_rke_plg`

if [[ "$verify" == "" ]]
then
        echo "Key does not exist"
        aws secretsmanager create-secret --region us-east-1 --name ${env_prefix}_customer_rke_plg --secret-string '{"admin":"'$password'"}'
else
        echo "Key exists"
        aws secretsmanager update-secret --region us-east-1 --secret-id ${env_prefix}_customer_rke_plg --secret-string '{"admin":"'$password'"}'
fi

