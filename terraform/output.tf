output "s3_bucket_name" {
  value = aws_s3_bucket.uploads.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.metadata_table.name
}

output "lambda_function_name" {
  value = aws_lambda_function.file_metadata_extractor.function_name
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_exec_role.arn
}