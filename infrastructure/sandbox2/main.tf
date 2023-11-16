terraform {

  required_version = "~> 1.5.0"       #field for tf version.  minimum

  #Different fields and requirements for providers
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.20.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.11.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
    rancher2 = {
      source = "rancher/rancher2"
      version = "3.2.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# TODO : Check if we can use rancher provider
provider "rancher2" {
  api_url    = "https://cluster-console.sand2.domain.com"
  access_key = var.rancher2_access_key
  secret_key = var.rancher2_secret_key
}

# SJ:  Hardcoded until we can dynamically work out kube context
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "sandbox2"
  }
}

# TODO: Specify for use for the 'depends_on' variable
provider "kubernetes" {
  host                   = data.aws_eks_cluster
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", local.cluster_name, "--role-arn", var.kubernetes_access_role ]
    command     = "aws"
  }
}

module "argocd_secret_manager" {
  password_length     = 16
  secret_manager_name = "sandbox2_customer_rke_argocd"
  source              = "../../terraform-modules/aws-secrets-manager/"
}

module "rke2" {
  agent_private_ips             = ["1.2.3.4", "1.2.3.5"]                # Change : Add worker node IPs
  sandbox_subnets				= ["1.2.3.64/26","1.2.3.0/26"]          # Change : Security group subnets
  alb_sg_id                     = module.alb_istio.alb_security_group_id
  ami_id                        = data.aws_ami.latest_patched_ami.id
  argocd_version                = "v2.8.4"              #cleanup version
  certmanager_version           = "1.13.1"              #cleanup version
  # Add the EFS mount name
  efs_mount                     = "<<EFS-mount>>.efs.us-east-1.amazonaws.com"   # Change:  Add EFS mount arn
  environment_name              = "sandbox 2"
  env_prefix                    = "sand2"
  eso_version                   = "0.9.5"             #cleanup version
  hostname                      = "cluster-console.sand2.domain.com"            # Change: Fix the DNS for server node
  instance_count                = 2
  instance_type                 = "t3.xlarge"
  istio_version                 = "1.18.0"            #cleanup version
  key_pair_name_prefix          = "Customer-oteemo"
  loadbalancer_subnets			= ["10.140.208.64/26","10.140.209.0/26"]        # Change: Security group for server subnets
  loki_version                  = "2.9.11"            #cleanup version
  node_agent_subnet_id          = "subnet-0ea1234"                              # Change: Node's subnets
  rancher_backup_version        = "102.0.2+up3.1.2"   #cleanup version
  rancher_password              = data.aws_secretsmanager_secret_version.sandbox2_rancher_password.secret_string
  rancher_version               = "2.7.6"             #cleanup version
  rke_version                   = "v1.24"             #cleanup version
  rsa_bits                      = 4096
  s3_bucket_name                = "sandbox2-customer-oteemo-node"               # Change: S3 bucket to be customer specific
  server_private_ip             = "1.2.3.100"                                   # Change: server IP for control node
  # Add server subnet
  server_subnet_id              = "subnet-0f045678"                             # Change: Server's subnet
  source                        = "../../terraform-modules/rke2-install/"
  userdata_agent_template_file  = "templates/userdata_agent.sh"
  userdata_server_template_file = "templates/userdata_server.sh"  
  volume_size                   = 100
  #Add VPC for the EC2 instances
  vpc_id                        = "vpc-0d8910"	                                # Change:  VPC for workers and servers
}

module "alb_istio" {
  # Add the env subnets
  alb_subnet_id         = ["subnet-043", "subnet-00c"]                          # Change:  Subnets for ALB
  alb_vpc_id            = "vpc-0d1a887bbc1aef59d"                               # Change:  VPC for ALB
  certificate_arn       = "arn:aws:acm:us-east-1:086178843174:certificate/65e38638-b9f7-426d-98dd-1a02ffcdc69a"   # Change: Certificate for ALB
  health_check_interval = 30
  health_check_path     = "/"
  health_check_port     = "traffic-port"
  health_check_timeout  = 5
  healthy_threshold     = 3
  # Add the server and node IPs
  ingress_ip            = ["1.2.3.100", "1.2.3.4", "1.2.3.5"]                   # Change: Add server and nodes IPs
  lb_name               = "istiolb2"                                            # Change: Give ALB a name
  listener_port         = "80"
  listener_protocol     = "HTTP"
  security_group_name   = "alb_sg2"
  source                = "../../terraform-modules/alb"
  target_group_name         = "customer-target-group-http"                      # Change: target group for HTTP
  target_group_name_https   = "customer-target-group-https"                     # Change: target group for HTTPS
  target_group_port     = 31380
  unhealthy_threshold   = 4
}

module "secret_manager" {
  password_length     = 16
  secret_manager_name = "sandbox2_customer_rke_rancher"
  source              = "../../terraform-modules/aws-secrets-manager/"
}
