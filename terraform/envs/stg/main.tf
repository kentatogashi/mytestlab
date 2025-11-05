terraform {
  required_providers {
    random = {
      version = "3.3.1"
    }
  }

  backend "s3" {
    bucket         = "20251104-my-terraform-tfstate"
    key            = "stg/terraform.tfstate"
    region         = "ap-southeast-2"
    profile        = "terraform"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "stg"
}

variable "mgmt_account_id" {
  description = "Management account ID"
  type        = string
  default     = "578736536528"
}

module "iam" {
  source = "./iam"

  environment     = var.environment
  mgmt_account_id = var.mgmt_account_id
}

module "vpc" {
  source = "../../modules/vpc"

  environment     = var.environment
  cidr_block      = "10.20.0.0/16"
  public_subnets  = ["10.20.1.0/24", "10.20.2.0/24"]
  private_subnets = ["10.20.11.0/24", "10.20.12.0/24"]
  azs             = ["ap-southeast-2a", "ap-southeast-2c"]
}


