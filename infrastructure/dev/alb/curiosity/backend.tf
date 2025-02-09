terraform {
  backend "s3" {
    bucket         = "lts-terraform-dev"
    key            = "env/dev/alb/statefile"
    region         = "us-east-1"
    dynamodb_table = "lts-terraform-DynamoDB"
  }
}
