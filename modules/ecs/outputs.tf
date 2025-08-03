output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.mcp_cluster.name
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.mcp_service.name
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.mcp_alb.dns_name
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.mcp_tg.arn
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = aws_lb.mcp_alb.arn
}
