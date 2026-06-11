output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.nginx_ec2.instance_public_ip
}