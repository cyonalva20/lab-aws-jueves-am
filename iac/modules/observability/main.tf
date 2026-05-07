locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# SNS TOPIC 

resource "aws_sns_topic" "alerts" {
  name = "${local.name_prefix}-alerts"

  tags = {
    Name        = "${local.name_prefix}-alerts"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.sns_alarm_email
}

# ALARMA DLQ

resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  alarm_name          = "${local.name_prefix}-dlq-messages-alarm"
  alarm_description   = "Hay mensajes en la DLQ — revisar errores en crop-lambda"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Sum"
  threshold           = 0

  dimensions = {
    QueueName = var.dlq_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions = [aws_sns_topic.alerts.arn]

  treat_missing_data = "notBreaching"

  tags = {
    Name        = "${local.name_prefix}-dlq-alarm"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ALARMA ERRORES UPLOAD LAMBDA 

resource "aws_cloudwatch_metric_alarm" "upload_errors" {
  alarm_name          = "${local.name_prefix}-upload-errors-alarm"
  alarm_description   = "La upload-lambda está lanzando errores"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 0

  dimensions = {
    FunctionName = var.upload_lambda_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  treat_missing_data = "notBreaching"

  tags = {
    Name        = "${local.name_prefix}-upload-errors-alarm"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ALARMA ERRORES CROP LAMBDA 

resource "aws_cloudwatch_metric_alarm" "crop_errors" {
  alarm_name          = "${local.name_prefix}-crop-errors-alarm"
  alarm_description   = "La crop-lambda está lanzando errores"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 0

  dimensions = {
    FunctionName = var.crop_lambda_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  treat_missing_data = "notBreaching"

  tags = {
    Name        = "${local.name_prefix}-crop-errors-alarm"
    Environment = var.environment
    Project     = var.project_name
  }
}

# DASHBOARD 

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${local.name_prefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Upload Lambda — Invocaciones y Errores"
          region = "us-east-1"
          period = 60
          stat   = "Sum"
          view   = "timeSeries"
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", var.upload_lambda_name],
            ["AWS/Lambda", "Errors", "FunctionName", var.upload_lambda_name]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Crop Lambda — Invocaciones y Errores"
          region = "us-east-1"
          period = 60
          stat   = "Sum"
          view   = "timeSeries"
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", var.crop_lambda_name],
            ["AWS/Lambda", "Errors", "FunctionName", var.crop_lambda_name]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "DLQ — Mensajes visibles"
          region = "us-east-1"
          period = 60
          stat   = "Sum"
          view   = "timeSeries"
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", var.dlq_name]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "API Gateway — Latencia"
          region = "us-east-1"
          period = 60
          stat   = "Average"
          view   = "timeSeries"
          metrics = [
            ["AWS/ApiGateway", "Latency", "ApiId", var.api_id],
            ["AWS/ApiGateway", "IntegrationLatency", "ApiId", var.api_id]
          ]
        }
      }
    ]
  })
}