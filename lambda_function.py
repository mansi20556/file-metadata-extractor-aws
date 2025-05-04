import boto3
import os
import json
import urllib.parse

dynamodb = boto3.resource('dynamodb')
s3_client = boto3.client('s3')
table_name = os.environ['DYNAMODB_TABLE']
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    print("Received event:", json.dumps(event))

    for record in event['Records']:
        try:
            s3_info = record['s3']
            bucket_name = s3_info['bucket']['name']
            file_name = urllib.parse.unquote_plus(s3_info['object']['key'])

            response = s3_client.head_object(Bucket=bucket_name, Key=file_name)
            file_size = response['ContentLength']
            content_type = response['ContentType']
            last_modified = response['LastModified'].isoformat()
            etag = response['ETag']

            metadata = {
                'FileName': file_name,
                'Bucket': bucket_name,
                'Size': file_size,
                'ContentType': content_type,
                'LastModified': last_modified,
                'ETag': etag
            }

            print("Writing to DynamoDB:", metadata)
            table.put_item(Item=metadata)

        except Exception as e:
            print(f"Error processing record: {str(e)}")

    return {
        'statusCode': 200,
        'body': json.dumps('Metadata processing complete')
    }
