data "aws_secretsmanager_secret" "sandbox2_rancher_secret" {
  name       = "sandbox2_customer_rke_rancher"
  depends_on = [module.secret_manager]
}

data "aws_secretsmanager_secret_version" "sandbox2_rancher_password" {
  secret_id  = data.aws_secretsmanager_secret.sandbox2_rancher_secret.id
  depends_on = [module.secret_manager]
}

data "aws_ami" "latest_patched_ami" {
  most_recent = true
  owners      = ["373950440124"]

  # filter on RHEL 8.x
  filter {
    name   = "name"
    values = ["prod-rhel8.4*mvp*"]        # Change: Modfy filter if not using RHEL Satellite
  }
}
