resource "aws_ecr_repository" "mcp_server" {
  name                 = "${var.project_name}-${var.environment}-mcp-server"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-mcp-server"
    }
  )
}

# Output the repository URL
output "repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.mcp_server.repository_url
}
