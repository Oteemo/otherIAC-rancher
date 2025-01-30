#!/bin/bash -xe

####to do make the sample yaml an seperate file that can be copied to the ec2 instead of using bash and hardcoding it
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

#Temp workaround
chmod 777 /var/lib/rpm/.rpm.lock
sleep 10

# Update SSM agent
dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# Register with Sat server
echo " --> Register"
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
yum -y install net-snmp net-snmp-utils net-snmp-libs net-snmp-devel

# Adding pub key for patching
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC1R48RInVL/ktexb2i5+1FwlyFyRMjhdAyJtcSYlpG/IX/7yakozJTVMrDiUg957s28ssw0ucdDGS1yTEm1qFKL44svLStodqUimZK/eTnFl74XRQQQJv4AAJsPcc11IDJNVR995T9hpHoDnqCaKl7SY1AYiScIf0M18VXZ7hmFDGp5NJ2BpDVFWaCb5B0dlHd7Lr2RUvvIBqLm4W9dx30r9pjbVcpSrcAiDnF5G8TywAfRjIgilHO/I0xqzwlmGsK2c4qNLOfmuniTB4yKWr2gENVOYwJAauEdQ3kuNTcTJwcEYORSuuSUPGQ3RXtIfFi15OGZs/8oWyTKEi0eRBwwcJEKz+TbgQHlkGOATF8L431c5MSR+NlbHRq50gLFQjDZAj6n2M0ZfmzsvJ9gNfxQnMDzp8zMaSFdVUnOacAL3cd11ZPZqJ8+PYp+qDLrpaZP2LgLnB1mFHHxDvUWDHlBeyI5FXQkhC87MdZNLIow6wUXz+4Y/ZF2OBiCyOMjeOWoRli+NGrs6Ds58A2fjZyV4a5/fMyIxpIEDROBlBlD6mStrvyHyEyGPDUJjqKhKPNXsotEWFHZdbeUfeq4jJ71eiWDgRM1evJD2pPq9QJcS8Bozq6N6dPBX8LgaP6HkwQt6pSMZdUOYDBVQ8aFmZdIlPBan5+lHzWkBXbn+botw==" > /opt/ansible_rw/.ssh/authorized_keys

# Blanking HUIT account key.
echo "" > /opt/ansible_ro/.ssh/authorized_keys

echo " --> SNMP"
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

echo " --> Nessus"
# Register with NESSUS server
/sbin/service nessusagent stop

FILE=/etc/tenable_tag
if test -f "$FILE"; then
    rm -rf /etc/tenable_tag
fi

/sbin/service nessusagent start
/opt/nessus_agent/sbin/nessuscli agent link --key=c5594d6b00c83d4311632819c1671562efb1c20dbf56e261b389bb620c40aeef --host=ns-manager.itsec.harvard.edu --port=8834 --groups=LTS-AWS-Linux --name=$(hostname)


#Install Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Add Docker Repos

#Add sudoers
cd /etc/sudoers.d/

export PATH=$PWD/bin:$PATH:/usr/local/bin

### 75 lines for github runner script
# Added Kubectl and Istioctl
# Added github runner setup
# Corrections PATH and KUBECTL