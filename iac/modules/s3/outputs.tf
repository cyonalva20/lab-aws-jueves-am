output "bucket_name" {
  description = "Nombre del bucket S3"
  value       = aws_s3_bucket.images.id
}

output "bucket_arn" {
  description = "ARN del bucket S3 — lo necesita IAM para los permisos"
  value       = aws_s3_bucket.images.arn
}

output "upload_prefix" {
  description = "Prefijo para imágenes originales"
  value       = "uploads/"
}

output "processed_prefix" {
  description = "Prefijo para imágenes procesadas"
  value       = "processed/"
}