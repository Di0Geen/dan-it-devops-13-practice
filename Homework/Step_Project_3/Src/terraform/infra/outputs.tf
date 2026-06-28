output "jenkins_master_public_ip" {
  description = "Public IP address of Jenkins master"
  value       = aws_instance.jenkins_master.public_ip
}

output "jenkins_master_public_dns" {
  description = "Public DNS of Jenkins master"
  value       = aws_instance.jenkins_master.public_dns
}

output "jenkins_worker_private_ip" {
  description = "Private IP address of Jenkins worker"
  value       = aws_instance.jenkins_worker.private_ip
}

output "ssh_to_master" {
  description = "SSH command for Jenkins master"
  value       = "ssh -i ${var.private_key_path} ubuntu@${aws_instance.jenkins_master.public_ip}"
}

output "jenkins_url" {
  description = "Jenkins URL through nginx reverse proxy"
  value       = "http://${aws_instance.jenkins_master.public_ip}"
}