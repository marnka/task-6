import boto3
import os

s3 = boto3.client('s3')

def lambda_handler(event, context):
    source_bucket = 's3-start'
    destination_bucket = 's3-finish'
    
    for record in event['Records']:
        key = record['s3']['object']['key']
        
        copy_source = {
            'Bucket': source_bucket,
            'Key': key
        }

        try:
            s3.copy_object(CopySource=copy_source, Bucket=destination_bucket, Key=key)
            print(f'Successfully copied {key} from {source_bucket} to {destination_bucket}')
        except Exception as e:
            print(f'Error copying {key}: {str(e)}')
