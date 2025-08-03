locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Data source for existing VPC
data "aws_vpc" "main" {
  id = var.vpc_id
}

# Data source for existing subnets
data "aws_subnet" "private" {
  count = length(var.private_subnet_ids)
  id    = var.private_subnet_ids[count.index]
}

# ECR Repository for MCP Server
module "ecr" {
  source = "./modules/ecr"
  
  project_name = var.project_name
  environment = var.environment
  tags        = local.common_tags
}

# S3 Bucket - First create without Lambda trigger to avoid circular dependency
module "s3_bucket" {
  source = "./modules/s3"
  
  project_name   = var.project_name
  environment   = var.environment
  aws_account_id = data.aws_caller_identity.current.account_id
  
  # Disable Lambda trigger initially to break circular dependency
  enable_lambda_trigger = false
  
  tags = local.common_tags
}

# ECS Cluster and Service
module "ecs" {
  source = "./modules/ecs"
  
  project_name = var.project_name
  environment = var.environment
  
  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  public_subnet_ids  = var.public_subnet_ids
  
  ecs_task_cpu       = var.ecs_task_cpu
  ecs_task_memory    = var.ecs_task_memory
  container_port     = var.container_port
  container_image    = var.container_image
  s3_bucket_name     = module.s3_bucket.bucket_name
  
  tags = local.common_tags
}

# Lambda Function
module "lambda" {
  source = "./modules/lambda"
  
  project_name = var.project_name
  environment = var.environment
  
  s3_bucket_arn    = module.s3_bucket.bucket_arn
  ecs_cluster_name = module.ecs.ecs_cluster_name
  
  tags = local.common_tags
}

# SNS Topic for CloudWatch Alarms
module "sns" {
  source = "./modules/sns"
  
  prefix = local.name_prefix
  tags   = local.common_tags
}

# Monitoring - CloudWatch Alarms and Metrics
module "monitoring" {
  source = "./modules/monitoring"
  
  prefix                 = local.name_prefix
  sns_topic_arn         = module.sns.topic_arn
  alb_arn_suffix        = split("/", module.ecs.alb_arn)[1]  # Extract the ALB name from ARN
  target_group_arn_suffix = split("/", module.ecs.target_group_arn)[1]  # Extract the target group name from ARN
  log_group_name        = "/ecs/${local.name_prefix}-task"
  create_log_group      = true
  tags                  = local.common_tags
  
  depends_on = [module.ecs]
}

# API Gateway with API Key Authentication
module "api_gateway" {
  source = "./modules/api_gateway"
  
  prefix     = local.name_prefix
  alb_dns_name = module.ecs.alb_dns_name
  stage_name = var.environment
  
  depends_on = [module.ecs]
}

# Outputs
output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "ecs_cluster_name" {
  value = module.ecs.ecs_cluster_name
}

output "ecs_service_name" {
  value = module.ecs.ecs_service_name
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = module.ecs.alb_dns_name
}

output "api_gateway_endpoint" {
  description = "The base URL of the API Gateway endpoint"
  value       = module.api_gateway.api_endpoint
}

output "api_key" {
  description = "The API key for accessing the MCP API (save this as it's only shown once)"
  value       = module.api_gateway.api_key_value
  sensitive   = true
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic for CloudWatch alarms"
  value       = module.sns.topic_arn
}
