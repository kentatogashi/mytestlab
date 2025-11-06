variable "mgmt_account_id" {
  description = "The AWS Account ID that owns the IAM Users who can assume these roles"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, stg, prod)"
  type        = string
}

