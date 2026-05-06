output "queue_arn" {
  description = "ARN de la cola principal — lo necesita S3 para notificaciones y Lambda para el trigger"
  value       = aws_sqs_queue.main.arn
}

output "queue_url" {
  description = "URL de la cola principal — lo necesita la crop-lambda para hacer DeleteMessage"
  value       = aws_sqs_queue.main.id
}

output "dlq_arn" {
  description = "ARN de la DLQ — lo necesita CloudWatch para la alarma"
  value       = aws_sqs_queue.dlq.arn
}

output "dlq_name" {
  description = "Nombre de la DLQ — lo necesita CloudWatch para la métrica"
  value       = aws_sqs_queue.dlq.name
}