# This file should be applied after the initial deployment
# to enable the S3 -> Lambda trigger

# Get the Lambda function ARN from the module output
data "aws_lambda_function" "mcp_trigger" {
  function_name = module.lambda.lambda_function_name
  depends_on    = [module.lambda]
}

# Get the S3 bucket from the module output
data "aws_s3_bucket" "mcp_bucket" {
  bucket = module.s3_bucket.bucket_name
  depends_on = [module.s3_bucket]
}

# Add the S3 notification configuration to trigger the Lambda
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = data.aws_s3_bucket.mcp_bucket.id

  lambda_function {
    lambda_function_arn = data.aws_lambda_function.mcp_trigger.arn
    events             = ["s3:ObjectCreated:*"]
  }

  # This ensures we don't create the notification until the Lambda permission is set
  depends_on = [
    module.lambda,
    module.s3_bucket
  ]
}

# Output the S3 bucket name for reference
output "s3_bucket_name" {
  value = module.s3_bucket.bucket_name
}

# Output the Lambda function name for reference
output "lambda_function_name" {
  value = module.lambda.lambda_function_name
}
