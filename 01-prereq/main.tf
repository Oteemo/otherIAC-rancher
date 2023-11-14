terraform {

  required_version = "~> 1.5.0"       #field for tf version.  minimum

  #Different fields and requirements for providers
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.20.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.11.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "customer-terraform-state"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "rancher_backup" {
  bucket = "customer-rancher-backup"
}

resource "aws_s3_bucket_versioning" "rancher_backup" {
  bucket = aws_s3_bucket.rancher_backup.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_policy" "s3_policy" {
  name        = "S3PolicyForRKE2-${random_integer.random_resource.result}"
  description = "Allow RKE2 servers and agents to access S3 bucket"
  policy      = templatefile("policies/s3_policy.json.tpl", { aws_s3_bucket = aws_s3_bucket.rancher_backup.id })
}

resource "random_integer" "random_resource" {
  min = 1
  max = 999999
}


resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "customer-terraform-DynamoDb"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}