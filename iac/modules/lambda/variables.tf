variable "project_name" {
  description = "Nombre base del proyecto"
  type        = string
}

variable "environment" {
  description = "Entorno: dev, qa, prod"
  type        = string
}

variable "aws_region" {
  description = "Región de AWS"
  type        = string
}

variable "upload_lambda_memory" {
  description = "Memoria en MB para la upload-lambda"
  type        = number
}

variable "upload_lambda_timeout" {
  description = "Timeout en segundos para la upload-lambda"
  type        = number
}

variable "crop_lambda_memory" {
  description = "Memoria en MB para la crop-lambda"
  type        = number
}

variable "crop_lambda_timeout" {
  description = "Timeout en segundos para la crop-lambda"
  type        = number
}

variable "sqs_batch_size" {
  description = "Cantidad de mensajes SQS que procesa la crop-lambda por invocación"
  type        = number
}

variable "bucket_name" {
  description = "Nombre del bucket S3"
  type        = string
}

variable "bucket_arn" {
  description = "ARN del bucket S3"
  type        = string
}

variable "upload_prefix" {
  description = "Prefijo para imágenes originales"
  type        = string
}

variable "processed_prefix" {
  description = "Prefijo para imágenes procesadas"
  type        = string
}

variable "sqs_queue_arn" {
  description = "ARN de la cola SQS principal"
  type        = string
}

variable "sqs_queue_url" {
  description = "URL de la cola SQS principal"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs de las subnets privadas donde viven las Lambdas"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "log_retention_days" {
  description = "Días de retención de logs en CloudWatch"
  type        = number
}