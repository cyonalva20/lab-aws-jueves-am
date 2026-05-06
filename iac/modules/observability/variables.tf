variable "project_name" {
  description = "Nombre base del proyecto"
  type        = string
}

variable "environment" {
  description = "Entorno: dev, qa, prod"
  type        = string
}

variable "dlq_arn" {
  description = "ARN de la DLQ — para la alarma de CloudWatch"
  type        = string
}

variable "dlq_name" {
  description = "Nombre de la DLQ — para la métrica de CloudWatch"
  type        = string
}

variable "sns_alarm_email" {
  description = "Email que recibe alertas cuando la DLQ tiene mensajes"
  type        = string
}

variable "upload_lambda_name" {
  description = "Nombre de la upload-lambda — para el dashboard"
  type        = string
}

variable "crop_lambda_name" {
  description = "Nombre de la crop-lambda — para el dashboard"
  type        = string
}

variable "api_id" {
  description = "ID del API Gateway — para el dashboard"
  type        = string
}