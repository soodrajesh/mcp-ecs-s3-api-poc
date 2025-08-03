variable "prefix" {
  description = "A prefix to use for resource names"
  type        = string
}

variable "alb_dns_name" {
  description = "The DNS name of the ALB to forward requests to"
  type        = string
}

variable "stage_name" {
  description = "The name of the API Gateway stage"
  type        = string
  default     = "v1"
}

variable "region" {
  description = "The AWS region where resources are deployed"
  type        = string
  default     = "eu-west-1"
}
