#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Update SSM agent
dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# Register with Nessus server
/sbin/service nessusagent stop

FILE=/etc/tenable_tag
if test -f "$FILE"; then
    rm -rf /etc/tenable_tag
fi

/sbin/service nessusagent start
/opt/nessus_agent/sbin/nessuscli agent link --key=c5594d6b00c83d4311632819c1671562efb1c20dbf56e261b389bb620c40aeef --host=ns-manager.itsec.harvard.edu --port=8834 --groups=LTS-AWS-Linux --name=$(hostname)

useradd github_runner

#Install Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

#Install IstioCTL
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.20.3 TARGET_ARCH=x86_64 sh -
cd istio-*
export PATH=$PWD/bin:$PATH:/usr/local/bin

# Add Docker Repos
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Install docker
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo apt-get install -y dirmngr gnupg
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo apt-get install -y apt-transport-https ca-certificates

#Setup Self Hosted Runner
su - github_runner

# Add to docker group for execution permission
sudo usermod -aG docker github_runner

mkdir /home/github_runner

mkdir /opt/hostedtoolcache/
mkdir /opt/hostedtoolcache/Ruby
cd /opt/
chown -R github_runner:github_runner /opt/hostedtoolcache/

cd /home/
chown -R github_runner github_runner

export PATH=$PWD/bin:$PATH:/usr/local/bin

mkdir actions-runner && cd actions-runner

# TODO :  Parameterize runner version
curl -o actions-runner-linux-x64-2.313.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.313.0/actions-runner-linux-x64-2.313.0.tar.gz

tar xzf ./actions-runner-linux-x64-2.313.0.tar.gz

# TODO: Parameterize repo and token - configuration with ORG level
#./config.sh --url https://github.com/harvard-lts/CURIOSity --token BBKOQB6OJKCNS3OXV3CXOFTF4ICFY

./config.sh --url https://github.com/harvard-lts --token ADLCTDZJQL7PLUH6QBFAKLLF6H4LY

### 75 lines for github runner script
# Added Kubectl and Istioctl
# Added github runner setup
# Corrections PATH and KUBECTL