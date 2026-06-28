variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "bucket_prefix" {
  description = "Prefix for Terraform state S3 bucket"
  type        = string
  default     = "di0geen-step-project-3-tfstate"
}