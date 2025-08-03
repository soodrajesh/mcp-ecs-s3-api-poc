resource "aws_sns_topic" "alarms" {
  name = "${var.prefix}-alarms"
  tags = var.tags
}

# Allow CloudWatch to publish to this topic
resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.alarms.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]
    
    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
    
    resources = [aws_sns_topic.alarms.arn]
  }
}
