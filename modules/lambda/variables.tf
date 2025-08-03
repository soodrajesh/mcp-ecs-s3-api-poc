variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket that will trigger the Lambda"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster where the service is running"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service to update"
  type        = string
  default     = "mcp-service"
}

variable "timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Amount of memory in MB the Lambda function can use"
  type        = number
  default     = 128
}

variable "runtime" {
  description = "Lambda function runtime"
  type        = string
  default     = "python3.9"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
