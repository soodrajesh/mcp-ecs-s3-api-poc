variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "sns_topic_arn" {
  description = "The ARN of the SNS topic to notify when alarms are triggered"
  type        = string
}

variable "alb_arn_suffix" {
  description = "The ARN suffix of the ALB to monitor"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "The ARN suffix of the target group to monitor"
  type        = string
}

variable "log_group_name" {
  description = "The name of the CloudWatch log group to monitor for errors"
  type        = string
  default     = "/ecs/mcp-task"
}

variable "create_log_group" {
  description = "Whether to create the CloudWatch log group"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}
