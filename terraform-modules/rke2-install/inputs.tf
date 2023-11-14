#data source fetch the subnet cidr

data "template_file" "user_data_agent" {
  template = file("${path.module}/templates/userdata_agent.sh")

  vars = {
    efs_mount      = var.efs_mount
    hostname       = var.hostname
    rancher_ip = aws_instance.rke2_server.private_ip,
    rke_version     = var.rke_version
    s3_bucket_name = aws_s3_bucket.bucket.bucket,

  }
}

## SJ
data "template_file" "user_data_server" {
  template = file("${path.module}/templates/userdata_server.sh") #file(var.userdata_server_template_file)

  vars = {
    argocd_version  = var.argocd_version
    certmanager_version  = var.certmanager_version
    efs_mount       = var.efs_mount
    eso_version     = var.eso_version
    hostname        = var.hostname
    istio_version   = var.istio_version
    loki_version    = var.loki_version
    rancher_backup_version = var.rancher_backup_version           # Added rancher backup version
    rancher_password = var.rancher_password #aws_secretsmanager_secret_version.rancher_password.secret_string
    rancher_version   = var.rancher_version
    rke_version       = var.rke_version
    s3_bucket_name    = aws_s3_bucket.bucket.bucket
    env_prefix = var.env_prefix
  }
}
