# ============================================================
# Production Environment — Variable Values
# ============================================================

# Must match the active Terraform workspace — guards against passing
# the wrong tfvars file. See locals.tf for the validation logic.
environment = "prod"

# ---- VPC -------------------------------------------------------
# Non-overlapping CIDR (dev=10.0, staging=10.1, prod=10.2)
vpc_cidr = "10.2.0.0/16"
azs      = ["us-east-1a", "us-east-1b", "us-east-1c"]

# ---- Security Group --------------------------------------------
sg_name = "prod-web-sg"

# SSH access should be restricted to your VPN or bastion IP in prod.
# Replace the CIDR below with your corporate VPN or bastion range.
ssh_ingress_rules = [
  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["8.8.8.8/32"]
    description = "Allow SSH from admin IP"
  }
]

# ---- EC2 -------------------------------------------------------
# Amazon Linux 2023 AMI (us-east-1)
ami_id        = "ami-0ed094fb1304fd857"
instance_type = "t3.medium"
key_name      = "akshada-terraweek-capstone"
