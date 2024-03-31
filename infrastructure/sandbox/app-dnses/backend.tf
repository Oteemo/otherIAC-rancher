terraform {
  backend "s3" {
    bucket         = "lts-terraform-backend"
    key            = "env/sandbox/app_dns/statefile"
    region         = "us-east-1"
    dynamodb_table = "lts-terraform-DynamoDb"
  }
}
