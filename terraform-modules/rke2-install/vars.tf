variable "agent_private_ips" {
  description = "ip address of the agent (the instance would pick from the list based on the current index of the array)"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the instance"
  type        = string
  default     = ""
}

variable "certmanager_version" {
  description = "certmanager version"
  type        = string
}

variable "efs_mount" {
  description = "EFS Mount" 
  type        = string
}

variable "env_prefix" {
  description = "Env prefix for EC2 instance"
  type        = string
}

variable "environment_name" {
  description = "Tag for the environment deployment"
  type        = string
}

variable "instance_count" {
  description = "Number of RKE2 agent instances to create"
  type        = number
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "istio_version" {
  description = "Istio version for Service Mesh "
  type        = string
}

variable "group_id1" {
  description = "Group id for mount points"
  type        = string
}

variable "group_id2" {
  description = "Group id for mount points"
  type        = string
}

variable "hostname" {
  description = "hostname of the rancher ui"
  type        = string
}

variable "key_pair_name_prefix" {
  description = "Prefix for the key pair name"
  type        = string
}

variable "loadbalancer_subnets" {
  description = "subnets per environment"
  type = list
}

variable "loki_version" {
  description = "LOKI PLG stack version"
  type        = string
}

variable "node_agent_subnet_id" {
  description = "subnet id to deploy the server"
  type        = string
}

#SJ : Added rancher backup version
variable "rancher_backup_version" {
  description = "Rancher Backup version"
  type        = string
}

variable "rancher_monitoring_version" {
  description = "Rancher Monitoring version"
  type        = string
}

variable "rancher_password" {
  description = "Rancher password this is just placeholder for the password. The password will be called from teh module that created it so it is not exposed to the script"
  type        = string
  default     = ""
}

variable "rancher_version" {
  description = "Rancher version"
  type        = string
}

variable "rke_version" {
  description = "RKE version for server"
  type        = string
  default     = "v1.24"
}

variable "rsa_bits" {
  description = "Number of bits for RSA key generation"
  type        = number
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "server_instance_count" {
  description = "Number of RKE2 server instances to create"
  type        = number
}

variable "server_instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "server_private_ip" {
  description = "ip address of the server"
  type        = string
}

variable "server_other_ips" {
  description = "ip address of the server"
  type        = list(string)
}

variable "server_subnet_id" {
  description = "subnet id to deploy the server"
  type        = string
}

variable "userdata_server_template_file" {
  description = "Path to the userdata_server.sh template file"
  type        = string
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

# Rename sandbox_subnet to worker.
variable "worker_subnets" {
  description = "subnets per environment"
  type = list
}

# Ansible Tower subnets for patching.
variable "tower_subnets" {
  description = "subnets for Ansible Tower"
  type = list
}

# Logicmonitor subnets.
variable "logicmon_subnets" {
  description = "subnets for Logicmonitor"
  type = list
}

variable "criticality" {
  description = "Used to identify the criticality of the resource"
  type        = string
}

variable "hosted_by" {
  description = "Used to identify the hosting group"
  type        = string
}

variable "level4" {
  description = "Used to identify the non/level4 subnet"
  type        = string
}