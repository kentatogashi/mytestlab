provider "aws" {
  region = "ap-southeast-2"

  # 認証情報が空の場合はprofileを使用、設定されている場合は認証情報を使用
  access_key = var.aws_access_key_id != "" ? var.aws_access_key_id : null
  secret_key = var.aws_secret_access_key != "" ? var.aws_secret_access_key : null
  profile    = var.aws_access_key_id == "" || var.aws_secret_access_key == "" ? "bootstrap" : null

  default_tags {
    tags = {
      Environment = var.environment
    }
  }
}


