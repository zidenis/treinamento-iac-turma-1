# Cria um S3 Bucket na conta AWS
resource "aws_s3_bucket" "site" {
  #checkov:skip=CKV_AWS_18:O ambiente é um demo e não utilizará server access logging.
  #checkov:skip=CKV_AWS_144:O ambiente é um demo e não utilizará replicação cross-region.
  #checkov:skip=CKV_AWS_145:O ambiente é um demo e não utilizará KMS keys para evitar custos adicionais. 
  #checkov:skip=CKV_AWS_300:O ambiente é um demo e não utilizará KMS keys para evitar custos adicionais.
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
  #checkov:skip=CKV_AWS_54:O bucket precisa de política pública para permitir leitura do index.html em website estático.
  #checkov:skip=CKV_AWS_56:Restrigir public buckets bloquearia o acesso público necessário ao site.
  bucket                  = aws_s3_bucket.site.id
  block_public_policy     = false
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
