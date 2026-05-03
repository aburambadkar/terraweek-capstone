# ============================================================
# Terraform Settings — Version Constraints + Remote Backend
#
# Backend block is intentionally empty (partial configuration).
# The bucket and key are supplied once at init time:
#
#   ./scripts/bootstrap-backend.sh        # one-time: creates the S3 bucket
#   terraform init -backend-config=backend/config.hcl
#
# Workspace selection is what isolates state per environment:
#
#   terraform workspace select dev        # state → env:/dev/terraform.tfstate
#   terraform workspace select staging    # state → env:/staging/terraform.tfstate
#   terraform workspace select prod       # state → env:/prod/terraform.tfstate
#
# State locking uses native S3 conditional writes (use_lockfile = true)
# — no DynamoDB required (Terraform >= 1.10).
#
# NOTE: Backend blocks do not support variable interpolation,
# which is why config lives in backend/config.hcl rather than
# being driven by variables.
# ============================================================

terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {}
}
