# ============================================================
# Staging Environment — Variable Values
# ============================================================

# Must match the active Terraform workspace — guards against passing
# the wrong tfvars file. See locals.tf for the validation logic.
environment = "staging"

# ---- VPC -------------------------------------------------------
# Non-overlapping CIDR (dev=10.0, staging=10.1, prod=10.2)
vpc_cidr = "10.1.0.0/16"
azs      = ["us-east-1a", "us-east-1b", "us-east-1c"]

# ---- Security Group --------------------------------------------
sg_name = "staging-web-sg"

# SSH access locked to the admin/VPN IP.
# Update cidr_blocks to your staging jump-box or VPN CIDR if different.
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
instance_type = "t3.small"
key_name      = "akshada-terraweek-capstone"
