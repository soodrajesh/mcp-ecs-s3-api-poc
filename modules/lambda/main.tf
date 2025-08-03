resource "aws_lambda_function" "mcp_trigger" {
  function_name    = "${var.project_name}-${var.environment}-trigger"
  filename         = "${path.module}/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  role             = aws_iam_role.lambda_exec.arn
  timeout          = 30
  memory_size      = 128

  environment {
    variables = {
      ECS_CLUSTER     = var.ecs_cluster_name
      ECS_SERVICE     = "${var.project_name}-${var.environment}-service"
      REGION          = data.aws_region.current.name
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-lambda"
    Environment = var.environment
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_name}-${var.environment}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-lambda-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_ecs" {
  name = "${var.project_name}-${var.environment}-lambda-ecs-policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mcp_trigger.arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn
}
