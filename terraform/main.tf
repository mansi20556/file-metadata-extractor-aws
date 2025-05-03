provider "aws" {
  region = var.aws_region
}

# S3 Bucket - Use the manually created bucket
resource "aws_s3_bucket" "uploads" {
  bucket = "extract-file-metadata"  # Static bucket name
  acl    = "private"
}

# DynamoDB Table - Use the manually created table
resource "aws_dynamodb_table" "metadata_table" {
  name         = "file-metadata"  # Static table name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  attribute {
    name = "Timestamp"
    type = "S"
  }

  tags = {
    "Name" = "file-metadata"
  }
}

# IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"  # Static IAM role name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Lambda Function
resource "aws_lambda_function" "file_metadata_extractor" {
  function_name = "fileMetadataExtractor"  # Static function name
  s3_bucket     = aws_s3_bucket.uploads.bucket
  s3_key        = "lambda.zip"
  runtime       = "python3.8"
  handler       = "handler.lambda_handler"
  role          = aws_iam_role.lambda_exec_role.arn
}

# Lambda Permissions for S3 and DynamoDB Access
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3"
  action        = "lambda:InvokeFunction"
  principal     = "s3.amazonaws.com"
  function_name = aws_lambda_function.file_metadata_extractor.function_name
  source_arn    = aws_s3_bucket.uploads.arn
}

resource "aws_lambda_permission" "allow_dynamodb" {
  statement_id  = "AllowDynamoDB"
  action        = "lambda:InvokeFunction"
  principal     = "dynamodb.amazonaws.com"
  function_name = aws_lambda_function.file_metadata_extractor.function_name
  source_arn    = aws_dynamodb_table.metadata_table.arn
}
