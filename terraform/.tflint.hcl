config {
  call_module_type = "local"
  force            = false
}

# AWS Provider plugin
plugin "aws" {
  enabled = true
  version = "0.31.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Terraform plugin (without preset to allow fine-grained control)
plugin "terraform" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = false
}

rule "terraform_required_providers" {
  enabled = false
}

