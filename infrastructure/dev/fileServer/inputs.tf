
data "aws_ami" "latest_patched_ami" {
  most_recent = true
  owners      = ["373950440124"]

  filter {
    name   = "name"
    values = ["prod-rhel8.4*mvp*"]
  }
}

