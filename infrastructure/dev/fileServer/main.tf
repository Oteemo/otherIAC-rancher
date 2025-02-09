terraform {

  required_version = ">= 1.8.0"       #field for tf version.  minimum

  #Different fields and requirements for providers
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70.0"
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



module "file_server_rhel" {
  ami_id                        = data.aws_ami.latest_patched_ami.id
  env_prefix                    = "dev"
  environment_name              = "development"
  hostname                      = "fileServer.dev.lib.harvard.edu"
  instance_count                = 1
  # Change instance_type
  instance_type                 = "t3.medium"
  loadbalancer_subnets			= ["10.138.16.0/24","10.138.29.0/24","10.138.17.0/24","10.138.19.0/25","10.138.18.0/25"]
  private_ip                    = "10.138.21.52"
  source                        = "../../../terraform-modules/file-server"
  subnet_id                     = "subnet-b205c19f"
  s3_bucket_name                = "harvard-lts-oteemo-node"             #req for iam policy

  tower_subnets                 = ["10.137.242.0/25"]
  userdata_agent_template_file  = "templates/userdata_github.sh"
  volume_size                   = 300
  volume_type                   = "gp3"

  worker_subnets				= ["10.138.21.0/24","10.138.22.0/24","10.138.23.0/24","10.1.79.0/24"]
  vpc_id                        = "vpc-d53f09b2"                # Change: VPC
}







