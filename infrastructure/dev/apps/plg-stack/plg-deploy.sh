# Create loki namespace
kubectl create namespace loki

# Set Environment Variables:
env_prefix="dev"

database=`aws secretsmanager get-secret-value --region us-east-1 --secret-id ${env_prefix}_plg_mysql_url --query SecretString|tr -d '"'`
oidc_id=`aws secretsmanager get-secret-value --region us-east-1 --secret-id ${env_prefix}_oidc_plg_id --query SecretString|tr -d '"'`
oidc_secret=`aws secretsmanager get-secret-value --region us-east-1 --secret-id ${env_prefix}_oidc_plg_secret --query SecretString|tr -d '"'`

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
helm install --debug loki grafana/loki-stack -n loki --version=2.10.2 -f - <<EOF
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
    limits_config:
      max_entries_limit_per_query: 500000

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
    auth.generic_oauth:
      enabled: true
      name: "Harvard Key"
      allow_sign_up: true
      client_id: ${oidc_id}
      client_secret: ${oidc_secret}
      scopes: "openid profile email groups offline_access"
      auth_url: "https://www.pin1.harvard.edu/cas/oidc/oidcAuthorize"
      token_url: "https://www.pin1.harvard.edu/cas/oidc/oidcAccessToken"
      api_url: "https://www.pin1.harvard.edu/cas/oidc"
      auto_login: false
      allow_assign_grafana_admin: false
      skip_org_role_sync: true
    server:
      domain: logs.${env_prefix}.lib.harvard.edu
      root_url: https://logs.${env_prefix}.lib.harvard.edu
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
      host: ${database}
      name: grafana
      user: grafana
      password: ${mysql_pw}
      ssl_mode: require
    smtp:
      enabled: true
      host: mailhub.harvard.edu:25
      from_address: tom_scorpa@harvard.edu
    dataproxy:
      timeout: 600
      keep_alive_seconds: 600
      dialTimeout: 600
      tls_handshake_timeout_seconds: 600

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
kind: VirtualService
metadata:
  name: loki-service
spec:
  hosts:
  - logs.${env_prefix}.lib.harvard.edu
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
verify=`aws secretsmanager describe-secret --region us-east-1 --secret-id ${env_prefix}_harvard_lts_rke_plg`

if [[ "$verify" == "" ]]
then
        echo "Key does not exist"
        aws secretsmanager create-secret --region us-east-1 --name ${env_prefix}_harvard_lts_rke_plg --secret-string '{"admin":"'$password'"}'
else
        echo "Key exists"
        aws secretsmanager update-secret --region us-east-1 --secret-id ${env_prefix}_harvard_lts_rke_plg --secret-string '{"admin":"'$password'"}'
fi



