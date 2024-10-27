# views.py

from django.http import JsonResponse
import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError
import os
from dotenv import load_dotenv
from django.conf import settings
import psycopg2
from django.http import HttpResponse



def test_s3(request):
    s3 = boto3.client(
        's3',
        aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID'),
        aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY'),
        region_name=os.getenv('AWS_REGION')
    )

    bucket_name = 'cogbuck123'
    
    try:
        response = s3.list_objects_v2(Bucket=bucket_name)
        contents = [obj['Key'] for obj in response.get('Contents', [])]
        return JsonResponse({"status": "S3-CONNECTION SUCCESS!", "files": contents})
    
    except NoCredentialsError:
        return JsonResponse({"status": "error", "message": "Credentials not available."})
    except PartialCredentialsError:
        return JsonResponse({"status": "error", "message": "Incomplete credentials provided."})
    except Exception as e:
        return JsonResponse({"status": "error", "message": str(e)})
    

def test_db_connection(request):
    try:
        # Fetch RDS database credentials from environment variables
        db_name = os.getenv('RDS_DB_NAME')
        db_user = os.getenv('RDS_USERNAME')
        db_password = os.getenv('RDS_PASSWORD')
        db_host = os.getenv('RDS_HOSTNAME')
        db_port = os.getenv('RDS_PORT')

        # Establish the database connection
        connection = psycopg2.connect(
            dbname=db_name,
            user=db_user,
            password=db_password,
            host=db_host,
            port=db_port
        )
        
        # Close the connection
        connection.close()

        return JsonResponse({'status': 'success', 'message': 'PostgreSQL RDS-connection is a SUCCESS!'})
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})    


