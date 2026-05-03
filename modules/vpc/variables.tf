variable "vpc_cidr" {
  description = "The CIDR block for the VPC (e.g. 10.0.0.0/16)"
  type        = string
}

variable "azs" {
  description = "List of availability zones — must contain exactly 3"
  type        = list(string)
}

variable "name_prefix" {
  description = "Prefix applied to all resource Name tags (typically the workspace/env name)"
  type        = string
  default     = "main"
}
