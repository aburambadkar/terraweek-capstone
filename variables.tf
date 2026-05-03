# ============================================================
# Root Variables
# ============================================================

# ---- Workspace guard -------------------------------------------
# Must match the active Terraform workspace exactly.
# The validation in locals.tf will fail loudly at plan time if it doesn't.
variable "environment" {
  description = "Deployment environment — must match the active Terraform workspace (dev | staging | prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

# ---- VPC -------------------------------------------------------
variable "vpc_cidr" {
  description = "The CIDR block for the VPC (e.g. 10.0.0.0/16)"
  type        = string
}

variable "azs" {
  description = "List of availability zones for subnet placement (must have exactly 3)"
  type        = list(string)
}

# ---- Security Group --------------------------------------------
variable "sg_name" {
  description = "Name of the security group"
  type        = string
  default     = "web-sg"
}

variable "ssh_ingress_rules" {
  description = "Ingress rules to attach to the security group (SSH / port 22 only for dev)"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}

# ---- EC2 -------------------------------------------------------
variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type (e.g. t3.micro)"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the AWS key pair to use for SSH access to the EC2 instance"
  type        = string
}
