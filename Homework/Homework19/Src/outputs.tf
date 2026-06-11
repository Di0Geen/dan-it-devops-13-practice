output "public_ec2_public_ip" {
  description = "Public IP address of public EC2"
  value       = aws_instance.public_ec2.public_ip
}

output "public_ec2_private_ip" {
  description = "Private IP address of public EC2"
  value       = aws_instance.public_ec2.private_ip
}

output "private_ec2_private_ip" {
  description = "Private IP address of private EC2"
  value       = aws_instance.private_ec2.private_ip
}

output "ssh_to_public_ec2" {
  description = "SSH command for public EC2"
  value       = "ssh -i ~/.ssh/terraform-homework-key ec2-user@${aws_instance.public_ec2.public_ip}"
}

output "ssh_from_public_to_private" {
  description = "SSH command from public EC2 to private EC2"
  value       = "ssh ec2-user@${aws_instance.private_ec2.private_ip}"
}