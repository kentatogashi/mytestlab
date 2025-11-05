provider "aws" {
  region  = "ap-southeast-2"
  profile = "terraform"

  default_tags {
    tags = {
      Environment = var.environment
    }
  }
}


