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

# Configura o ciclo de vida para o bucket
resource "aws_s3_bucket_lifecycle_configuration" "site_lifecycle" {
  bucket = aws_s3_bucket.site.id
  rule {
    id     = "Expire Old Files"
    status = "Enabled"

    expiration {
      days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Configura este bucket como host de um website estático
resource "aws_s3_bucket_website_configuration" "site_website" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }
}

# Habilita o acesso público ao bucket por meio de uma política de bucket
resource "aws_s3_bucket_public_access_block" "site_policy" {
  bucket = aws_s3_bucket.site.id
  #checkov:skip=CKV_AWS_54:O bucket precisa de política pública para permitir leitura do index.html em website estático.
  #trivy:ignore:AVD-AWS-0087
  block_public_policy = false
  #checkov:skip=CKV_AWS_56:Restrigir public buckets bloquearia o acesso público necessário ao site.
  #trivy:ignore:AVD-AWS-0093
  restrict_public_buckets = false
  block_public_acls       = true
  ignore_public_acls      = true
}

# Define uma Bucket Policy para liberar acesso público de leitura
resource "aws_s3_bucket_policy" "allow_public_access" {
  #checkov:skip=CKV_AWS_70:Somente o objeto index.html é exposto anonimamente; o acesso não é amplo ao bucket.
  bucket = aws_s3_bucket.site.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.site.arn}/index.html"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.site_policy]
}

# Cria o index.html do website
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.site.id
  key          = "index.html"
  content      = "<html><body><h1>IaC Demo</h1><p><h2>Bucket criado com Terraform em ${formatdate("DD/MM/YYYY hh:mm:ss", timeadd(timestamp(), "-3h"))}</h2></p></body></html>"
  content_type = "text/html"
  tags = {
    Name = "index.html"
  }
}
