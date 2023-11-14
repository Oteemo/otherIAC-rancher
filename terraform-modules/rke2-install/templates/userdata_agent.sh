#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Update SSM agent
dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# Register with Sat server
rpm -e katello-ca-consumer-rhsatprd02.cloudservices.customer.com-1.0-5.noarch
curl --insecure --output katello-ca-consumer-latest.noarch.rpm https://rhsatprd-master.customer.com/pub/katello-ca-consumer-latest.noarch.rpm
yum -y localinstall katello-ca-consumer-latest.noarch.rpm
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

# Register with Nessus server
/opt/nessus_agent/sbin/nessuscli agent link --key=ba71d5afb7819defd6d3c469aaf29dcd35964c6664b71955a9b7bf2529844d75 --host=ns-manager.itsec.customer.com --port=8834 --groups=CUSTOMER-AWS-Linux --name=$(hostname)

# Wait for the token to be uploaded to S3 and then download it
while true; do
  if aws s3 ls s3://${s3_bucket_name}/node-token; then
    aws s3 cp s3://${s3_bucket_name}/node-token /tmp/node-token
    break
  else
    echo "Waiting for token to be uploaded..."
    sleep 2
  fi
done

# Install RKE2
curl -sfL https://get.rke2.io | INSTALL_RKE2_CHANNEL=${rke_version} INSTALL_RKE2_TYPE=agent sh -

# issue with unit file for RKE
sed -ie  "s/\(.*nm-cloud-setup.service.*\)/#\1/" /usr/lib/systemd/system/rke2-agent.service


# Create config file
mkdir -p /etc/rancher/rke2/ 

# Change the ip to reflect your rancher1 ip
echo "server: https://${rancher_ip}:9345" > /etc/rancher/rke2/config.yaml

# Change the Token to the one from rancher1 /var/lib/rancher/rke2/server/node-token 
export TOKEN=$(cat /tmp/node-token)
echo "token: $TOKEN" >> /etc/rancher/rke2/config.yaml

# Enable and start
systemctl enable --now rke2-agent.service
