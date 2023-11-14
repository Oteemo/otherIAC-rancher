# ####iam
resource "random_integer" "random_resource" {
  min = 1
  max = 999999
}
resource "aws_iam_policy" "server_policy" {
  name        = "RKEServerPolicy-${random_integer.random_resource.result}"
  description = "IAM policy for RKE Server"
  policy      = file("${path.module}/policies/server_policy.json")
}

resource "aws_iam_role_policy_attachment" "server_policy_attachment" {
  role       = aws_iam_role.server_role.name
  policy_arn = aws_iam_policy.server_policy.arn
}

resource "aws_iam_policy" "agent_policy" {
  name        = "RKEAgentPolicy-${random_integer.random_resource.result}"
  description = "IAM policy for RKE Agents"
  policy      = file("${path.module}/policies/agent_policy.json")
}

resource "aws_iam_role_policy_attachment" "agent_policy_attachment" {
  role       = aws_iam_role.agent_role.name
  policy_arn = aws_iam_policy.agent_policy.arn
}

resource "aws_iam_policy" "ssm_policy" {
  name   = "SSMPolicyForRKE2-${random_integer.random_resource.result}"
  policy = file("${path.module}/policies/ssm_policy.json")
}

resource "aws_iam_policy" "s3_policy" {
  name        = "S3PolicyForRKE2-${random_integer.random_resource.result}"
  description = "Allow RKE2 servers and agents to access S3 bucket"
  policy      = templatefile("${path.module}/policies/s3_policy.json.tpl", { aws_s3_bucket = aws_s3_bucket.bucket.id })
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

resource "aws_iam_role" "agent_role" {
  name               = "agent_role-${random_integer.random_resource.result}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3_policy_attachment_server" {
  role       = aws_iam_role.server_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "s3_policy_attachment_agent" {
  role       = aws_iam_role.agent_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "server_ssm_policy_attachment" {
  role       = aws_iam_role.server_role.name
  policy_arn = aws_iam_policy.ssm_policy.arn
}

resource "aws_iam_role_policy_attachment" "agent_ssm_policy_attachment" {
  role       = aws_iam_role.agent_role.name
  policy_arn = aws_iam_policy.ssm_policy.arn
}

resource "aws_iam_instance_profile" "agent" {
  name = "Agent_Profile-${random_integer.random_resource.result}"
  role = aws_iam_role.agent_role.name
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
