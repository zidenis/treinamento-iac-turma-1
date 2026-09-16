# Dynamically fetch the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# EC2 Instance running Nginx
resource "aws_instance" "nginx_server" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"
  subnet_id     = data.aws_subnets.default.ids[0]

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # User data script to automate Nginx installation upon startup
  user_data = <<-EOF
              #!/bin/bash
              set -x
              sudo dnf update -y
              sudo dnf install nginx -y
              sudo systemctl start nginx
              sudo systemctl enable nginx

              EOF

  tags = {
    Name = "Nginx-Web-Server"
  }
}