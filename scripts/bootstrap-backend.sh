#!/usr/bin/env bash
# ============================================================
# bootstrap-backend.sh
#
# One-time setup: creates the single S3 bucket used for
# Terraform remote state across all environments.
# Workspace selection (dev / staging / prod) isolates state
# inside the bucket automatically via key prefixes.
#
# Run this ONCE before the very first `terraform init`.
#
# Usage:
#   chmod +x scripts/bootstrap-backend.sh
#   ./scripts/bootstrap-backend.sh
#
# Prerequisites:
#   - AWS CLI installed and configured (aws configure)
#   - Sufficient IAM permissions: s3:CreateBucket,
#     s3:PutBucketVersioning, s3:PutBucketEncryption,
#     s3:PutBucketPublicAccessBlock
# ============================================================

set -euo pipefail

REGION="us-east-1"
BUCKET="terraweek-capstone-tfstate"

echo ""
echo "============================================================"
echo "  Bootstrapping Terraform S3 backend"
echo "  Bucket : ${BUCKET}"
echo "  Region : ${REGION}"
echo "  Locking: Native S3 (use_lockfile = true)"
echo "============================================================"
echo ""

# ---- S3 Bucket -----------------------------------------------
echo "[1/3] Creating S3 bucket..."
if aws s3api head-bucket --bucket "${BUCKET}" --region "${REGION}" 2>/dev/null; then
  echo "      Bucket already exists — skipping creation."
else
  # Note: us-east-1 does NOT accept LocationConstraint — omit it for that region
  aws s3api create-bucket \
    --bucket "${BUCKET}" \
    --region "${REGION}"
  echo "      Bucket created."
fi

echo "[2/3] Enabling versioning (allows state rollback)..."
aws s3api put-bucket-versioning \
  --bucket "${BUCKET}" \
  --versioning-configuration Status=Enabled
echo "      Versioning enabled."

echo "[3/3] Enabling AES-256 encryption and blocking public access..."
aws s3api put-bucket-encryption \
  --bucket "${BUCKET}" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'
aws s3api put-public-access-block \
  --bucket "${BUCKET}" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
echo "      Encryption enabled, public access blocked."

# ---- Done ----------------------------------------------------
echo ""
echo "============================================================"
echo "  Done! Your backend bucket is ready."
echo ""
echo "  Run once to initialise the backend:"
echo "    terraform init -backend-config=backend/config.hcl"
echo ""
echo "  Then for each environment:"
echo "    terraform workspace new dev          # first time only"
echo "    terraform workspace select dev"
echo "    terraform plan  -var-file=env/dev.tfvars"
echo "    terraform apply -var-file=env/dev.tfvars"
echo ""
echo "  Repeat with staging / prod as needed."
echo "============================================================"
echo ""
