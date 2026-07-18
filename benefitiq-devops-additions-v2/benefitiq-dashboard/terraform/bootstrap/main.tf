# ---------------------------------------------------------------------------
# Run this FIRST, on its own, with local state. It creates the S3 bucket and
# DynamoDB table that the main terraform/ config then uses as its remote
# backend. This can't live in the main config — you can't reference a backend
# from the same config that backend is meant to store.
#
# Usage:
#   cd terraform/bootstrap
#   terraform init
#   terraform apply -var="project_name=benefitiq"
#
# Then, back in terraform/:
#   terraform init \
#     -backend-config="bucket=<output: state_bucket_name>" \
#     -backend-config="key=benefitiq/terraform.tfstate" \
#     -backend-config="region=<your region>" \
#     -backend-config="dynamodb_table=<output: lock_table_name>"
# ---------------------------------------------------------------------------
terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "project_name" {
  type    = string
  default = "benefitiq"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "state" {
  bucket = "${var.project_name}-terraform-state-${data.aws_caller_identity.current.account_id}"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "lock" {
  name         = "${var.project_name}-terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

data "aws_caller_identity" "current" {}

output "state_bucket_name" {
  value = aws_s3_bucket.state.bucket
}

output "lock_table_name" {
  value = aws_dynamodb_table.lock.name
}
