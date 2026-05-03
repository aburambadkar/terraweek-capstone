# ============================================================
# Dev Environment — Variable Values
# ============================================================

# Must match the active Terraform workspace — guards against passing
# the wrong tfvars file. See locals.tf for the validation logic.
environment = "dev"

# ---- VPC -------------------------------------------------------
vpc_cidr = "10.0.0.0/16"
azs      = ["us-east-1a", "us-east-1b", "us-east-1c"]

# ---- Security Group --------------------------------------------
sg_name = "dev-web-sg"

# Port 22 is the ONLY open ingress port for dev.
# Access is locked to the admin IP below — change this to your own IP if needed.
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
instance_type = "t3.micro"
key_name      = "akshada-terraweek-capstone"
