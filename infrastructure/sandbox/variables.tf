variable "certmanager_version" {
  description = "Cert Manager version"
  type        = string
}

variable "hostname" {
  description = "Cluster hostname"
  type        = string
}

variable "istio_version" {
  description = "Istio version for Service Mesh "
  type        = string
}

variable "rancher_version" {
  description = "Rancher version"
  type        = string
}

variable "rancher_backup_version" {
  description = "Rancher (packaged) Backup version"
  type        = string
}

variable "rancher_monitoring_version" {
  description = "Rancher (packaged) Monitoring version"
  type        = string
}

variable "rke_version" {
  description = "RKE version"
  #Equivalent to K8 version
  type        = string
}

variable "rancher_secret_name" {
  default = "sandbox1_rancher_secret_name"
}

variable server_instance_type {
  description = "AWS instance type for Server/Control nodes"
  type        = string
}

variable "vpc_id" {
  description = "VPC id for or per environment"
  type = string
}
