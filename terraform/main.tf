terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Name = "example-2024-02"
    }
  }
}

module "s3" {
  source           = "./s3"
  application_name = var.name
  bucket_name      = "example-2024-02"
  environment      = var.environment
}

module "lambda" {
  source           = "./lambda"
  application_name = var.name
  environment      = var.environment
  s3_bucket_id     = module.s3.s3_bucket_id
  s3_bucket_arn    = module.s3.s3_bucket_arn
}
