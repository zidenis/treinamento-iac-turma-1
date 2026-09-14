terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }

  required_version = "> 1.15.0"
}

provider "aws" {
}

# Cria um S3 Bucket na conta AWS para hospedar um website estático com acesso público
# Como é um laboratório/demo, algumas boas práticas de segurança foram desabilitadas intencionalmente.
#AWS-0089 (LOW): Bucket has logging disabled
#AWS-0132 (HIGH): Bucket does not encrypt data with a customer managed key
#trivy:ignore:AWS-0089
#trivy:ignore:AVD-AWS-0132
resource "aws_s3_bucket" "site" {
  #checkov:skip=CKV_AWS_18:O ambiente é um demo e não utilizará server access logging.
  #checkov:skip=CKV_AWS_300:O ambiente é um demo e não utilizará KMS keys para evitar custos adicionais.
  #checkov:skip=CKV_AWS_144:O ambiente é um demo e não utilizará replicação cross-region.
  #checkov:skip=CKV_AWS_145:O ambiente é um demo e não utilizará KMS keys para evitar custos adicionais.
  #checkov:skip=CKV2_AWS_6:O bucket é intencionalmente público para um website estático; a exposição é limitada ao objeto index.html.
  #checkov:skip=CKV2_AWS_62:O ambiente é um demo e não utilizará event notifications.
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
  }
}

# Configura versionamento para o bucket
resource "aws_s3_bucket_versioning" "site_versioning" {
  bucket = aws_s3_bucket.site.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Configura este bucket como host de um website estático
resource "aws_s3_bucket_website_configuration" "site_website" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }
}
