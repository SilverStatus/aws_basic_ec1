# Specifies the required Terraform version and AWS Provider version.
terraform {
  required_version = ">= 0.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92.0"
      s3_use_path_style           = false
      skip_region_validation      = false
      skip_credentials_validation = false
    }
  }
}

# Sets our region to "us-east-1"
provider "aws" {
  region = "us-east-1"
}