terraform {
  backend "s3" {
    bucket         = "20251104-my-terraform-tfstate"
    key            = "dev/terraform.tfstate"
    region         = "ap-southeast-2"
    profile        = "terraform"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

module "iam" {
  source = "./iam"

  environment    = var.environment
  mgmt_account_id = var.mgmt_account_id
}

module "vpc" {
  source = "../../modules/vpc"

  environment    = var.environment
  cidr_block     = "10.10.0.0/16"
  public_subnets = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnets = ["10.10.11.0/24", "10.10.12.0/24"]
  azs            = ["ap-southeast-2a", "ap-southeast-2c"]
}

########################
# S3: static-web (5個)
########################

resource "random_pet" "static_suffix" {
  count = 5
  length = 2
}

resource "aws_s3_bucket" "static" {
  count  = 5
  bucket = "${var.environment}-static-web-${random_pet.static_suffix[count.index].id}"
  tags = {
    Environment = var.environment
  }
  lifecycle {
    ignore_changes = [bucket]
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

resource "random_pet" "backup_suffix" {
  count = 5
  length = 2
}

resource "aws_s3_bucket" "backup" {
  count  = 5
  bucket = "${var.environment}-backup-${random_pet.backup_suffix[count.index].id}"
  tags = {
    Environment = var.environment
  }
  lifecycle {
    ignore_changes = [bucket]
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

variable "mgmt_account_id" {
  description = "Management account ID"
  type        = string
}
