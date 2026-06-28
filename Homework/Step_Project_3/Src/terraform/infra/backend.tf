terraform {
  backend "s3" {
    bucket  = "di0geen-step-project-3-tfstate-406026ea"
    key     = "Step_Project_3/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
  }
}