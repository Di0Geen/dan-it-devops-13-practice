output "bucket_name" {
  description = "S3 bucket name for Terraform backend"
  value       = aws_s3_bucket.tf_state.bucket
}