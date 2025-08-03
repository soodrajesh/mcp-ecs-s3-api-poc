import boto3
import os


def lambda_handler(event, context):
    """
    Lambda function to trigger ECS service update when a new file is uploaded to S3.
    """
    # Get environment variables
    ecs_cluster = os.environ['ECS_CLUSTER']
    ecs_service = os.environ['ECS_SERVICE']
    region = os.environ['REGION']

    # Initialize ECS client
    ecs = boto3.client('ecs', region_name=region)

    try:
        # Update the ECS service to force a new deployment
        ecs.update_service(
            cluster=ecs_cluster,
            service=ecs_service,
            forceNewDeployment=True
        )

        print(
            f"Successfully triggered update for service {ecs_service} "
            f"in cluster {ecs_cluster}"
        )
        return {
            'statusCode': 200,
            'body': f"Successfully triggered update for service {ecs_service}"
        }

    except Exception as e:
        print(f"Error updating ECS service: {str(e)}")
        raise e
