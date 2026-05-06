locals {
  name_prefix = "${var.project_name}-${var.environment}"
  bucket_name = "${local.name_prefix}-images-${data.aws_caller_identity.current.account_id}"
}
data "aws_caller_identity" "current" {}

# BUCKET PRINCIPAL 

resource "aws_s3_bucket" "images" {
  bucket = local.bucket_name
  force_destroy = var.environment != "prod"

  tags = {
    Name        = local.bucket_name
    Environment = var.environment
    Project     = var.project_name
  }
}

# VERSIONADO

resource "aws_s3_bucket_versioning" "images" {
  bucket = aws_s3_bucket.images.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ENCRIPTACIÓN

resource "aws_s3_bucket_server_side_encryption_configuration" "images" {
  bucket = aws_s3_bucket.images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# BLOQUEO DE ACCESO PÚBLICO

resource "aws_s3_bucket_public_access_block" "images" {
  bucket = aws_s3_bucket.images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# LIFECYCLE RULES

resource "aws_s3_bucket_lifecycle_configuration" "images" {
  bucket = aws_s3_bucket.images.id

  # Regla para imágenes originales
  rule {
    id     = "expire-uploads"
    status = "Enabled"

    filter {
      prefix = "uploads/"
    }

    expiration {
      days = var.uploads_expiration_days
    }
    noncurrent_version_expiration {
      noncurrent_days = var.uploads_expiration_days
    }
  }
  rule {
    id     = "expire-processed"
    status = "Enabled"

    filter {
      prefix = "processed/"
    }

    expiration {
      days = var.processed_expiration_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.processed_expiration_days
    }
  }
}

# NOTIFICACIÓN A SQS

resource "aws_s3_bucket_notification" "images" {
  bucket = aws_s3_bucket.images.id

  queue {
    queue_arn     = var.sqs_queue_arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "uploads/"
  }

  depends_on = [aws_s3_bucket.images]
}