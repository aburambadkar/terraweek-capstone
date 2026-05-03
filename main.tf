# ============================================================
# Root Module — Wires the three child modules together
# ============================================================

# 1. Network (VPC + Subnets + NAT Gateway)
module "vpc" {
  source      = "./modules/vpc"
  vpc_cidr    = var.vpc_cidr
  azs         = var.azs
  name_prefix = local.env
}

# 2. Firewall (Security Group)
module "security_group" {
  source        = "./modules/security-grp"
  vpc_id        = module.vpc.vpc_id
  sg_name       = var.sg_name
  ingress_rules = var.ssh_ingress_rules
}

# 3. Compute (EC2 Instance)
module "web_server" {
  source             = "./modules/ec2"
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.security_group.security_group_id]
  instance_name      = "${local.env}-web-server"
  key_name           = var.key_name
}
