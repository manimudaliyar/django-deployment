# This Terraform configuration sets up the backend infrastructure for managing Terraform state in AWS.
provider "aws" {
  region = var.aws-region
}

# Create an S3 bucket to store Terraform state files
resource "aws_s3_bucket" "django-state-bucket" {
  bucket = "django-deployment-state-bucket-terraform"
  force_destroy = false

# Prevent the bucket from being destroyed to protect state files
  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
    Name = "${var.environment}-django-state-bucket"
    }
  )
}

# Enable versioning on the S3 bucket to keep track of changes to state files
resource "aws_s3_bucket_versioning" "state-file-bucket-versioning" {
  bucket = aws_s3_bucket.django-state-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Create a DynamoDB table to manage Terraform state locks
resource "aws_dynamodb_table" "terraform-lock-table" {
  name = "django-deployment-terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

# Define the attribute for the DynamoDB table to store lock information
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(
    local.common_tags,
    {
    Name = "${var.environment}-django-state-bucket"
    }
  )
}