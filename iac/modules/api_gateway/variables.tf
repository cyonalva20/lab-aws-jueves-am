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

variable "upload_lambda_arn" {
  description = "ARN de la upload-lambda"
  type        = string
}

variable "upload_lambda_name" {
  description = "Nombre de la upload-lambda — para dar permisos de invocación"
  type        = string
}

variable "log_retention_days" {
  description = "Días de retención de logs en CloudWatch"
  type        = number
}