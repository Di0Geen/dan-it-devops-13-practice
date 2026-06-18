output "ec2_public_ips" {
  description = "Public IP addresses of EC2 instances"
  value       = aws_instance.web[*].public_ip
}

output "nginx_urls" {
  description = "Nginx URLs"
  value       = [for instance in aws_instance.web : "http://${instance.public_ip}"]
}

output "ansible_inventory_file" {
  description = "Generated Ansible inventory file"
  value       = local_file.ansible_inventory.filename
}