#define variables
locals {
  layer_zip_path    = "custodian_layer.zip"
  layer_name        = "custodian_lambda_layer"
  requirements_path = "${path.module}/lambda/requirements.txt"
}

variable "dir_name" {
  description = "The name of the vpc"
  default     = "python"
}

variable "runtime" {
  type    = string
  default = "python3.12"
}

variable "function_name" {
  type    = string
  default = "Custodian_Lambda"
}


################################################################################
# Creating CloudWatch Log group for Lambda Function
################################################################################
resource "aws_cloudwatch_log_group" "custodian_lambda_function_cloudwatch" {
  name              = "/aws/lambda/${aws_lambda_function.custodian_lambda_function.function_name}"
  retention_in_days = 30
}

resource "aws_scheduler_schedule" "custodian_schedule" {
  name                         = "custodian-rule"
  schedule_expression_timezone = "GMT"
  schedule_expression          = "cron(05 07,08,19,20 ? * MON-SUN *)"
  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn      = aws_lambda_function.custodian_lambda_function.arn
    role_arn = aws_iam_role.scheduler_role.arn
  }
}
