variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "mgmt_account_id" {
  description = "Management account ID"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "vpc_public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "vpc_private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.10.11.0/24", "10.10.12.0/24"]
}

variable "vpc_azs" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-southeast-2a", "ap-southeast-2c"]
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "ec2_key_name" {
  description = "Name of the AWS Key Pair to use for SSH access"
  type        = string
  default     = ""
}

variable "ec2_allowed_ssh_cidr_blocks" {
  description = "CIDR blocks allowed to SSH to the EC2 instance"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "sns_notification_email" {
  description = "Email address for EC2 status check notifications"
  type        = string
  default     = ""
}
