terraform {
  backend "s3" {
    bucket         = "jg-static-aws-site-terraform-state-backend"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "jg-static-aws-site-terraform-state-locking"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=3.49.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"
}