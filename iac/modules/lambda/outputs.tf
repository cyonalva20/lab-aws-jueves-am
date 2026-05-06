output "upload_lambda_arn" {
  description = "ARN de la upload-lambda — lo necesita API Gateway"
  value       = aws_lambda_function.upload.arn
}

output "upload_lambda_name" {
  description = "Nombre de la upload-lambda"
  value       = aws_lambda_function.upload.function_name
}

output "crop_lambda_arn" {
  description = "ARN de la crop-lambda"
  value       = aws_lambda_function.crop.arn
}

output "upload_lambda_log_group" {
  description = "Nombre del log group de la upload-lambda"
  value       = aws_cloudwatch_log_group.upload_lambda.name
}

output "crop_lambda_log_group" {
  description = "Nombre del log group de la crop-lambda"
  value       = aws_cloudwatch_log_group.crop_lambda.name
}