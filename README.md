# AWS S3 Metadata Extractor (Lambda + DynamoDB)

This project automatically extracts metadata of files uploaded to an S3 bucket using AWS Lambda, and stores it in a DynamoDB table.

## 🔧 How It Works

1. **You upload a file to S3**.
2. **Lambda is triggered** via S3 event.
3. **Lambda extracts metadata** like file name, size, content type, etc.
4. **Metadata is stored** in a DynamoDB table.

## 📁 Metadata Captured

- FileName  
- Bucket  
- Size  
- ContentType  
- LastModified  
- ETag

## 🧱 Prerequisites

You need the following AWS resources set up **from the AWS Console**:

- ✅ An **S3 bucket**
- ✅ A **DynamoDB table**
- ✅ A **Lambda function** with the `lambda_function.py` code
- ✅ An **IAM Role** attached to Lambda with permissions for:
  - S3: `GetObject`, `ListBucket`
  - DynamoDB: `PutItem`
- ✅ **S3 event notification** configured to trigger Lambda on file uploads

## 🚀 Deployment Steps

> All steps are done from AWS Console:

1. **Create S3 bucket**.
2. **Create DynamoDB table** with `FileName` as the partition key.
3. **Create Lambda function** with the `lambda_function.py` code.
4. **Set environment variable** `DYNAMODB_TABLE` with your table name.
5. **Attach IAM role** to Lambda with S3 + DynamoDB access.
6. **Set S3 event trigger** to invoke Lambda on new uploads.
7. Upload a file to the S3 bucket — metadata will appear in DynamoDB!

## 🧪 Testing

- Upload any file to your S3 bucket.
- Go to **DynamoDB → Explore Table Items** to view metadata.

## 📂 File Structure

