# Apresenta a URL de acesso ao website
output "website_url" {
  description = "URL de acesso ao website"
  value       = "http://${aws_s3_bucket_website_configuration.site_website.website_endpoint}"
}
