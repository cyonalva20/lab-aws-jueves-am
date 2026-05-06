locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# LOG GROUP API GATEWAY 

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${local.name_prefix}"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# HTTP API

resource "aws_apigatewayv2_api" "main" {
  name          = "${local.name_prefix}-api"
  protocol_type = "HTTP"
  description   = "API para subir imágenes - ${var.environment}"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
    max_age       = 300
  }

  tags = {
    Name        = "${local.name_prefix}-api"
    Environment = var.environment
    Project     = var.project_name
  }
}

# INTEGRACIÓN CON LAMBDA 

resource "aws_apigatewayv2_integration" "upload_lambda" {
  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "AWS_PROXY"
  integration_uri    = var.upload_lambda_arn
  integration_method = "POST"

  payload_format_version = "2.0"
}

# RUTA POST /upload 

resource "aws_apigatewayv2_route" "upload" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /upload"
  target    = "integrations/${aws_apigatewayv2_integration.upload_lambda.id}"
}

# STAGE 

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
      errorMessage   = "$context.error.message"
    })
  }

  default_route_settings {
    # Throttling — máximo 10,000 requests por segundo según el diagrama
    throttling_burst_limit = 10000
    throttling_rate_limit  = 10000
  }

  tags = {
    Name        = "${local.name_prefix}-api-stage"
    Environment = var.environment
  }

  depends_on = [aws_cloudwatch_log_group.api_gateway]
}

# PERMISO PARA INVOCAR LAMBDA 

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.upload_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}