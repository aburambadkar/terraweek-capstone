# ============================================================
# Root Outputs
# ============================================================

# ---- VPC -------------------------------------------------------
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the three public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the three private subnets"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_ip" {
  description = "Public IP of the NAT Gateway (used by private subnet egress)"
  value       = module.vpc.nat_gateway_ip
}

# ---- Security Group --------------------------------------------
output "security_group_id" {
  description = "ID of the security group attached to the EC2 instance"
  value       = module.security_group.security_group_id
}

# ---- EC2 -------------------------------------------------------
output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = module.web_server.instance_id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.web_server.public_ip
}
