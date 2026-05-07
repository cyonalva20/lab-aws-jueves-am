# PROVIDER 

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  profile = "mi-perfil"

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# MÓDULO NETWORKING 

module "networking" {
  source = "./modules/networking"

  project_name         = var.project_name
  environment          = var.environment
  aws_region           = var.aws_region
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# MÓDULO SQS 

module "sqs" {
  source = "./modules/sqs"

  project_name      = var.project_name
  environment       = var.environment
  visibility_timeout = var.sqs_visibility_timeout
  message_retention = var.sqs_message_retention
  dlq_retention     = var.sqs_dlq_retention
  max_receive_count = var.sqs_max_receive_count

  bucket_arn = module.s3.bucket_arn
}

# MÓDULO S3 

module "s3" {
  source = "./modules/s3"

  project_name              = var.project_name
  environment               = var.environment
  uploads_expiration_days   = var.uploads_expiration_days
  processed_expiration_days = var.processed_expiration_days
  sqs_queue_arn             = module.sqs.queue_arn
}

# MÓDULO LAMBDA 

module "lambda" {
  source = "./modules/lambda"

  project_name          = var.project_name
  environment           = var.environment
  aws_region            = var.aws_region
  upload_lambda_memory  = var.upload_lambda_memory
  upload_lambda_timeout = var.upload_lambda_timeout
  crop_lambda_memory    = var.crop_lambda_memory
  crop_lambda_timeout   = var.crop_lambda_timeout
  sqs_batch_size        = var.sqs_batch_size
  log_retention_days    = var.log_retention_days

  # Networking
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids

  # S3
  bucket_name      = module.s3.bucket_name
  bucket_arn       = module.s3.bucket_arn
  upload_prefix    = module.s3.upload_prefix
  processed_prefix = module.s3.processed_prefix

  # SQS
  sqs_queue_arn = module.sqs.queue_arn
  sqs_queue_url = module.sqs.queue_url
}

# MÓDULO API GATEWAY 

module "api_gateway" {
  source = "./modules/api_gateway"

  project_name       = var.project_name
  environment        = var.environment
  aws_region         = var.aws_region
  log_retention_days = var.log_retention_days

  # Lambda
  upload_lambda_arn  = module.lambda.upload_lambda_arn
  upload_lambda_name = module.lambda.upload_lambda_name
}

# MÓDULO OBSERVABILITY 

module "observability" {
  source = "./modules/observability"

  project_name    = var.project_name
  environment     = var.environment
  sns_alarm_email = var.sns_alarm_email

  # SQS DLQ
  dlq_arn  = module.sqs.dlq_arn
  dlq_name = module.sqs.dlq_name

  # Lambdas
  upload_lambda_name = module.lambda.upload_lambda_name
  crop_lambda_name   = module.lambda.upload_lambda_name

  # API Gateway
  api_id = module.api_gateway.api_id
}