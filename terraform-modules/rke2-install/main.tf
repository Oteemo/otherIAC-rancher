resource "aws_instance" "rke2_agent" {
  count                   = var.instance_count            # Variable for agent instance count
  ami                     = var.ami_id
  associate_public_ip_address = false
  ebs_block_device {
    device_name           = "/dev/sda1"
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    delete_on_termination = true
  }
  iam_instance_profile    = aws_iam_instance_profile.agent.name
  instance_type           = var.instance_type             # Variable for agent instance type
  metadata_options {
    http_tokens = "required"
  }
  monitoring              = true
  private_ip              = var.agent_private_ips[count.index]
  subnet_id               = var.node_agent_subnet_id
  vpc_security_group_ids = [aws_security_group.allow_vpn_ingress_to_rke.id]
  user_data            = data.template_file.user_data_agent.rendered
  user_data_replace_on_change = true
  #if the array = ["10.0.0.1", ""10.0.0.2"]
  tags = {
    Name = "rke2_${var.env_prefix}_agent_${count.index + 1}"
    product = "DevSecOps"
    environment = var.environment_name
    Created = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())
 }
   lifecycle {
    ignore_changes = [
      tags["Created"],
    ]
  }
}

resource "aws_instance" "rke2_server" {
  ebs_block_device {
    device_name           = "/dev/sda1"
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    delete_on_termination = true
  }

  ami                  = var.ami_id
  iam_instance_profile = aws_iam_instance_profile.server.name
  instance_type        = var.server_instance_type                  # Variable for agent instance type
  metadata_options {
    http_tokens = "required"
  }
  monitoring           = true
  private_ip           = var.server_private_ip
  subnet_id            = var.server_subnet_id
  user_data            = data.template_file.user_data_server.rendered
  vpc_security_group_ids = [aws_security_group.allow_vpn_ingress_to_rke.id]
  tags = {
    Name = "rke2_${var.env_prefix}_server_1"
    product = "DevSecOps"
    environment = var.environment_name
    Created = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())
  }
  lifecycle {
    ignore_changes = [
      tags["Created"],
    ]
  }
}

####################################################################################
### Add other server nodes
####################################################################################

resource "aws_instance" "rke2_other_server" {
  count = var.server_instance_count
  ebs_block_device {
    device_name           = "/dev/sda1"
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    delete_on_termination = true
  }
  ami                  = var.ami_id
  iam_instance_profile = aws_iam_instance_profile.server.name
  instance_type        = var.server_instance_type
  metadata_options {
    http_tokens = "required"
  }
  monitoring           = true
  private_ip           = var.server_other_ips[count.index]
  subnet_id              = var.server_subnet_id
  user_data              = data.template_file.other_data_server.rendered      # Change:  Use new seed script just for servers
  vpc_security_group_ids = [aws_security_group.allow_vpn_ingress_to_rke.id]
  tags                   = {
    Name        = "rke2_${var.env_prefix}_server_${count.index + 2}"
    product     = "DevSecOps"
    environment = var.environment_name
    Created     = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket        = var.s3_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

#security group.tf
resource "aws_security_group" "allow_vpn_ingress_to_rke" {
  name        = "allow_vpn_ingress_to_rke-${random_integer.random_resource.result}"
  description = "Allow inbound traffic from vpn to rke instances"
  vpc_id      =  var.vpc_id

  ingress {
    description = "SSH inbound from VPN"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.1.79.0/24"]    
  }
  
    ingress {
    description = "Any source that needs to be able to use the Rancher UI or API"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.worker_subnets
  }
  
    ingress {
    description = "Load Balancer access to the Rancher UI or API"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.loadbalancer_subnets    
  }


  ingress {
    description = "NodePort port range"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = var.worker_subnets
  }

  ingress {
    description = "NodePort port range"
    from_port   = 30000
    to_port     = 32767
    protocol    = "udp"
    cidr_blocks = var.worker_subnets
  }

  ingress {
    description = "NodePort port range"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = var.worker_subnets
  }

  ingress {
    description = "NodePort port range"
    from_port   = 31380
    to_port     = 31380
    protocol    = "tcp"
    cidr_blocks = var.loadbalancer_subnets
  }

  ingress {
    description = "HTTPS access from ALB to nodes"
    from_port   = 32001
    to_port     = 32003
    protocol    = "tcp"
    cidr_blocks = var.loadbalancer_subnets
  }

  ingress {
    description = "Load balancer/proxy that does external SSL termination"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.worker_subnets
  }

  ingress {
    description = "Req for K8S"
    from_port   = 9091
    to_port     = 9091
    protocol    = "tcp"
    cidr_blocks = var.worker_subnets
  }
  
  ingress {
    description = "etcd peer communication and etcd client requests"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = var.worker_subnets
  }
  
  ingress {
    description = "Req for K8S"
    from_port   = 2376
    to_port     = 2376
    protocol    = "tcp"
    cidr_blocks = var.worker_subnets
  }
  
  ingress {
    description = "RKE2 server needs port 6443 for accessible by other nodes in the cluster"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = var.worker_subnets
  }

  ingress {
    description = "Req for K8S"
    from_port   = 10254
    to_port     = 10254
    protocol    = "tcp"
    cidr_blocks = var.worker_subnets
  }

  ingress {
    description = "ArgoCD port to ALB"
    from_port   = 30446
    to_port     = 30446
    protocol    = "tcp"
    cidr_blocks = var.loadbalancer_subnets
  }

  ingress {
    description = "RKE2 server and agent nodes"
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = var.worker_subnets
  }

  ingress {
    description = "RKE2 server needs port 9345 for accessible by other nodes in the cluster"
    from_port   = 9345
    to_port     = 9345
    protocol    = "tcp"
    cidr_blocks = var.worker_subnets
  }

  ingress {
    description = "Access from Ansible Tower for patching"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.tower_subnets 
  }



  egress {
    from_port        = 0 
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Worker Subnets"
  }
}

