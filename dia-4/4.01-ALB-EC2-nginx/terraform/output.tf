
# Output the public DNS name of the ALB to access the website
output "alb_dns_name" {
  description = "The public DNS name of the Application Load Balancer"
  value       = aws_lb.nginx_alb.dns_name
}