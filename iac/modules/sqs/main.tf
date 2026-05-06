locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# DEAD LETTER QUEUE

resource "aws_sqs_queue" "dlq" {
  name                      = "${local.name_prefix}-image-dlq"
  message_retention_seconds = var.dlq_retention

  tags = {
    Name        = "${local.name_prefix}-image-dlq"
    Environment = var.environment
    Project     = var.project_name
  }
}

# COLA PRINCIPAL

resource "aws_sqs_queue" "main" {
  name                       = "${local.name_prefix}-image-queue"
  visibility_timeout_seconds = var.visibility_timeout
  message_retention_seconds  = var.message_retention
  receive_wait_time_seconds = 20
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = {
    Name        = "${local.name_prefix}-image-queue"
    Environment = var.environment
    Project     = var.project_name
  }
}

# POLICY DE LA COLA

resource "aws_sqs_queue_policy" "main" {
  queue_url = aws_sqs_queue.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3ToSendMessages"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.main.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = var.bucket_arn
          }
        }
      }
    ]
  })
}