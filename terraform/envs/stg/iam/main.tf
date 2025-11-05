module "iam_roles" {
  source          = "../../../modules/iam"
  environment     = var.environment
  mgmt_account_id = var.mgmt_account_id
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "mgmt_account_id" {
  description = "Management account ID"
  type        = string
}


