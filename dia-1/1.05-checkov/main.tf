# Cria um S3 Bucket na conta AWS
resource "aws_s3_bucket" "site" {
  bucket = "capacitacao-iac-terraform-1-fluxo-basico"
  tags = {
    Name = "capacitacao-iac-terraform-1-fluxo-basico"
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
  bucket                  = aws_s3_bucket.site.id
  block_public_policy     = false # Obrigatório False para aceitar a política pública
  restrict_public_buckets = false # Obrigatório False para permitir acesso público ao bucket
}

# Define uma Bucket Policy para liberar acesso público de leitura
resource "aws_s3_bucket_policy" "allow_public_access" {
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

  depends_on = [aws_s3_bucket_public_access_block.site_policy] # Política deve ser aplicada após remover o bloqueio de políticas públicas
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
