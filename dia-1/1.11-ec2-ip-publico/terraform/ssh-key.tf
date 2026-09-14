# Generate SSH private and public keys locally
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Register the public key in AWS
resource "aws_key_pair" "generated_key" {
  key_name   = "my-custom-ssh-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Save the private key locally for your use
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/iac-ssh-private-key.pem"
  file_permission = "0400"
}