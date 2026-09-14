# Variáveis recebem o input do usuário. Pode-se definir um valor default
variable "environment" {
  description = "Ambiente de implantação da IaC"
  type        = string
  default     = "dev"
}

# Cria um S3 Bucket cujo nome depende da variável environment
resource "aws_s3_bucket" "capacitacao" {
  bucket = "br-jus-jt-csjt-${var.environment}"
}

# Blocos data permitem buscar informações de recursos existentes
data "aws_caller_identity" "current" {}

# Valores locais permitem usar expressões para criar valores. 
# Neste exemplo, o versionamento é habilitado apenas se o ambiente for prod.
locals {
  versioned = var.environment == "prod" ? true : false

  jt_tags = {
    "jt:environment" = var.environment
  }
}

# Módulos permitem reutilizar configurações de outros arquivos.
# Os argumentos do módulo são passados na forma de atributos.
module "logs_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.15.4"
  bucket  = "br-jus-jt-csjt-logs"
  versioning = {
    enabled = local.versioned
  }
  tags = merge(local.jt_tags, {
    "owner" = data.aws_caller_identity.current.account_id
  })
}

# Output expõe informações dos recursos para o usuário
output "bucket_arn" {
  value = module.logs_bucket.s3_bucket_bucket_domain_name
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

provider "aws" {

  # Default tags são tags aplicadas automaticamente em todos os recursos 
  # que suportam tags e são provisionados pelo provider AWS
  default_tags {
    tags = local.jt_tags
  }

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    s3 = "http://localhost:4566"
  }
}
