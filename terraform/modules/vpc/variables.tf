variable "environment" {
  description = "Environment name (e.g., dev, stg, prod)"
  type        = string
}

variable "name" {
  description = "Name prefix for VPC resources (optional, defaults to environment-vpc if not specified)"
  type        = string
  default     = ""
}

variable "cidr_block" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

