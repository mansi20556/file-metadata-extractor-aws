import json
import boto3
import os

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    dynamodb = boto3.resource('dynamodb')
    table_name = os.environ['DYNAMODB_TABLE']
    table = dynamodb.Table(table_name)

    # Get bucket name and object key from the event
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    object_key = event['Records'][0]['s3']['object']['key']

    # Fetch metadata using head_object
    metadata = s3.head_object(Bucket=bucket_name, Key=object_key)

    # Extract useful metadata
    item = {
        'FileName': object_key,
        'Size': metadata['ContentLength'],
        'ContentType': metadata['ContentType'],
        'LastModified': str(metadata['LastModified']),
        'ETag': metadata['ETag']
    }

    # Store metadata in DynamoDB
    table.put_item(Item=item)

    return {
        'statusCode': 200,
        'body': json.dumps('Metadata extracted and stored successfully!')
    }
