variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function to trigger on S3 events"
  type        = string
  default     = ""
}

variable "enable_lambda_trigger" {
  description = "Whether to enable the Lambda trigger on the S3 bucket"
  type        = bool
  default     = false
}
