# Backend configuration for remote state management
# S3 bucket and DynamoDB table created by backend-setup

terraform {
  backend "s3" {
    bucket         = "terraform-state-webapp-dev-12345"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-lock-webapp"
    encrypt        = true
  }
}
