resource "aws_api_gateway_rest_api" "mcp_api" {
  name        = "${var.prefix}-mcp-api"
  description = "API Gateway for MCP Server"
}

resource "aws_api_gateway_resource" "mcp_resource" {
  path_part   = "{proxy+}"
  parent_id   = aws_api_gateway_rest_api.mcp_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.mcp_api.id
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id      = aws_api_gateway_rest_api.mcp_api.id
  resource_id      = aws_api_gateway_resource.mcp_resource.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "alb_integration" {
  rest_api_id = aws_api_gateway_rest_api.mcp_api.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.alb_dns_name}/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_deployment" "mcp_deployment" {
  depends_on = [
    aws_api_gateway_integration.alb_integration
  ]
  
  rest_api_id = aws_api_gateway_rest_api.mcp_api.id
  description = "MCP API deployment"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "mcp_stage" {
  deployment_id = aws_api_gateway_deployment.mcp_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.mcp_api.id
  stage_name    = var.stage_name
}

resource "aws_api_gateway_api_key" "mcp_api_key" {
  name        = "${var.prefix}-mcp-api-key"
  description = "API Key for MCP Server"
  enabled     = true
}

resource "aws_api_gateway_usage_plan" "mcp_usage_plan" {
  name        = "${var.prefix}-mcp-usage-plan"
  description = "Usage plan for MCP Server API"

  api_stages {
    api_id = aws_api_gateway_rest_api.mcp_api.id
    stage  = aws_api_gateway_stage.mcp_stage.stage_name
  }

  quota_settings {
    limit  = 1000
    period = "DAY"
  }

  throttle_settings {
    burst_limit = 5
    rate_limit  = 10
  }

  depends_on = [aws_api_gateway_stage.mcp_stage]
}

resource "aws_api_gateway_usage_plan_key" "mcp_usage_plan_key" {
  key_id        = aws_api_gateway_api_key.mcp_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.mcp_usage_plan.id
}

# Output the API key value
output "api_key_value" {
  value       = aws_api_gateway_api_key.mcp_api_key.value
  description = "The API key value (only visible once after creation)"
  sensitive   = true
}

output "api_endpoint" {
  value       = "https://${aws_api_gateway_rest_api.mcp_api.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.mcp_stage.stage_name}/"
  description = "The base URL of the API Gateway endpoint"
}
