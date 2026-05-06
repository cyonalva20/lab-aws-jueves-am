# GENERAL 

variable "aws_region" {
  description = "Región de AWS donde se despliega todo"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Entorno de despliegue: dev, qa o prod"
  type        = string
  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "El entorno debe ser dev, qa o prod"
  }
}

variable "project_name" {
  description = "Nombre base del proyecto, se usa para nombrar todos los recursos"
  type        = string
  default     = "image-processor"
}

# NETWORKING 

variable "vpc_cidr" {
  description = "CIDR block de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs de las subnets públicas (una por AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs de las subnets privadas (una por AZ)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

# S3 

variable "uploads_expiration_days" {
  description = "Días antes de que expiren las imágenes originales en uploads/"
  type        = number
  default     = 30
}

variable "processed_expiration_days" {
  description = "Días antes de que expiren las imágenes procesadas en processed/"
  type        = number
  default     = 90
}

# SQS 

variable "sqs_visibility_timeout" {
  description = "Segundos que un mensaje es invisible mientras se procesa (debe ser 6x el timeout de la lambda)"
  type        = number
  default     = 360
}

variable "sqs_message_retention" {
  description = "Segundos que SQS retiene mensajes en la cola principal"
  type        = number
  default     = 86400 # 1 día
}

variable "sqs_dlq_retention" {
  description = "Segundos que SQS retiene mensajes en la DLQ"
  type        = number
  default     = 1209600 # 14 días
}

variable "sqs_max_receive_count" {
  description = "Veces que un mensaje puede fallar antes de ir a la DLQ"
  type        = number
  default     = 3
}

# LAMBDA 

variable "upload_lambda_memory" {
  description = "Memoria en MB para la upload-lambda"
  type        = number
  default     = 256
}

variable "upload_lambda_timeout" {
  description = "Timeout en segundos para la upload-lambda"
  type        = number
  default     = 30
}

variable "crop_lambda_memory" {
  description = "Memoria en MB para la crop-lambda"
  type        = number
  default     = 512
}

variable "crop_lambda_timeout" {
  description = "Timeout en segundos para la crop-lambda"
  type        = number
  default     = 60
}

variable "sqs_batch_size" {
  description = "Cantidad de mensajes SQS que procesa la crop-lambda por invocación"
  type        = number
  default     = 5
}

# OBSERVABILITY 

variable "log_retention_days" {
  description = "Días de retención de logs en CloudWatch"
  type        = number
  default     = 14
}

variable "sns_alarm_email" {
  description = "Email que recibe alertas cuando la DLQ tiene mensajes"
  type        = string
}