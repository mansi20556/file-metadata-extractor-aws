output "s3_bucket_name" {
  value = data.aws_s3_bucket.uploads.id
}

output "lambda_function_name" {
  value = data.aws_lambda_function.file_metadata_extractor.function_name
}

output "dynamodb_table_name" {
  value = data.aws_dynamodb_table.metadata_table.name
}

output "dynamodb_table_arn" {
  value = data.aws_dynamodb_table.metadata_table.arn
}

output "lambda_role_arn" {
  value = data.aws_iam_role.lambda_exec_role.arn
}
