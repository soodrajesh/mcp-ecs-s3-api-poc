variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-1"
}

variable "aws_profile" {
  description = "AWS profile to use for authentication"
  type        = string
  default     = "raj-private"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "mcp-s3-poc"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "ID of the existing VPC to use"
  type        = string
  default     = "vpc-011e66b8e1b66cf82"
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs to use for ECS tasks"
  type        = list(string)
  default     = ["subnet-0fc1f8aa9fbe3fdda", "subnet-049089cd5e6586ffd", "subnet-0adbeb3ce3ba0d644"]
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs to use for ALB"
  type        = list(string)
  default     = ["subnet-0fc1f8aa9fbe3fdda", "subnet-049089cd5e6586ffd", "subnet-0adbeb3ce3ba0d644"]
}

variable "ecs_task_cpu" {
  description = "CPU units for the ECS task"
  type        = number
  default     = 256
}

variable "ecs_task_memory" {
  description = "Memory in MB for the ECS task"
  type        = number
  default     = 512
}

variable "container_port" {
  description = "Port for the MCP server container"
  type        = number
  default     = 8080
}

variable "container_image" {
  description = "Container image to use for the MCP server"
  type        = string
  default     = "mcp-dev-mcp-server:latest"
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "container_image_tag" {
  description = "The tag of the container image to use in the ECS task"
  type        = string
  default     = "latest"
}

# API Gateway Variables
variable "api_gateway_stage_name" {
  description = "The name of the API Gateway stage"
  type        = string
  default     = "v1"
}

# Monitoring Variables
variable "alarm_email" {
  description = "Email address to receive CloudWatch alarm notifications"
  type        = string
  default     = "your-email@example.com"
}

variable "high_latency_threshold" {
  description = "Threshold in seconds for high latency alarm"
  type        = number
  default     = 2
}

# ECS Variables
variable "desired_task_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 1
}

# S3 Variables
variable "enable_s3_encryption" {
  description = "Enable server-side encryption for S3 bucket"
  type        = bool
  default     = true
}
