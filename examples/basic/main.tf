terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

variable "region" {
  description = "AWS region for the provider."
  type        = string
  default     = "us-east-1"
}

provider "aws" {
  region = var.region
}

module "baseline" {
  source = "../.."

  log_bucket_name         = "example-account-logs-0001"
  minimum_password_length = 16

  tags = {
    Environment = "sandbox"
    ManagedBy   = "terraform"
  }
}

output "log_bucket_arn" {
  value = module.baseline.log_bucket_arn
}
