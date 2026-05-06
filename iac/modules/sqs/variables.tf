variable "project_name" {
  description = "Nombre base del proyecto"
  type        = string
}

variable "environment" {
  description = "Entorno: dev, qa, prod"
  type        = string
}

variable "visibility_timeout" {
  description = "Segundos que un mensaje es invisible mientras se procesa"
  type        = number
}

variable "message_retention" {
  description = "Segundos que SQS retiene mensajes en la cola principal"
  type        = number
}

variable "dlq_retention" {
  description = "Segundos que SQS retiene mensajes en la DLQ"
  type        = number
}

variable "max_receive_count" {
  description = "Veces que un mensaje puede fallar antes de ir a la DLQ"
  type        = number
}

variable "bucket_arn" {
  description = "ARN del bucket S3 para la policy de la cola"
  type        = string
}