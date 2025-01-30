# ####iam
resource "random_integer" "random_resource" {
  min = 1
  max = 999999
}
resource "aws_iam_policy" "server_policy" {
  name        = "RKEServerPolicy-${random_integer.random_resource.result}"
  description = "IAM policy for File Server"
  policy      = file("${path.module}/policies/server_policy.json")
}

resource "aws_iam_role_policy_attachment" "server_policy_attachment" {
  role       = aws_iam_role.server_role.name
  policy_arn = aws_iam_policy.server_policy.arn
}

resource "aws_iam_policy" "ssm_policy" {
  name   = "SSMPolicyForRunners-${random_integer.random_resource.result}"
  policy = file("${path.module}/policies/ssm_policy.json")
}

resource "aws_iam_role" "server_role" {
  name               = "server_role-${random_integer.random_resource.result}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "server_ssm_policy_attachment" {
  role       = aws_iam_role.server_role.name
  policy_arn = aws_iam_policy.ssm_policy.arn
}

resource "aws_iam_instance_profile" "server" {
  name = "Server_profile-${random_integer.random_resource.result}"
  role = aws_iam_role.server_role.name
}

resource "aws_iam_policy" "secrets_manager_policy" {
  name   = "SecretsManagerPolicyForRKE2-${random_integer.random_resource.result}"
  policy = file("${path.module}/policies/secrets_manager_policy.json")
}

resource "aws_iam_role_policy_attachment" "secrets_manager_policy_attachment" {
  role       = aws_iam_role.server_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}
