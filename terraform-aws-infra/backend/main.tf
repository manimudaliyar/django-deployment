provider "aws" {
  region = var.aws-region
}

resource "aws_s3_bucket" "django-state-bucket" {
  bucket = "django-deployment-state-bucket-terraform"
  force_destroy = false

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

resource "aws_s3_bucket_versioning" "state-file-bucket-versioning" {
  bucket = aws_s3_bucket.django-state-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform-lock-table" {
  name = "django-deployment-terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

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