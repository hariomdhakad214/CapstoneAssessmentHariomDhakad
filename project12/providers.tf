terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Only enabled by the CI pipeline so `terraform plan` can run without real AWS credentials.
  skip_credentials_validation = var.ci_mode
  skip_requesting_account_id  = var.ci_mode
  skip_metadata_api_check     = var.ci_mode
  skip_region_validation      = var.ci_mode
}
