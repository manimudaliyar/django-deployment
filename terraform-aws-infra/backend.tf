terraform {
  backend "s3" {
    bucket = "django-deployment-state-bucket-terraform"
    key = "django-deployment/terraform.tfstate"
    region = "ap-south-1"
    dynamodb_table = "django-deployment-terraform-lock-table"
    encrypt = true
  }
}