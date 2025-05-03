terraform {
  backend "s3" {
    bucket         = "file-metadata-extract"
    key            = "lambda-project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "MetadataTable"
    encrypt        = true
  }
}