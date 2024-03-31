data "aws_secretsmanager_secret" "rancher_secret" {
  name       = "sandbox1_harvard_lts_rke_rancher"
  depends_on = [module.secret_manager]
}

data "aws_secretsmanager_secret_version" "rancher_password" {
  secret_id  = data.aws_secretsmanager_secret.rancher_secret.id
  depends_on = [module.secret_manager]
}

data "aws_ami" "latest_patched_ami" {
  most_recent = true
  owners      = ["373950440124"]

  filter {
    name   = "name"
    values = ["prod-rhel8.4*mvp*"]
  }
}

