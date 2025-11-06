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

########################
# S3: static-web (5個)
########################

resource "aws_s3_bucket" "static" {
  count  = 5
  bucket = "${var.environment}-static-web-${format("%02d", count.index + 1)}"
  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "static" {
  count  = 5
  bucket = aws_s3_bucket.static[count.index].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

########################
# S3: backup (5個)
########################

resource "aws_s3_bucket" "backup" {
  count  = 5
  bucket = "${var.environment}-backup-${format("%02d", count.index + 1)}"
  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "backup" {
  count  = 5
  bucket = aws_s3_bucket.backup[count.index].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
