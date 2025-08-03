#!/bin/bash
set -e

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/.."  # Move to project root

# Load environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Check if AWS profile is set
if [ -z "$AWS_PROFILE" ]; then
    echo "AWS_PROFILE environment variable is not set. Please set it in .env file."
    exit 1
fi

# Check if AWS region is set
if [ -z "$AWS_REGION" ]; then
    AWS_REGION="eu-west-1"  # Default region
fi

# Get ECR repository URL from Terraform output
ECR_REPO_URL=$(terraform output -raw ecr_repository_url 2>/dev/null || true)

if [ -z "$ECR_REPO_URL" ]; then
    echo "Error: Could not get ECR repository URL from Terraform output."
    echo "Terraform output:"
    terraform output
    echo "\nMake sure you've run 'terraform apply' to create the ECR repository."
    exit 1
fi

# Extract repository name from URL
REPO_NAME=$(echo $ECR_REPO_URL | cut -d'/' -f2)

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text --profile $AWS_PROFILE)
if [ $? -ne 0 ]; then
    echo "Error: Failed to get AWS account ID. Make sure your AWS credentials are configured correctly."
    exit 1
fi

# Login to ECR
echo "Logging in to ECR..."
aws ecr get-login-password --region $AWS_REGION --profile $AWS_PROFILE | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build the Docker image for linux/amd64 platform
echo "Building Docker image for linux/amd64 platform..."
docker build --platform linux/amd64 -t $REPO_NAME -f Dockerfile.mcp .

# Tag the image for ECR
IMAGE_TAG="latest"
ECR_IMAGE_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$IMAGE_TAG"
docker tag $REPO_NAME:latest $ECR_IMAGE_URI

# Push the image to ECR
echo "Pushing image to ECR..."
docker push $ECR_IMAGE_URI

echo "Image pushed successfully to: $ECR_IMAGE_URI"

# Update the ECS task definition with the new image
# This is a placeholder - you might want to update your ECS service to use the new image
echo "To update your ECS service with the new image, run:"
echo "aws ecs update-service --cluster <cluster-name> --service <service-name> --force-new-deployment --region $AWS_REGION --profile $AWS_PROFILE"
