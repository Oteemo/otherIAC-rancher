terraform {
  backend "s3" {
    bucket         = "customer-terraform-backend"
    key            = "env/sandbox2/statefile"
    region         = "us-east-1"
    dynamodb_table = "customer-terraform-DynamoDb"
  }
}