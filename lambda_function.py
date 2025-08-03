import boto3
import json
import os


def lambda_handler(event, context):
    """
    Lambda function that gets triggered when a new file is uploaded to S3.
    It updates the ECS service to ensure it's running to process the new file.
    """
    try:
        # Get environment variables
        cluster = os.environ.get('ECS_CLUSTER')
        service = os.environ.get('ECS_SERVICE')

        if not all([cluster, service]):
            raise ValueError("Missing required environment variables")

        # Initialize ECS client
        ecs = boto3.client('ecs')

        # Update the ECS service to ensure it's running
        # Update the ECS service to ensure it's running
        ecs.update_service(
            cluster=cluster,
            service=service,
            forceNewDeployment=True
        )

        return {
            'statusCode': 200,
            'body': json.dumps('Successfully triggered ECS service update')
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        raise e
