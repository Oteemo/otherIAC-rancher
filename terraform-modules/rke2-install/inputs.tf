#data source fetch the subnet cidr

data "template_file" "user_data_agent" {
  template = file("${path.module}/templates/userdata_agent.sh")

  vars = {
    efs_mount       = var.efs_mount
    group_id1        = var.group_id1
    group_id2        = var.group_id2
    hostname        = var.hostname
    rancher_ip      = aws_instance.rke2_server.private_ip
    rke_version     = var.rke_version
    s3_bucket_name  = aws_s3_bucket.bucket.bucket,
  }
}

data "template_file" "user_data_server" {
  template = file("${path.module}/templates/userdata_server-reduced.sh")

  vars = {

    certmanager_version  = var.certmanager_version
    efs_mount       = var.efs_mount
    env_prefix      = var.env_prefix
    environment_name= var.environment_name
    group_id1       = var.group_id1
    group_id2       = var.group_id2
    hostname        = var.hostname
    istio_version   = var.istio_version
    loki_version    = var.loki_version
    rancher_backup_version = var.rancher_backup_version           # Added rancher backup version
    rancher_monitoring_version = var.rancher_monitoring_version
    rancher_password = var.rancher_password #aws_secretsmanager_secret_version.rancher_password.secret_string
    rancher_version  = var.rancher_version
    rke_version      = var.rke_version
    s3_bucket_name   = aws_s3_bucket.bucket.bucket
  }
}

data "template_file" "other_data_server" {
  template = file("${path.module}/templates/userdata_seed.sh") #file(var.userdata_server_template_file)

  vars = {
    certmanager_version   = var.certmanager_version
    efs_mount             = var.efs_mount
    env_prefix            = var.env_prefix
    group_id1             = var.group_id1
    group_id2             = var.group_id2
    hostname              = var.hostname
    istio_version         = var.istio_version
    loki_version          = var.loki_version
    rancher_backup_version = var.rancher_backup_version           # Added rancher backup version
    rancher_ip      = aws_instance.rke2_server.private_ip
    rancher_password = var.rancher_password #aws_secretsmanager_secret_version.rancher_password.secret_string
    rancher_version   = var.rancher_version
    rke_version       = var.rke_version
    s3_bucket_name    = aws_s3_bucket.bucket.bucket
  }
}