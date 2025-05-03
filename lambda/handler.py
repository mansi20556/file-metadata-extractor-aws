import json
import boto3
import os

# Initialize S3 and DynamoDB clients
s3 = boto3.client('s3')
dynamodb = boto3.client('dynamodb')

# Set the bucket and table name
bucket_name = os.environ['S3_BUCKET_NAME']  # This can be set in Lambda environment variables
table_name = os.environ['DYNAMODB_TABLE_NAME']  # Set in Lambda environment variables

def lambda_handler(event, context):
    try:
        # Extract S3 object key from the event
        object_key = event['Records'][0]['s3']['object']['key']
        
        # Retrieve metadata from the S3 object
        metadata = s3.head_object(Bucket=bucket_name, Key=object_key)
        
        # Extract relevant metadata
        extracted_metadata = {
            'LockID': object_key,  # Example key, adjust as per your metadata
            'Timestamp': metadata['LastModified']
        }
        
        # Insert metadata into DynamoDB table
        dynamodb.put_item(
            TableName=table_name,
            Item={
                'LockID': {'S': extracted_metadata['LockID']},
                'Timestamp': {'S': extracted_metadata['Timestamp']}
            }
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps('Metadata processed successfully!')
        }
    
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error: {str(e)}")
        }
