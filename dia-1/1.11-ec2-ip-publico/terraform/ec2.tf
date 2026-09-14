
# Check the user IP 
data "http" "my_ip" {
  url = "https://ifconfig.me/ip"
}


# Create a Security Group that allow ssh from user IP
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.my_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Fetch data from latest Ubuntu 26.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}


# Create the EC2 instance and install Docker
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  # Shell script to install tools during first boot
  user_data = <<-EOF
              #!/bin/bash
              set -x
              export HOME=/root

              # Clear the old cache
              rm -rf /var/lib/apt/lists/*
              apt-get clean
              sed -i 's|^URIs: http://us-east-1.*|URIs: http://archive.ubuntu.com/ubuntu/|' /etc/apt/sources.list.d/ubuntu.sources

              # TENV
              # instala pré-requisitos para instalações do tenv e outras ferramentas
              sudo apt-get update -y
              sudo apt-get install -y jq unzip pipx python-is-python3
              TENV_LATEST=$(curl -s https://api.github.com/repos/tofuutils/tenv/releases/latest | jq -r '.assets[] | select(.name | endswith("Linux_x86_64.tar.gz")) | .browser_download_url')
              curl -L -O $TENV_LATEST
              mkdir ~/.tenv
              tar xvzf $(echo $TENV_LATEST | grep -o -E "tenv_v.*") -C ~/.tenv
              echo 'PATH="/root/.tenv:$PATH"' >> ~/.bashrc
              export PATH=/root/.tenv:$${PATH}
              source ~/.bashrc
              sleep 10
              /root/.tenv/tenv completion bash > /root/.tenv/tenv_completion.bash
              source /root/.tenv/tenv_completion.bash
              echo 'source /root/.tenv/tenv_completion.bash' >> ~/.bashrc
              source /root/.bashrc

              # AWS CLI
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              ./aws/install
              rm -rf ./aws
              rm -f ./awscliv2.zip


              # TERRAFORM - Via TENV
              /root/.tenv/tenv terraform install 1.15.9
              /root/.tenv/terraform -install-autocomplete

              # TERRAGRUNT - Via TENV
              /root/.tenv/tenv terragrunt install 1.1.3
              /root/.tenv/terragrunt --install-autocomplete
              echo 'export TG_TF_PATH=terraform' >> ~/.bashrc

              # TFLINT
              TF_LINT_SO=linux_amd64
              TFLINT_LATEST=$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | jq -r ".assets[] | select(.name | endswith(\"tflint_$${TF_LINT_SO}.zip\")) | .browser_download_url")
              curl -L -O $TFLINT_LATEST
              unzip -o $(echo $TFLINT_LATEST | grep -o -E "tflint_$${TF_LINT_SO}.+") -d ~/.tenv

              # TRIVY
              TRIVY_LATEST=$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | jq -r '.assets[] | select(.name | endswith("Linux-64bit.tar.gz")) | .browser_download_url')
              curl -L -O $TRIVY_LATEST
              tar xzf $(echo $TRIVY_LATEST | grep -o -E "trivy_.+") -C ~/.tenv trivy

              # CHECKOV
              # Instalação do Checkov via pipx
              pipx ensurepath
              source ~/.bashrc
              pipx install checkov

              # PRE COMMIT
              pipx install pre-commit

              EOF


  tags = {
    Name = "Bastion"
  }
}
