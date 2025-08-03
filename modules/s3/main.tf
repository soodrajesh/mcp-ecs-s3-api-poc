resource "aws_s3_bucket" "mcp_bucket" {
  bucket = "${var.project_name}-${var.environment}-${var.aws_account_id}"
  force_destroy = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-bucket"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "mcp_bucket_access" {
  bucket = aws_s3_bucket.mcp_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# This will be created separately after the Lambda function exists

# This will be created separately after the Lambda function exists
