# Main Terraform configuration for School MIS Infrastructure
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend configuration for state management
  # IMPORTANT: Run ./scripts/setup-terraform-backend.sh first to create the S3 bucket and DynamoDB table
  # Then uncomment the backend block below and run: terraform init -migrate-state
  
  # backend "s3" {
  #   bucket         = "school-mis-terraform-state"
  #   key            = "terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "school-mis-terraform-locks"
  #   encrypt        = true
  # }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "School-MIS"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# Local values
locals {
  # Shortened naming to stay within AWS limits (32 chars max for ALB target groups)
  name_prefix = "${substr(var.project_name, 0, 8)}-${substr(var.environment, 0, 4)}"
  azs         = slice(data.aws_availability_zones.available.names, 0, 1)
  
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
