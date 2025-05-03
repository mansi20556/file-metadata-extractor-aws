provider "aws" {
  region = var.aws_region
}

# Create an S3 bucket to trigger Lambda when files are uploaded
resource "aws_s3_bucket" "uploads" {
  bucket = "mansi-upload-bucket"
  force_destroy = true
}

# Create IAM role for Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach inline policy with S3 + DynamoDB + logs permissions to IAM Role
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:HeadObject"
        ],
        Effect = "Allow",
        Resource = [
          aws_s3_bucket.uploads.arn,
          "${aws_s3_bucket.uploads.arn}/*"
        ]
      },
      {
        Action = [
          "dynamodb:PutItem"
        ],
        Effect = "Allow",
        Resource = aws_dynamodb_table.metadata_table.arn
      }
    ]
  })
}

# Create DynamoDB table to store metadata
resource "aws_dynamodb_table" "metadata_table" {
  name           = "MetadataTable"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "FileName"

  attribute {
    name = "FileName"
    type = "S"
  }
}

# Create Lambda Function
resource "aws_lambda_function" "file_metadata_extractor" {
  function_name = "fileMetadataExtractor"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"
  filename      = "../lambda.zip"
  timeout       = 10

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.metadata_table.name
    }
  }
}

# S3 event to trigger Lambda
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.uploads.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.file_metadata_extractor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

# Grant S3 permission to invoke Lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.file_metadata_extractor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.uploads.arn
}