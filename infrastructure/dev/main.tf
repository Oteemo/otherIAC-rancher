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
  }
}

provider "aws" {
  region = "us-east-1"
}

module "argocd_secret_manager" {
  password_length     = 16
  secret_manager_name = "dev_harvard_lts_rke_argocd"
  source              = "../../terraform-modules/aws-secrets-manager/"
}

module "rke2" {
  agent_private_ips             = ["10.138.22.90", "10.138.22.91","10.138.22.100","10.138.22.101","10.138.22.102","10.138.22.93","10.138.22.103","10.138.22.104","10.138.22.105"]
  #agent_private_ips             = ["10.138.22.90", "10.138.22.91","10.138.22.100","10.138.22.101","10.138.22.102","10.138.22.93"]
  alb_sg_id                     = module.alb_istio_public.alb_security_group_id
  ami_id                        = data.aws_ami.latest_patched_ami.id
  certmanager_version           = var.certmanager_version                                    # Cert Manager version
  criticality                   = "Non-Critical"  
  efs_mount                     = "fs-0afca58a6112bf240.efs.us-east-1.amazonaws.com"  # Change: Add EFS mount name
  environment_name              = "Development"
  env_prefix                    = "dev"
  group_id1                     = "1636"
  group_id2                     = "199"
  hosted_by                     = "LTS"
  hostname                      = var.hostname               # Change: Add console DNS name
  instance_count                = 9
  instance_type                 = "c5.4xlarge"
  istio_version                 = var.istio_version
  key_pair_name_prefix          = "dev-HarvardLTS-oteemo"
  level4                        = "nonlevel4"
  loadbalancer_subnets			= ["10.138.16.0/24","10.138.29.0/24","10.138.17.0/24","10.138.19.0/25","10.138.18.0/25","10.138.18.128/25"] # Includes public and internal only subnets for load balancers.
  loki_version                  = "2.9.11"
  node_agent_subnet_id          = "subnet-bee95ef7"                           # Change: Agents subnet id
  rancher_backup_version        = var.rancher_backup_version
  #rancher_monitoring_version    = "104.0.0+up45.31.1"
  rancher_monitoring_version    = var.rancher_monitoring_version
  rancher_password              = data.aws_secretsmanager_secret_version.rancher_password.secret_string
  rancher_version               = var.rancher_version       # 2.10.2
  rke_version                   = var.rke_version
  rsa_bits                      = 4096
  s3_bucket_name                = "dev-harvard-lts-oteemo-node"
  server_instance_count         = 2                                             # Change: server count
  server_instance_type          = var.server_instance_type
  server_other_ips              = ["10.138.21.161","10.138.21.162"]             # Change: Other server IPs
  server_private_ip             = "10.138.21.160"                               # Change: Add server IPs
  # Add server subnet
  server_subnet_id              = "subnet-b205c19f"
  source                        = "../../terraform-modules/rke2-install/"
  userdata_agent_template_file  = "templates/userdata_agent.sh"
  userdata_server_template_file = "templates/userdata_server.sh"
  volume_size                   = 140
  volume_type                   = "gp3"
  vpc_id                        = var.vpc_id
  # Rename sandbox to worker
  worker_subnets				= ["10.138.21.0/24","10.138.22.0/24","10.138.23.0/24","10.1.79.0/24"]
  tower_subnets                 = ["10.137.242.0/25"]
  logicmon_subnets              = ["10.34.64.128/26", "10.137.242.0/26", "10.34.64.64/26"]
}

module "alb_istio_public" {
  alb_subnet_id         = ["subnet-b005c19d","subnet-bce95ef5"] #Internal only subnets. 
  alb_vpc_id            = var.vpc_id
  allowed_subnets       = ["10.1.79.0/24","10.138.22.90/32", "10.138.22.91/32","10.138.22.100/32","10.138.22.101/32","10.138.22.102/32","10.138.22.93/32","10.138.21.16/32","10.138.21.161/32","10.138.21.162/32","10.1.65.0/24"]
  certificate_arn       = "arn:aws:acm:us-east-1:217428790895:certificate/27df129c-7914-493c-b32d-81da3d88b9e7"
  additional_certs      = ["arn:aws:acm:us-east-1:217428790895:certificate/b9b53ef8-c904-4a1a-beb0-67c530592fe0","arn:aws:acm:us-east-1:217428790895:certificate/36ff0a31-692c-426d-ba6b-909e52584394","arn:aws:acm:us-east-1:217428790895:certificate/cb18d655-9c73-45d7-8944-b8275ef2722f","arn:aws:acm:us-east-1:217428790895:certificate/e40c0aa3-3868-4dbd-9b64-47752c6c9c75","arn:aws:acm:us-east-1:217428790895:certificate/e100726e-f92b-4bd0-8d47-0f12bf99b324","arn:aws:acm:us-east-1:217428790895:certificate/d812d637-194c-4f96-8493-cbfec9f747a9","arn:aws:acm:us-east-1:217428790895:certificate/d5dbd13f-66e0-45b5-9474-3e5575e61b4a","arn:aws:acm:us-east-1:217428790895:certificate/876ac7b3-b4f6-449e-90f6-036d215da1a5","arn:aws:acm:us-east-1:217428790895:certificate/52b9af90-39ec-4d0a-bee0-4e6c73d56909","arn:aws:acm:us-east-1:217428790895:certificate/516df022-0210-44ae-8fdf-2d98f669b853","arn:aws:acm:us-east-1:217428790895:certificate/0f2fc76d-42e3-4fa6-927d-2bdb17649f02","arn:aws:acm:us-east-1:217428790895:certificate/c1fa5210-e9cf-4429-abcd-db35e5f38e86","arn:aws:acm:us-east-1:217428790895:certificate/0aacf9ac-3e61-4c28-a0de-a0504c71820e","arn:aws:acm:us-east-1:217428790895:certificate/d32d13fe-a49d-45c8-8986-1d5134b03b3a","arn:aws:acm:us-east-1:217428790895:certificate/97fd65e4-332c-4e6a-b27b-401cae2d72b1","arn:aws:acm:us-east-1:217428790895:certificate/95dffe6b-62d5-4215-be71-21b7ddf0c4e9","arn:aws:acm:us-east-1:217428790895:certificate/47ad7270-8884-4a1c-b7d5-920f194e23d0","arn:aws:acm:us-east-1:217428790895:certificate/1258aed1-3c61-4871-b29c-36d485151879","arn:aws:acm:us-east-1:217428790895:certificate/77c767e7-1e3c-4589-873b-8468bbf9f918","arn:aws:acm:us-east-1:217428790895:certificate/6c95afc9-7a9f-4e88-b1dd-c06d3e3c3abf","arn:aws:acm:us-east-1:217428790895:certificate/9cdfecbe-d7e2-42b9-bf23-5774273e892b","arn:aws:acm:us-east-1:217428790895:certificate/b582cadd-4bff-4cae-ab22-bfa7cd10542f","arn:aws:acm:us-east-1:217428790895:certificate/1ecd3e7c-868e-4a1c-86d0-6aeb6698780d","arn:aws:acm:us-east-1:217428790895:certificate/765db4fa-8cba-40f3-af2c-ef449c9ba7ec","arn:aws:acm:us-east-1:217428790895:certificate/58078b79-f3a7-4dd4-8375-a565e2557ac2","arn:aws:acm:us-east-1:217428790895:certificate/3fc90332-1bac-499c-9c67-e317db4adea4","arn:aws:acm:us-east-1:217428790895:certificate/d4e40a14-4986-4a1d-adcf-854c6282e726","arn:aws:acm:us-east-1:217428790895:certificate/af05470c-8935-47fa-826f-55b43a2ec4dc","arn:aws:acm:us-east-1:217428790895:certificate/7f5b022b-85a8-4795-9f87-987abc7e4e71"]
  health_check_interval = 30
  health_check_path     = "/"
  health_check_port     = "traffic-port"
  health_check_timeout  = 5
  healthy_threshold     = 3
  ingress_ip            = ["10.138.22.90", "10.138.22.91","10.138.22.100","10.138.22.101","10.138.22.102","10.138.22.93","10.138.21.160","10.138.21.161","10.138.21.162","10.138.22.103","10.138.22.104","10.138.22.105"]
  #ingress_ip            = ["10.138.22.90", "10.138.22.91","10.138.22.100","10.138.22.101","10.138.22.102","10.138.22.93","10.138.21.160","10.138.21.161","10.138.21.162"]
  lb_name               = "dev-istiolb"
  listener_port         = 80
  listener_protocol     = "HTTP"
  security_group_name   = "dev_alb_sg"
  feedback_url          = "feedback-srv-dev.lib.harvard.edu"
  id_url                = "id-dev.lib.harvard.edu"
  source                = "../../terraform-modules/alb-public"
  # Change this to your env target group
  target_group_name         = "dev-lts-tgt-grp"
  target_group_name_https   = "dev-lts-tgt-grp-https"
  target_group_port     = 31380
  target_group_port_https = 32001
  ##  CHECK HTTPS PORT
  internal              = true
  unhealthy_threshold   = 4
  additional_tags         = { Name = "Istio Public", environment = "Development", product = "LTS Infrastructure" }
}

module "alb_istio_server" {
  alb_subnet_id         = ["subnet-bce95ef5","subnet-b005c19d"]
  alb_vpc_id            = var.vpc_id
  certificate_arn       = "arn:aws:acm:us-east-1:217428790895:certificate/27df129c-7914-493c-b32d-81da3d88b9e7"
  additional_certs      = ["arn:aws:acm:us-east-1:217428790895:certificate/32c89f17-ae71-4e40-8702-b24e5e5f6e5b","arn:aws:acm:us-east-1:217428790895:certificate/aeeef261-9764-41de-afa8-e7304f6e4ef1","arn:aws:acm:us-east-1:217428790895:certificate/aac362e5-db32-47ad-a9b6-3b4efca2b861","arn:aws:acm:us-east-1:217428790895:certificate/c5f40aab-dec8-4ae2-9734-c5bb82f6b20b","arn:aws:acm:us-east-1:217428790895:certificate/47c42a47-d137-4652-b769-9cea221c510d","arn:aws:acm:us-east-1:217428790895:certificate/c8932632-559c-4eb1-90c7-f460c30de90c","arn:aws:acm:us-east-1:217428790895:certificate/16ceadfe-a07e-49f0-bf85-0b84a6d183ab"]
  health_check_interval = 30
  health_check_path     = "/"
  health_check_port     = "traffic-port"
  health_check_timeout  = 5
  healthy_threshold     = 3
  ingress_ip            = ["10.138.22.90", "10.138.22.91","10.138.22.100","10.138.22.101","10.138.22.102","10.138.22.93","10.138.21.160","10.138.21.161","10.138.21.162","10.138.22.103","10.138.22.104","10.138.22.105"]
  #ingress_ip            = ["10.138.22.90", "10.138.22.91","10.138.22.100","10.138.22.101","10.138.22.102","10.138.22.93","10.138.21.160","10.138.21.161","10.138.21.162"]
  allowed_subnets       = ["10.1.79.0/24","10.138.21.160/32","10.138.21.161/32","10.138.21.162/32","10.138.22.100/32","10.138.22.101/32","10.138.22.102/32","10.138.22.90/32","10.138.22.91/32","10.138.22.93/32"]
  lb_name               = "dev-istiolb-server"
  listener_port         = 80
  listener_protocol     = "HTTP"
  security_group_name   = "dev_alb_sg_srv"
  source                = "../../terraform-modules/alb"
  target_group_name         = "dev-srv-lts-tgt-grp"
  target_group_name_https   = "dev-srv-lts-tgt-grp-https"
  target_group_port       = 31381
  target_group_port_https = 32003
  internal              = true
  unhealthy_threshold   = 4
  additional_tags         = { Name = "Istio Server", environment = "Development", product = "LTS Infrastructure" }
}

module "alb_istio_apiprivate" {
  alb_subnet_id         = ["subnet-bce95ef5","subnet-b005c19d"]
  alb_vpc_id            = var.vpc_id
  certificate_arn       = "arn:aws:acm:us-east-1:217428790895:certificate/27df129c-7914-493c-b32d-81da3d88b9e7"
  additional_certs      = ["arn:aws:acm:us-east-1:217428790895:certificate/47c42a47-d137-4652-b769-9cea221c510d"]
  health_check_interval = 30
  health_check_path     = "/"
  health_check_port     = "traffic-port"
  health_check_timeout  = 5
  healthy_threshold     = 3
  ingress_ip            = ["10.138.22.90", "10.138.22.91","10.138.22.100","10.138.22.101","10.138.22.102","10.138.22.93","10.138.21.160","10.138.21.161","10.138.21.162","10.138.22.103","10.138.22.104","10.138.22.105"]
  #ingress_ip            = ["10.138.22.90", "10.138.22.91","10.138.22.100","10.138.22.101","10.138.22.102","10.138.22.93","10.138.21.160","10.138.21.161","10.138.21.162"]
  allowed_subnets       = ["10.144.32.0/22","10.1.79.0/24"] #includes apigee-x-dev INC05362131
  lb_name               = "dev-istiolb-apiprivate"
  listener_port         = 80
  listener_protocol     = "HTTP"
  security_group_name   = "dev_alb_sg_api"
  source                = "../../terraform-modules/alb"
  #target_group_name         = "dev-srv-lts-tgt-grp"
  target_group_name_https   = "dev-api-lts-tgt-grp-https"
  target_group_port       = 31383
  target_group_port_https = 32004
  internal              = true
  unhealthy_threshold   = 4
  additional_tags         = { Name = "Istio API Private", environment = "Development", product = "LTS Infrastructure" }
}

module "alb_istio_private" {
  alb_subnet_id         = ["subnet-b005c19d","subnet-bce95ef5"] #Internal only subnets. 
  alb_vpc_id            = var.vpc_id
  allowed_subnets       = ["10.1.79.0/24","10.138.22.90/32","10.138.22.91/32","10.138.22.100/32","10.138.22.101/32","10.138.22.102/32","10.138.22.93/32","10.138.21.16/32","10.138.21.161/32","10.138.21.162/32","10.1.65.0/24"]
  certificate_arn       = "arn:aws:acm:us-east-1:217428790895:certificate/27df129c-7914-493c-b32d-81da3d88b9e7"
  additional_certs      = ["arn:aws:acm:us-east-1:217428790895:certificate/e57459b7-6b68-4db2-a162-09bea5d9c176","arn:aws:acm:us-east-1:217428790895:certificate/1ecd3e7c-868e-4a1c-86d0-6aeb6698780d","arn:aws:acm:us-east-1:217428790895:certificate/9a7ee40f-88e6-4132-9de3-b3ce5b99b4fa","arn:aws:acm:us-east-1:217428790895:certificate/c5f40aab-dec8-4ae2-9734-c5bb82f6b20b","arn:aws:acm:us-east-1:217428790895:certificate/aac362e5-db32-47ad-a9b6-3b4efca2b861","arn:aws:acm:us-east-1:217428790895:certificate/743c6ba8-24e1-45f5-a1b7-8af4ecca5694","arn:aws:acm:us-east-1:217428790895:certificate/0b754844-612e-4841-b71e-6d0a33cdce49","arn:aws:acm:us-east-1:217428790895:certificate/a6a57d90-a77e-4077-a8d8-a4d1d4f0227a","arn:aws:acm:us-east-1:217428790895:certificate/579e4be9-a646-42f3-9396-4309da454671","arn:aws:acm:us-east-1:217428790895:certificate/5591c76a-4abe-403e-8143-717dd1b1c04e","arn:aws:acm:us-east-1:217428790895:certificate/7690f097-1147-47cb-a5ad-7aaa81628517","arn:aws:acm:us-east-1:217428790895:certificate/356dfaa2-6a2c-464e-9149-e9bc9d7b4167","arn:aws:acm:us-east-1:217428790895:certificate/5900b129-36e9-439f-82ce-48d376aaad8d","arn:aws:acm:us-east-1:217428790895:certificate/f280e08e-0b0d-4096-87dc-a8bd013396ee","arn:aws:acm:us-east-1:217428790895:certificate/0da55bf7-d280-4a1d-8d29-5820a3519e47","arn:aws:acm:us-east-1:217428790895:certificate/ceef3b8c-9f99-42e8-99a9-4cdaadd6be32","arn:aws:acm:us-east-1:217428790895:certificate/410b4449-c99d-4a8a-82d8-db6c8777c755","arn:aws:acm:us-east-1:217428790895:certificate/47d2a9db-0795-4985-a20c-b75e66e5c472","arn:aws:acm:us-east-1:217428790895:certificate/96abaeb1-7d4c-4084-bfc4-a91e769abd45","arn:aws:acm:us-east-1:217428790895:certificate/76d86a6a-6ce9-4b92-8f6f-286c03486e32"]
  health_check_interval = 30
  health_check_path     = "/"
  health_check_port     = "traffic-port"
  health_check_timeout  = 5
  healthy_threshold     = 3
  # Add the server and node IPs
  ingress_ip            = ["10.138.22.90", "10.138.22.91","10.138.22.100","10.138.22.101","10.138.22.102","10.138.22.93","10.138.21.160","10.138.21.161","10.138.21.162","10.138.22.103","10.138.22.104","10.138.22.105"]
  #ingress_ip            = ["10.138.22.90", "10.138.22.91","10.138.22.100","10.138.22.101","10.138.22.102","10.138.22.93","10.138.21.160","10.138.21.161","10.138.21.162"]
  lb_name               = "dev-istiolb-private"
  listener_port         = 443
  listener_protocol     = "HTTPS"
  security_group_name   = "dev_alb_sg_priv"
  source                = "../../terraform-modules/alb"
  target_group_name         = "dev-lts-pvt-tgt-grp"
  target_group_name_https   = "dev-lts-pvt-tgt-grp-https"
  target_group_port     = 31382  #private should have no http listener
  target_group_port_https = 32002
  internal              = true
  unhealthy_threshold   = 4
  additional_tags         = { Name = "Istio Private", environment = "Development", product = "LTS Infrastructure" }
}

module "alb_console" {
  alb_subnet_id         = ["subnet-b005c19d","subnet-bce95ef5"] #Internal only subnets. 
  alb_vpc_id            = var.vpc_id
  certificate_arn       = "arn:aws:acm:us-east-1:217428790895:certificate/27df129c-7914-493c-b32d-81da3d88b9e7"
  additional_certs      = []
  health_check_interval = 30
  health_check_path       = "/"
  health_check_port       = "traffic-port"
  health_check_timeout    = 5
  healthy_threshold       = 3
  ingress_ip              = ["10.138.21.160","10.138.21.161","10.138.21.162"] # Management server IPs
  allowed_subnets         = ["10.1.79.0/24"]
  lb_name                 = "cluster-console-dev"
  listener_port           = "443"
  listener_protocol       = "HTTPS"
  security_group_name     = "alb_console_sg_dev"
  source                  = "../../terraform-modules/alb"
  target_group_name       = "console-target-dev-http"
  target_group_name_https = "console-target-dev-https"
  target_group_port_https = 443
  internal                = true
  unhealthy_threshold     = 4
  additional_tags         = { waf-type = "exception-alb", waf-custom = "exclude-oscmdinj-webappvul", waf-exception-request = "INC05464766", Name = "Cluster Console", environment = "Development", product = "LTS Infrastructure" }
}

module "alb_deployment" {
  alb_subnet_id         = ["subnet-b005c19d","subnet-bce95ef5"] #Internal only subnets. 
  alb_vpc_id            = var.vpc_id
  certificate_arn       = "arn:aws:acm:us-east-1:217428790895:certificate/cb8b4318-0174-4598-a6b4-ee67d5f7b986"
  additional_certs      = []                     
  health_check_interval = 30
  health_check_path       = "/"
  health_check_port       = "443"
  health_check_timeout    = 5
  healthy_threshold       = 3
  ingress_ip            = ["10.138.22.90", "10.138.22.91","10.138.22.100","10.138.22.101","10.138.22.102","10.138.22.93","10.138.21.160","10.138.21.161","10.138.21.162","10.138.22.103","10.138.22.104","10.138.22.105"]
  #ingress_ip              = ["10.138.21.160","10.138.21.161","10.138.21.162","10.138.22.90", "10.138.22.91","10.138.22.100","10.138.22.101","10.138.22.102","10.138.22.93"]
  allowed_subnets         = ["10.1.79.0/24"]
  lb_name                 = "cluster-deploy-dev"
  listener_port           = "443"
  listener_protocol       = "HTTPS"
  security_group_name     = "alb_deployment_sg_dev"
  source                  = "../../terraform-modules/alb"
  target_group_name       = "deployment-target-http"
  target_group_name_https = "deployment-target-https"
  target_group_port_https = 30446
  internal                = true
  unhealthy_threshold     = 4
  additional_tags         = {Name = "Deployment", environment = "Development", product = "LTS Infrastructure" }
}

module "alb_logging" {
  alb_subnet_id         = ["subnet-b005c19d","subnet-bce95ef5"] #Internal only subnets. 
  alb_vpc_id            = var.vpc_id
  certificate_arn       = "arn:aws:acm:us-east-1:217428790895:certificate/176dcdaa-fb59-4c3d-b379-bba77a8f8c7e"
  additional_certs      = []   
  health_check_interval = 30
  health_check_path       = "/"
  health_check_port       = "443"
  health_check_timeout    = 5
  healthy_threshold       = 3
  ingress_ip            = ["10.138.22.90", "10.138.22.91","10.138.22.100","10.138.22.101","10.138.22.102","10.138.22.93","10.138.21.160","10.138.21.161","10.138.21.162","10.138.22.103","10.138.22.104","10.138.22.105"]
  #ingress_ip              = ["10.138.21.160","10.138.21.161","10.138.21.162","10.138.22.90", "10.138.22.91","10.138.22.100","10.138.22.101","10.138.22.102","10.138.22.93"]
  allowed_subnets         = ["10.1.79.0/24"]
  lb_name                 = "cluster-logging-dev"
  listener_port           = "443"
  listener_protocol       = "HTTPS"
  security_group_name     = "alb_logging_dev"
  source                  = "../../terraform-modules/alb"
  target_group_name       = "logging-dev-target-http"
  target_group_name_https = "logging-dev-target-https"
  target_group_port_https = 32001
  internal                = true
  unhealthy_threshold     = 5
  additional_tags         = {Name = "K8S Logging", environment = "Development", product = "LTS Infrastructure" }
  
}


module "route53_istio_private_alias" {
  source                = "../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "istio_private"
  aws_route53_record    = module.alb_istio_private.alb_dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

module "route53_istio_public_alias" {
  source                = "../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "istio_public"
  aws_route53_record    = module.alb_istio_public.alb_dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

module "route53_istio_server_alias" {
  source                = "../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "istio_server"
  aws_route53_record    = module.alb_istio_server.alb_dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

#ALB Route 53 records
module "route53_deployment_alias" {
  source                = "../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "deployment-dev"
  aws_route53_record    = module.alb_deployment.alb_dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

module "route53_logging_alias" {
  source                = "../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "logging_dev"
  aws_route53_record    = module.alb_logging.alb_dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

module "route53_rancher_alias" {
  source                = "../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "rancher-dev"
  aws_route53_record    = module.alb_console.alb_dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

module "secret_manager" {
  password_length     = 16
  source              = "../../terraform-modules/aws-secrets-manager/"
  secret_manager_name = "dev_harvard_lts_rke_rancher"
}
