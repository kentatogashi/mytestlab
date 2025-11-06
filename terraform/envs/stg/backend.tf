terraform {
  backend "s3" {
    bucket         = "20251104-my-terraform-tfstate"
    key            = "stg/terraform.tfstate"
    region         = "ap-southeast-2"
    profile        = "terraform"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

