variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where resources will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "ecs_task_cpu" {
  description = "CPU units for the ECS task"
  type        = number
  default     = 256
}

variable "ecs_task_memory" {
  description = "Memory for the ECS task (MB)"
  type        = number
  default     = 512
}

variable "container_port" {
  description = "Port that the container exposes"
  type        = number
  default     = 8080
}

variable "container_image" {
  description = "The container image to use for the ECS task, including the repository URL and tag"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for the application"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
