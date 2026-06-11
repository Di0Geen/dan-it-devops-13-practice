terraform {
  backend "s3" {
    bucket = "terraform-state-danit-devops-di0geen-352312075095"
    key    = "Di0Geen/homework20/terraform.tfstate"
    region = "eu-central-1"
  }
}