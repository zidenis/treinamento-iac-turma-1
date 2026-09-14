
output "instance_ip" {
  value = aws_instance.bastion.public_ip
}