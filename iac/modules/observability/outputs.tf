output "sns_topic_arn" {
  description = "ARN del SNS topic de alertas"
  value       = aws_sns_topic.alerts.arn
}

output "dlq_alarm_name" {
  description = "Nombre de la alarma de la DLQ"
  value       = aws_cloudwatch_metric_alarm.dlq_messages.alarm_name
}

output "dashboard_name" {
  description = "Nombre del dashboard de CloudWatch"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}