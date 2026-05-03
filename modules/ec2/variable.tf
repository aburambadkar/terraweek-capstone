variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type (e.g. t3.micro)"
  type        = string
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch the instance in"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the instance"
  type        = list(string)
}

variable "instance_name" {
  description = "Value for the instance's Name tag"
  type        = string
  default     = "web-server"
}

variable "key_name" {
  description = "Name of the AWS key pair to use for SSH access"
  type        = string
}
