terraform {

  required_version = ">= 1.8.0"       #field for tf version.  minimum

  #Different fields and requirements for providers
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.16.0"
    }
    # https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "rke2" {
  agent_private_ips             = ["10.140.210.6", "10.140.210.7"]                  # Change:  Add agent IPs
  loadbalancer_subnets			= ["10.140.208.64/26","10.140.208.0/26"]
  alb_sg_id                     = module.alb_istio_public.alb_security_group_id
  ami_id                        = data.aws_ami.latest_patched_ami.id
  certmanager_version           = var.certmanager_version  # 1.15.5
  criticality                   = "Non-Critical"
  efs_mount                     = "fs-060a9b8f69234eac3.efs.us-east-1.amazonaws.com"  # Change: Add EFS mount name
  env_prefix                    = "sand"
  environment_name              = "Sandbox"
  group_id1                     = "1636"
  group_id2                     = "199"
  hosted_by                     = "LTS"
  hostname                      = var.hostname                          #cluster-console.sand.lib.harvard.edu"
  instance_count                = 2
  instance_type                 = "c5.2xlarge"
  key_pair_name_prefix          = "HarvardLTS-oteemo"
  istio_version                 = var.istio_version
  level4                        = "nonlevel4"
  loki_version                  = "2.9.11"
  node_agent_subnet_id          = "subnet-0eab0ba64ee10f51f"
  rancher_backup_version        = var.rancher_backup_version                # 105.0.0+up6.0.0
  rancher_monitoring_version    = var.rancher_monitoring_version            # 103.1.1+up45.31.1
  rancher_password              = data.aws_secretsmanager_secret_version.rancher_password.secret_string
  rancher_version               = var.rancher_version       # 2.10.2
  rke_version                   = var.rke_version           # v.31
  rsa_bits                      = 4096
  s3_bucket_name                = "harvard-lts-oteemo-node"
  server_instance_count         = 0                                             # Change: server count
  server_instance_type          = var.server_instance_type  # r6a.xlarge"
  server_other_ips              = ["10.140.210.73"]                             # Change: Other server IPs
  server_private_ip             = "10.140.210.69"                               # Change: Add server IPs
  server_subnet_id              = "subnet-0f0741730943f0743"
  source                        = "../../terraform-modules/rke2-install/"
  userdata_agent_template_file  = "templates/userdata_agent.sh"
  userdata_server_template_file = "templates/userdata_server.sh"
  volume_size                   = 100
  volume_type                   = "gp3"
  vpc_id                        = var.vpc_id                       # Change: VPC
  worker_subnets				= ["10.140.210.64/26","10.140.210.0/26","10.1.79.0/24"]
  tower_subnets                 = ["10.137.242.0/25"]
  logicmon_subnets              = ["10.34.64.128/26", "10.137.242.0/26", "10.34.64.64/26"]
}

module "alb_istio_public" {
  alb_vpc_id            = var.vpc_id
  alb_subnet_id         = ["subnet-0430ccd74062f252d", "subnet-00c239cfa0a160dfe"]
  allowed_subnets       = ["128.103.24.79/32","128.103.224.79/32","10.1.79.0/24","10.140.210.0/24", "10.140.210.6/32", "10.140.210.7/32", "10.140.210.69/32"]
  ingress_ip            = ["10.140.210.69", "10.140.210.6", "10.140.210.7"]     # Change: Add server and worker IPs
  health_check_path     = "/productpage"
  certificate_arn       = "arn:aws:acm:us-east-1:086178843174:certificate/2f91f81c-41dc-4916-a930-98aaac463151"
  security_group_name   = "sb_alb_sg"
  additional_certs      = []                      #TF is ok with empty variables. Just skips it.
  lb_name               = "istiolb"
  listener_port         = 80
  listener_protocol     = "HTTP"
  source                = "../../terraform-modules/alb"
  target_group_name     = "lts-public-tgt-grp"                            # Change: HTTP target group
  target_group_name_https     = "lts-public-tgt-grp-https"                # Change: HTTPS target group
  target_group_port     = 31380
  target_group_port_https = 32001
  health_check_interval = 30
  health_check_timeout  = 5
  health_check_port     = "traffic-port"
  healthy_threshold     = 3
  unhealthy_threshold   = 4
  additional_tags         = { Name = "Istio Public", environment = "Sandbox", product = "LTS Infrastructure" }
}

module "alb_istio_server" {
  alb_vpc_id            = var.vpc_id
  alb_subnet_id         = ["subnet-0430ccd74062f252d", "subnet-00c239cfa0a160dfe"]
  allowed_subnets       = ["128.103.24.79/32","128.103.224.79/32","10.1.79.0/24"]
  ingress_ip            = ["10.140.210.69", "10.140.210.6", "10.140.210.7"]     # Change: Add server and worker IPs
  health_check_path     = "/"
  certificate_arn       = "arn:aws:acm:us-east-1:086178843174:certificate/a4134b83-712a-4c2c-93ae-652cfd993177"
  security_group_name   = "sb_alb_sg_srv"
  additional_certs      = []
  lb_name               = "istiolb-server"
  listener_port         = 80
  listener_protocol     = "HTTP"
  source                = "../../terraform-modules/alb"
  target_group_name     = "lts-server-tgt-grp"                           # Change: HTTP target group
  target_group_name_https     = "lts-server-tgt-grp-https"                     # Change: HTTPS target group
  target_group_port     = 31381
  target_group_port_https = 32003
  health_check_interval = 30
  health_check_timeout  = 5
  health_check_port     = "traffic-port"
  healthy_threshold     = 3
  unhealthy_threshold   = 4
  internal              = true
  additional_tags         = { Name = "Istio Server", environment = "Sandbox", product = "LTS Infrastructure" }
}

module "alb_istio_private" {
  alb_subnet_id         = ["subnet-0430ccd74062f252d", "subnet-00c239cfa0a160dfe"]
  alb_vpc_id            = var.vpc_id
  allowed_subnets       = ["128.103.24.79/32","128.103.224.79/32","10.1.79.0/24","10.140.210.0/24","10.140.210.6/32", "10.140.210.7/32", "10.140.210.69/32"]
  ingress_ip            = ["10.140.210.69", "10.140.210.6", "10.140.210.7"]     # Change: Add server and worker IPs
  health_check_path     = "/"
  certificate_arn       = "arn:aws:acm:us-east-1:086178843174:certificate/a4134b83-712a-4c2c-93ae-652cfd993177"
  security_group_name   = "sb_alb_sg_priv"
  additional_certs      = []
  lb_name               = "istiolb-private"
  listener_port         = 80
  listener_protocol     = "HTTP"
  source                = "../../terraform-modules/alb"
  target_group_name     = "lts-private-tgt-grp"                           # Change: HTTP target group
  target_group_name_https     = "lts-private-tgt-grp-https"                     # Change: HTTPS target group
  target_group_port     = 31382
  target_group_port_https = 32002
  health_check_interval = 30
  health_check_timeout  = 5
  health_check_port     = "traffic-port"
  healthy_threshold     = 3
  unhealthy_threshold   = 4
  internal              = true
  additional_tags         = { Name = "Istio API Private", environment = "Sandbox", product = "LTS Infrastructure" }
}

module "alb_console" {
  alb_subnet_id         = ["subnet-0430ccd74062f252d", "subnet-00c239cfa0a160dfe"]
  alb_vpc_id            = var.vpc_id
  allowed_subnets       =  ["128.103.24.79/32","128.103.224.79/32","10.1.79.0/24"]
  certificate_arn       = "arn:aws:acm:us-east-1:086178843174:certificate/a4134b83-712a-4c2c-93ae-652cfd993177"
  additional_certs      = []
  health_check_interval = 30
  health_check_path       = "/"
  health_check_port       = "traffic-port"
  health_check_timeout    = 5
  healthy_threshold       = 3
  ingress_ip              = ["10.140.210.69"] # add the server IPs
  lb_name                 = "cluster-console-sb"
  listener_port           = "443"
  listener_protocol       = "HTTPS"
  security_group_name     = "alb_console_sg_sb"
  source                  = "../../terraform-modules/alb"
  target_group_name       = "console-target-sb-http"
  target_group_name_https = "console-target-sb-https"
  target_group_port_https = 443
  unhealthy_threshold     = 4
  additional_tags         = { waf-type = "exception-alb", waf-custom = "exclude-oscmdinj-webappvul", waf-exception-request = "INC05464766", Name = "Cluster Console", environment = "Sandbox", product = "LTS Infrastructure" }
}

module "alb_deployment" {
  alb_subnet_id         = ["subnet-0430ccd74062f252d", "subnet-00c239cfa0a160dfe"]
  alb_vpc_id            = var.vpc_id
  allowed_subnets       =  ["128.103.24.79/32","128.103.224.79/32","10.1.79.0/24"]
  certificate_arn       = "arn:aws:acm:us-east-1:086178843174:certificate/da5fecdd-3c2a-4db4-8e7e-02efc9133b36"
  additional_certs        = []
  health_check_interval = 30
  health_check_path       = "/"
  health_check_port       = "traffic-port"
  health_check_timeout    = 5
  healthy_threshold       = 3
  ingress_ip              = ["10.140.210.69","10.140.210.6", "10.140.210.7"] # add the server IPs
  lb_name                 = "cluster-deploy-sb"
  listener_port           = "443"
  listener_protocol       = "HTTPS"
  security_group_name     = "alb_deployment_sg_sb"
  source                  = "../../terraform-modules/alb"
  target_group_name       = "deployment-target-http"
  target_group_name_https = "deployment-target-https"
  target_group_port_https = 30446
  unhealthy_threshold     = 4
  additional_tags         = {Name = "Deployment", environment = "Development", product = "LTS Infrastructure" }
}

module "alb_logging" {
  alb_subnet_id         = ["subnet-0430ccd74062f252d", "subnet-00c239cfa0a160dfe"] # 10.140.208.64/26  10.140.208.0/26 add the env subnets
  alb_vpc_id            = var.vpc_id
  allowed_subnets       =  ["128.103.24.79/32","128.103.224.79/32","10.1.79.0/24"]
  certificate_arn       = "arn:aws:acm:us-east-1:086178843174:certificate/5c1e2162-a70c-413c-aa3f-01efbc04a7ed"
  additional_certs      = []   
  health_check_interval = 30
  health_check_path       = "/"
  health_check_port       = "443"
  health_check_timeout    = 5
  healthy_threshold       = 3
  ingress_ip              = ["10.140.210.10", "10.140.210.71", "10.140.210.13"]
  lb_name                 = "cluster-logging-sb"
  listener_port           = "443"
  listener_protocol       = "HTTPS"
  security_group_name     = "alb_logging_sb"
  source                  = "../../terraform-modules/alb"
  target_group_name       = "logging-target-http"
  target_group_name_https = "logging-target-https"
  target_group_port_https = 32001
  unhealthy_threshold     = 5
  additional_tags         = {Name = "K8S Logging", environment = "Development", product = "LTS Infrastructure" }
}

#DEPLOYMENT DNS
module "route53_deployment_alias" {
  source                = "../../terraform-modules/route53"
  aws_route53_zone_name = "hz-sand.lib.harvard.edu"
  use_cname             = false
  alias_name            = "deployment-sand"
  aws_route53_record    = module.alb_deployment.alb_dns_name
  zone_id               = "Z064914927D9U8MUM38IN"
}

#LOGGING DNS
module "route53_logging_alias" {
  source                = "../../terraform-modules/route53"
  aws_route53_zone_name = "hz-sand.lib.harvard.edu"
  use_cname             = false
  alias_name            = "logging-sand"
  aws_route53_record    = module.alb_logging.alb_dns_name
  zone_id               = "Z064914927D9U8MUM38IN"
}

#RANCHER DNS
module "route53_rancher_alias" {
  source                = "../../terraform-modules/route53"
  aws_route53_zone_name = "hz-sand.lib.harvard.edu"
  use_cname             = false
  alias_name            = "rancher-sand"
  aws_route53_record    = module.alb_console.alb_dns_name
  zone_id               = "Z064914927D9U8MUM38IN"
}

module "argocd_secret_manager" {
  password_length     = 16
  source              = "../../terraform-modules/aws-secrets-manager/"
  secret_manager_name = "sandbox1_harvard_lts_rke_argocd"
}

module "secret_manager" {
  password_length     = 16
  source              = "../../terraform-modules/aws-secrets-manager/"
  secret_manager_name = "sandbox1_harvard_lts_rke_rancher"
}
