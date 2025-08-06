# Backend configuration for Terraform state storage
# This file contains the S3 backend configuration
# Usage: terraform init -backend-config=backend.hcl

bucket         = "school-mis-terraform-state"
key            = "terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "school-mis-terraform-locks"
encrypt        = true
