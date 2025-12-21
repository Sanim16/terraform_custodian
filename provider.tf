terraform {
  # backend "s3" {
  #   bucket         = "unique-bucket-name-msctf" # REPLACE WITH YOUR BUCKET NAME
  #   key            = "remote-backend/terraform_nginx/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-state-locking"
  #   encrypt        = true
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}
