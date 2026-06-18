variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-central-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of EC2 instances"
  type        = number
  default     = 2
}

variable "public_key_path" {
  description = "Path to public SSH key"
  type        = string
}

variable "private_key_path" {
  description = "Path to private SSH key for Ansible"
  type        = string
}