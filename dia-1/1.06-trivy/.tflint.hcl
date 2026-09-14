tflint {
  required_version = "> 0.60.0"
}

plugin "terraform" {
  enabled = true
  preset  = "all"
}

plugin "aws" {
  enabled = true
  version = "0.48.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
  deep_check = false
}

rule "aws_resource_missing_tags" {
  enabled = true
  tags = [
    "Name"
  ]
}