locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# EMPAQUETADO DEL CÓDIGO 

data "archive_file" "upload_lambda" {
  type        = "zip"
  source_dir  = "${path.root}/../src/upload-lambda"
  output_path = "${path.root}/../src/upload-lambda.zip"
}

data "archive_file" "crop_lambda" {
  type        = "zip"
  source_dir  = "${path.root}/../src/crop-lambda"
  output_path = "${path.root}/../src/crop-lambda.zip"
}

# SECURITY GROUP UPLOAD LAMBDA 

resource "aws_security_group" "upload_lambda" {
  name        = "${local.name_prefix}-upload-lambda-sg"
  description = "SG para la upload-lambda"
  vpc_id      = var.vpc_id

  egress {
    description = "HTTPS hacia VPC Endpoints"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.name_prefix}-upload-lambda-sg"
    Environment = var.environment
  }
}

# SECURITY GROUP CROP LAMBDA 

resource "aws_security_group" "crop_lambda" {
  name        = "${local.name_prefix}-crop-lambda-sg"
  description = "SG para la crop-lambda"
  vpc_id      = var.vpc_id

  egress {
    description = "HTTPS hacia VPC Endpoints"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.name_prefix}-crop-lambda-sg"
    Environment = var.environment
  }
}

# IAM ROLE UPLOAD LAMBDA 

resource "aws_iam_role" "upload_lambda" {
  name = "${local.name_prefix}-upload-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${local.name_prefix}-upload-lambda-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "upload_basic" {
  role       = aws_iam_role.upload_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "upload_vpc" {
  role       = aws_iam_role.upload_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "upload_s3" {
  name = "${local.name_prefix}-upload-s3-policy"
  role = aws_iam_role.upload_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${var.bucket_arn}/${var.upload_prefix}*"
      }
    ]
  })
}

# IAM ROLE CROP LAMBDA 

resource "aws_iam_role" "crop_lambda" {
  name = "${local.name_prefix}-crop-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${local.name_prefix}-crop-lambda-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "crop_basic" {
  role       = aws_iam_role.crop_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "crop_vpc" {
  role       = aws_iam_role.crop_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "crop_s3_sqs" {
  name = "${local.name_prefix}-crop-s3-sqs-policy"
  role = aws_iam_role.crop_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "S3ReadUploads"
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${var.bucket_arn}/${var.upload_prefix}*"
      },
      {
        Sid      = "S3WriteProcessed"
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${var.bucket_arn}/${var.processed_prefix}*"
      },
      {
        Sid    = "SQSAccess"
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = var.sqs_queue_arn
      }
    ]
  })
}

# LOG GROUPS 

resource "aws_cloudwatch_log_group" "upload_lambda" {
  name              = "/aws/lambda/${local.name_prefix}-upload"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_log_group" "crop_lambda" {
  name              = "/aws/lambda/${local.name_prefix}-crop"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# UPLOAD LAMBDA 

resource "aws_lambda_function" "upload" {
  function_name = "${local.name_prefix}-upload"
  role          = aws_iam_role.upload_lambda.arn
  runtime       = "nodejs20.x"
  handler       = "index.handler"
  memory_size   = var.upload_lambda_memory
  timeout       = var.upload_lambda_timeout

  filename         = data.archive_file.upload_lambda.output_path
  source_code_hash = data.archive_file.upload_lambda.output_base64sha256

  environment {
    variables = {
      S3_BUCKET     = var.bucket_name
      UPLOAD_PREFIX = var.upload_prefix
      AWS_ACCOUNT   = data.aws_caller_identity.current.account_id
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.upload_lambda.id]
  }

  depends_on = [
    aws_cloudwatch_log_group.upload_lambda,
    aws_iam_role_policy_attachment.upload_basic,
    aws_iam_role_policy_attachment.upload_vpc
  ]

  tags = {
    Name        = "${local.name_prefix}-upload"
    Environment = var.environment
    Project     = var.project_name
  }
}

# CROP LAMBDA 

resource "aws_lambda_function" "crop" {
  function_name = "${local.name_prefix}-crop"
  role          = aws_iam_role.crop_lambda.arn
  runtime       = "nodejs20.x"
  handler       = "index.handler"
  memory_size   = var.crop_lambda_memory
  timeout       = var.crop_lambda_timeout

  filename         = data.archive_file.crop_lambda.output_path
  source_code_hash = data.archive_file.crop_lambda.output_base64sha256

  environment {
    variables = {
      S3_BUCKET        = var.bucket_name
      PROCESSED_PREFIX = var.processed_prefix
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.crop_lambda.id]
  }

  depends_on = [
    aws_cloudwatch_log_group.crop_lambda,
    aws_iam_role_policy_attachment.crop_basic,
    aws_iam_role_policy_attachment.crop_vpc
  ]

  tags = {
    Name        = "${local.name_prefix}-crop"
    Environment = var.environment
    Project     = var.project_name
  }
}

# SQS TRIGGER 

resource "aws_lambda_event_source_mapping" "sqs_crop" {
  event_source_arn                   = var.sqs_queue_arn
  function_name                      = aws_lambda_function.crop.arn
  batch_size                         = var.sqs_batch_size
  maximum_batching_window_in_seconds = 0

  function_response_types = ["ReportBatchItemFailures"]

  depends_on = [aws_iam_role_policy.crop_s3_sqs]
}

data "aws_caller_identity" "current" {}