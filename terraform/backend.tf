terraform {
  backend "s3" {
    bucket         = "extract-file-metadata"
    key            = "lambda-project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "file-metadata"
    encrypt        = true
  }
}