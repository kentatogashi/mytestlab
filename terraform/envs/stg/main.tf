# ============================================================
# IAM Module
# ============================================================
module "iam" {
  source = "./iam"

  environment     = var.environment
  mgmt_account_id = var.mgmt_account_id
}

# ============================================================
# VPC Module
# ============================================================
module "vpc" {
  source = "../../modules/vpc"

  environment     = var.environment
  cidr_block      = var.vpc_cidr_block
  public_subnets  = var.vpc_public_subnets
  private_subnets = var.vpc_private_subnets
  azs             = var.vpc_azs
}


