provider "aws" {
  region = var.aws_region
}

# Reference existing S3 bucket
data "aws_s3_bucket" "uploads" {
  bucket = "extract-file-metadata"
}

# Reference existing DynamoDB table
data "aws_dynamodb_table" "metadata_table" {
  name = "file-metadata"
}

# Reference existing IAM role
data "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
}

# Reference existing Lambda function
data "aws_lambda_function" "file_metadata_extractor" {
  function_name = "fileMetadataExtractor"
}

# Create Lambda function permission if needed (not referencing an existing one)
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.file_metadata_extractor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.uploads.arn
}

# S3 event to trigger Lambda (use existing resources)
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = data.aws_s3_bucket.uploads.id

  lambda_function {
    lambda_function_arn = data.aws_lambda_function.file_metadata_extractor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

