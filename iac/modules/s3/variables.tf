variable "project_name" {
  description = "Nombre base del proyecto"
  type        = string
}

variable "environment" {
  description = "Entorno: dev, qa, prod"
  type        = string
}

variable "uploads_expiration_days" {
  description = "Días antes de que expiren las imágenes originales"
  type        = number
}

variable "processed_expiration_days" {
  description = "Días antes de que expiren las imágenes procesadas"
  type        = number
}

variable "sqs_queue_arn" {
  description = "ARN de la cola SQS para notificaciones de S3"
  type        = string
}