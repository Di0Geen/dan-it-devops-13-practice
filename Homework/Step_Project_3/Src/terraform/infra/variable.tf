variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "step-project-3"
}

variable "vpc_cidr" {
  description = "Main VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR for Jenkins master"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR for Jenkins worker"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "Availability zone"
  type        = string
  default     = "eu-central-1a"
}

variable "public_key_path" {
  description = "Path to public SSH key"
  type        = string
  default     = "~/.ssh/step_project_3_key.pub"
}

variable "private_key_path" {
  description = "Path to private SSH key"
  type        = string
  default     = "~/.ssh/step_project_3_key"
}

variable "key_name" {
  description = "AWS key pair name"
  type        = string
  default     = "step-project-3-key"
}

variable "master_instance_type" {
  description = "Instance type for Jenkins master"
  type        = string
  default     = "t3.micro"
}

variable "worker_instance_type" {
  description = "Instance type for Jenkins worker"
  type        = string
  default     = "t3.micro"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}