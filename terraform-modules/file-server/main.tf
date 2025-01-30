resource "aws_instance" "file_server" {
  ebs_block_device {
    device_name           = "/dev/sda1"
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    delete_on_termination = true
  }

  ami                  = var.ami_id
  iam_instance_profile = aws_iam_instance_profile.server.name
  instance_type        = var.instance_type             # Variable for agent instance type
  metadata_options {
    http_tokens = "required"
  }
  monitoring           = true
  private_ip           = var.private_ip
  subnet_id            = var.subnet_id
  user_data            = data.template_file.file_server_rhel.rendered
  vpc_security_group_ids = [aws_security_group.allow_vpn_ingress_to_fileserver.id]
  tags = {
    Name = "file_server_${var.env_prefix}_1"
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

#security group.tf
resource "aws_security_group" "allow_vpn_ingress_to_fileserver" {
  name        = "allow_vpn_ingress_to_github-${random_integer.random_resource.result}"
  description = "Allow inbound traffic from vpn to github"
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

