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

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "static" {
  count  = 5
  bucket = "${var.environment}-static-web-${substr(data.aws_caller_identity.current.account_id, length(data.aws_caller_identity.current.account_id) - 4, 4)}-${format("%02d", count.index + 1)}"
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
  bucket = "${var.environment}-backup-${substr(data.aws_caller_identity.current.account_id, length(data.aws_caller_identity.current.account_id) - 4, 4)}-${format("%02d", count.index + 1)}"
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

########################
# EC2 Instances (5種類)
########################

# EC2用途ごとの設定
locals {
  ec2_instances = {
    web = {
      name_prefix = "web"
      instance_type = "t3.small"
      subnet_index = 0
    }
    app = {
      name_prefix = "app"
      instance_type = "t3.medium"
      subnet_index = 0
    }
    db = {
      name_prefix = "db"
      instance_type = "t3.large"
      subnet_index = 0
    }
    cache = {
      name_prefix = "cache"
      instance_type = "t3.micro"
      subnet_index = 1
    }
    worker = {
      name_prefix = "worker"
      instance_type = "t3.small"
      subnet_index = 1
    }
  }
}

# 用途ごとのEC2インスタンスを作成
module "ec2" {
  for_each = local.ec2_instances
  source   = "../../modules/ec2"

  environment         = var.environment
  name_prefix         = each.value.name_prefix
  vpc_id              = module.vpc.vpc_id
  subnet_id           = module.vpc.public_subnet_ids[each.value.subnet_index]
  instance_type       = each.value.instance_type
  key_name            = var.ec2_key_name
  allowed_ssh_cidr_blocks = var.ec2_allowed_ssh_cidr_blocks
}
