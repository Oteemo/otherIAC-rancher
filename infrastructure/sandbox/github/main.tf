terraform {

  required_version = ">= 1.6.0"       #field for tf version.  minimum

  #Different fields and requirements for providers
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

#module "github_runner_ubuntu" {
#  ami_id                        = data.aws_ami.latest_patched_ami.id
#  env_prefix                    = "sand"
#  environment_name              = "sandbox"
#  hostname                      = "cluster-console.sand.lib.harvard.edu"
#  instance_count                = 1
#  # Change instance_type
#  instance_type                 = "t3.medium"
#  loadbalancer_subnets			= ["10.140.208.64/26","10.140.208.0/26"]
#  private_ip                    = "10.140.210.91"
#  source                        = "../../../terraform-modules/github-runner"
#  subnet_id                     = "subnet-0f0741730943f0743"
#  userdata_agent_template_file  = "templates/userdata_github.sh"
#
#  worker_subnets				= ["10.140.210.64/26","10.140.210.0/26","10.1.79.0/24"]
#  vpc_id                        = "vpc-0d1a887bbc1aef59d"                # Change: VPC
#}

module "github_runner_rhel" {
  ami_id                        = data.aws_ami.latest_patched_ami.id
  env_prefix                    = "sand"
  environment_name              = "sandbox"
  hostname                      = "cluster-console.sand.lib.harvard.edu"
  instance_count                = 1
  # Change instance_type
  instance_type                 = "t3.medium"
  loadbalancer_subnets			= ["10.140.208.64/26","10.140.208.0/26"]
  private_ip                    = "10.140.210.91"
  source                        = "../../../terraform-modules/github-runner"
  subnet_id                     = "subnet-0f0741730943f0743"
  s3_bucket_name                = "harvard-lts-oteemo-node"             #req for iam policy

  tower_subnets                 = ["10.137.242.0/25"]
  userdata_agent_template_file  = "templates/userdata_github.sh"
  volume_size                   = 300
  volume_type                   = "gp3"

  worker_subnets				= ["10.140.210.64/26","10.140.210.0/26","10.1.79.0/24"]
  vpc_id                        = "vpc-0d1a887bbc1aef59d"                # Change: VPC
}







