output "api_endpoint" {
  description = "URL del API Gateway — este es el endpoint que usa el cliente"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "api_id" {
  description = "ID del API Gateway"
  value       = aws_apigatewayv2_api.main.id
}

output "api_log_group" {
  description = "Nombre del log group del API Gateway"
  value       = aws_cloudwatch_log_group.api_gateway.name
}