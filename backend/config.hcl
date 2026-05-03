# ============================================================
# S3 Backend — Single Config for All Environments
# Usage: terraform init -backend-config=backend/config.hcl
#
# Terraform automatically namespaces state per workspace:
#   default   →  terraform.tfstate
#   dev       →  env:/dev/terraform.tfstate
#   staging   →  env:/staging/terraform.tfstate
#   prod      →  env:/prod/terraform.tfstate
#
# The workspace is the isolation boundary — always run
# `terraform workspace select <env>` before plan/apply.
# ============================================================

bucket       = "terraweek-capstone-tfstate"
key          = "terraform.tfstate"
region       = "us-east-1"
encrypt      = true
use_lockfile = true  # Native S3 locking — requires Terraform >= 1.10
