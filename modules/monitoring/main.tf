resource "aws_cloudwatch_metric_alarm" "mcp_5xx_errors" {
  alarm_name          = "${var.prefix}-mcp-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors 5XX errors from the MCP server"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "mcp_latency" {
  alarm_name          = "${var.prefix}-mcp-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "2"  # 2 seconds
  alarm_description   = "This metric monitors high latency from the MCP server"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }
}

resource "aws_cloudwatch_log_group" "mcp_logs" {
  count             = var.create_log_group ? 1 : 0
  name              = var.log_group_name
  retention_in_days = 30
  tags              = var.tags
}

resource "aws_cloudwatch_log_metric_filter" "mcp_errors" {
  name           = "${var.prefix}-mcp-error-logs"
  pattern        = "ERROR"
  log_group_name = var.create_log_group ? aws_cloudwatch_log_group.mcp_logs[0].name : var.log_group_name

  metric_transformation {
    name      = "MCPErrorCount"
    namespace = "MCP/Logs"
    value     = "1"
  }

  # Only create the filter if we're creating the log group
  # or if the log group name is provided and we're not creating it
  count = var.create_log_group || var.log_group_name != null ? 1 : 0
}

resource "aws_cloudwatch_metric_alarm" "mcp_error_logs" {
  alarm_name          = "${var.prefix}-mcp-error-logs"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "MCPErrorCount"
  namespace           = "MCP/Logs"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors error logs from the MCP server"
  alarm_actions       = [var.sns_topic_arn]

  # Add depends_on to ensure the metric filter is created first
  depends_on = [aws_cloudwatch_log_metric_filter.mcp_errors]
}
