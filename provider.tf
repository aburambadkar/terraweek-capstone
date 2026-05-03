# ============================================================
# Provider Configuration
# The terraform{} block (required_providers + backend) lives
# in backend.tf — Terraform merges all terraform{} blocks.
# ============================================================

# AWS Provider
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = terraform.workspace
      Owner       = "AK"
      Project     = "TerraWeek"
    }
  }
}

