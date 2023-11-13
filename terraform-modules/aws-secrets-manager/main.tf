resource "aws_secretsmanager_secret" "secret_manager" {
  name = var.secret_manager_name
  recovery_window_in_days = 0 
}

resource "aws_secretsmanager_secret_version" "secret_version" {
  secret_id     = aws_secretsmanager_secret.secret_manager.id
  secret_string = random_password.password.result
  depends_on = [ random_password.password ]
}

resource "random_password" "password" {
  length           = var.password_length
  special          = true
  override_special = "!$%&*-_=+<>:?"
}



