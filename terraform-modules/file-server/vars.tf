

variable "ami_id" {
  description = "AMI ID for the instance"
  type        = string
  default     = ""
}

variable "env_prefix" {
  description = "Env prefix for EC2 instance"
  type        = string
}

variable "environment_name" {
  description = "Tag for the environment deployment"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "instance_count" {
  description = "Number of RKE2 agent instances to create"
  type        = number
}

variable "hostname" {
  description = "hostname of the rancher ui"
  type        = string
}

variable "loadbalancer_subnets" {
  description = "subnets per environment"
  type = list
}

variable "private_ip" {
  description = "ip address of the agent (the instance would pick from the list based on the current index of the array)"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "harvard-lts-oteemo-node"
}

variable "subnet_id" {
  description = "subnet id to deploy the server"
  type        = string
}


variable "tower_subnets" {
  description = "subnets for Ansible Tower"
  type = list
}

variable "userdata_agent_template_file" {
  description = "Path to the userdata_agent.sh template file"
  type        = string
}

variable "volume_size" {
  description = "Size of the EBS volume in GB"
  type        = number
}

variable "volume_type" {
  description = "Type of the EBS volume in GB"
  type        = string
}

variable "vpc_id" {
  description = "VPC id for or per environment"  
  type = string
}

variable "worker_subnets" {
  description = "subnets per environment"
  type = list
}

