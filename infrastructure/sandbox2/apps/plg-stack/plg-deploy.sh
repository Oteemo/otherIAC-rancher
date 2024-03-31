# Create loki namespace
kubectl create namespace loki

# Set Environment Variables:
env_prefix="sand"
database="some-db-host:3306"

# Create Rancher Storage Secret & Mysql DB Password
# Note: The AWS Secret Prereq needs to be created before running this. The secret-id is listed below.
# The secret should contain the plg_key and plg_private_key for the IAM S3 user that was created.

output=`aws secretsmanager get-secret-value --region us-east-1 --secret-id ${env_prefix}_plg_s3_secret_name --query SecretString|tr -d '"'`
key=$(echo "$output" | sed 's/\\/"/g')
mysql_pw=`aws secretsmanager get-secret-value --region us-east-1 --secret-id ${env_prefix}_plg_mysql --query SecretString|tr -d '"'`

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
# helm install loki grafana/loki-stack -n loki -f - <<EOF
helm install loki grafana/loki-stack -n loki --version=2.9.11 -f - <<EOF
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
        s3: s3://us-east-1/lts-plg-stack-${env_prefix}
        s3forcepathstyle: true
        bucketnames: lts-plg-stack-${env_prefix}
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
    paths:
      data: /var/lib/grafana/
      logs: /var/log/grafana
      plugins: /var/lib/grafana/plugins
      provisioning: /etc/grafana/provisioning
    analytics:
      check_for_updates: true
    log:
      mode: console
    grafana_net:
      url: https://grafana.net
    database:
      type: mysql
      host: local-plg-db.cdpnfrydb0hr.us-east-1.rds.amazonaws.com:3306
      name: grafana
      user: grafana
      password: ${mysql_pw}
      ssl_mode: require
    smtp:
      enabled: true
      host: mailhub.harvard.edu

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
    - logs.${env_prefix}.lib.harvard.edu
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: loki-service
spec:
  hosts:
  - "*"
  gateways:
  - istio-system/public-gateway
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
verify=`aws secretsmanager describe-secret --region us-east-1 --secret-id local_harvard_lts_rke_plg`

if [[ "$verify" == "" ]]
then
        echo "Key does not exist"
        aws secretsmanager create-secret --region us-east-1 --name ${env_prefix}_harvard_lts_rke_plg --secret-string '{"admin":"'$password'"}'
else
        echo "Key exists"
        aws secretsmanager update-secret --region us-east-1 --secret-id ${env_prefix}_harvard_lts_rke_plg --secret-string '{"admin":"'$password'"}'
fi

echo "Updating Loki Map"


