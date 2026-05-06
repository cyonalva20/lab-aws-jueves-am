output "api_endpoint" {
  description = "URL del endpoint para subir imágenes"
  value       = "${module.api_gateway.api_endpoint}/upload"
}

output "bucket_name" {
  description = "Nombre del bucket S3"
  value       = module.s3.bucket_name
}

output "upload_lambda_name" {
  description = "Nombre de la upload-lambda"
  value       = module.lambda.upload_lambda_name
}

output "crop_lambda_name" {
  description = "Nombre de la crop-lambda"
  value       = module.lambda.crop_lambda_name
}

output "sqs_queue_url" {
  description = "URL de la cola SQS principal"
  value       = module.sqs.queue_url
}

output "dlq_arn" {
  description = "ARN de la DLQ"
  value       = module.sqs.dlq_arn
}

output "cloudwatch_dashboard" {
  description = "Nombre del dashboard de CloudWatch"
  value       = module.observability.dashboard_name
}

output "environment" {
  description = "Entorno desplegado"
  value       = var.environment
}