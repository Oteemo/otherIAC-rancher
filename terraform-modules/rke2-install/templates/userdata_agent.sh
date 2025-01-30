#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Update SSM agent
dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# Register with Sat server
echo 'Installing Katello'
katello_version=$(rpm -qa | grep katello-ca-consumer)
rpm -e $katello_version
curl --insecure --output katello-ca-consumer-latest.noarch.rpm https://rhsatprd-master.huit.harvard.edu/pub/katello-ca-consumer-latest.noarch.rpm
yum -y localinstall katello-ca-consumer-latest.noarch.rpm
subscription-manager register --org="LTS" --activationkey="RHEL 8" --force
subscription-manager refresh
subscription-manager config --rhsm.manage_repos=1

# Get updates, install nfs, install snmp, and apply
yum -y update
yum -y install nfs-utils
yum -y install dnsmasq net-snmp net-snmp-utils net-snmp-libs net-snmp-devel

# Blanking HUIT account key. 
echo "" > /opt/ansible_ro/.ssh/authorized_keys
echo "" > /opt/ansible_rw/.ssh/authorized_keys

# Adding pub key for patching
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC1R48RInVL/ktexb2i5+1FwlyFyRMjhdAyJtcSYlpG/IX/7yakozJTVMrDiUg957s28ssw0ucdDGS1yTEm1qFKL44svLStodqUimZK/eTnFl74XRQQQJv4AAJsPcc11IDJNVR995T9hpHoDnqCaKl7SY1AYiScIf0M18VXZ7hmFDGp5NJ2BpDVFWaCb5B0dlHd7Lr2RUvvIBqLm4W9dx30r9pjbVcpSrcAiDnF5G8TywAfRjIgilHO/I0xqzwlmGsK2c4qNLOfmuniTB4yKWr2gENVOYwJAauEdQ3kuNTcTJwcEYORSuuSUPGQ3RXtIfFi15OGZs/8oWyTKEi0eRBwwcJEKz+TbgQHlkGOATF8L431c5MSR+NlbHRq50gLFQjDZAj6n2M0ZfmzsvJ9gNfxQnMDzp8zMaSFdVUnOacAL3cd11ZPZqJ8+PYp+qDLrpaZP2LgLnB1mFHHxDvUWDHlBeyI5FXQkhC87MdZNLIow6wUXz+4Y/ZF2OBiCyOMjeOWoRli+NGrs6Ds58A2fjZyV4a5/fMyIxpIEDROBlBlD6mStrvyHyEyGPDUJjqKhKPNXsotEWFHZdbeUfeq4jJ71eiWDgRM1evJD2pPq9QJcS8Bozq6N6dPBX8LgaP6HkwQt6pSMZdUOYDBVQ8aFmZdIlPBan5+lHzWkBXbn+botw==" > /opt/ansible_rw/.ssh/authorized_keys

# Configure SNMP config
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

### DNSMASQ ###
#blank dnsmasq config
echo "" > /etc/dnsmasq.conf 

# write desired dnsmasq config
echo "domain-needed
bogus-priv
interface=lo
bind-interfaces
listen-address=127.0.0.1
cache-size=1000
resolv-file=/etc/resolv.dnsmasq
no-poll
## Can append below two parameters to log host queries
log-queries
log-facility=/var/log/dnsmasq.log" >> /etc/dnsmasq.conf 

#cache miss DNS server config
cat /etc/resolv.conf >> /etc/resolv.dnsmasq

#blank resolv.conf
echo "" > /etc/resolv.conf

#write dnsmasq conf to resolv.conf
echo "nameserver 127.0.0.1
options edns0" >> /etc/resolv.conf

#enable and start dnsmasq service
systemctl enable --now dnsmasq.service

#logrotate for dnsmasq
echo "/var/log/dnsmasq.log {
	rotate 1
	size 10M
    copytruncate
}" >> /etc/logrotate.d/dnsmasq

# Add EFS mount point and mount EFS volume. 
mkdir /docker
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,soft,timeo=600,retrans=2,noresvport ${efs_mount}:/ docker
sudo echo "${efs_mount}:/ /docker nfs4  rw    0     0" >> /etc/fstab

# TEMP FIX before PVCs
groupadd appcommon -g ${group_id1}
groupadd appadmin -g ${group_id2}

# Register with Nessus server
/sbin/service nessusagent stop

FILE=/etc/tenable_tag
if test -f "$FILE"; then
    rm -rf /etc/tenable_tag
fi

/sbin/service nessusagent start
/opt/nessus_agent/sbin/nessuscli agent link --key=c5594d6b00c83d4311632819c1671562efb1c20dbf56e261b389bb620c40aeef --host=ns-manager.itsec.harvard.edu --port=8834 --groups=LTS-AWS-Linux --name=$(hostname)


# Change Worker Node Ulimits
echo "# CHANGES BY LTS
      *               soft    nproc           200000
      *               hard    nproc           200000
      *               hard    nofile          150000
      *               soft    nofile          100000" >> /etc/security/limits.conf
echo "# CHANGES BY LTS
      fs.file-max = 12760880" >> /etc/sysctl.d/99-sysctl.conf




# Wait for the token to be uploaded to S3 and then download it
while true; do
  if aws s3 ls --region us-east-1 s3://${s3_bucket_name}/node-token; then
    aws s3 cp --region us-east-1 s3://${s3_bucket_name}/node-token /tmp/node-token
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



