# # provider "aws" {
# #   region = "us-east-1"
# # }

# data "archive_file" "custodian_zip" {
#   type        = "zip"
#   source_dir  = "${path.module}/../lambda"
#   output_path = "${path.module}/../lambda/custodian.zip"
# }

# # resource "aws_lambda_function" "custodian" {
# #   filename      = data.archive_file.custodian_zip.output_path
# #   function_name = "custodian-policy-runner"
# #   role          = aws_iam_role.custodian_lambda_role.arn
# #   handler       = "handler.lambda_handler"
# #   runtime       = "python3.9"
# #   timeout       = 300
# #   memory_size   = 512

# #   environment {
# #     variables = {}
# #   }

# #   layers = []
# # }

# # # EventBridge rule to run every 6 hours
# # resource "aws_cloudwatch_event_rule" "custodian_schedule" {
# #   name                = "custodian-schedule"
# #   schedule_expression = "rate(1 hour)"
# # }

# # resource "aws_cloudwatch_event_target" "custodian_lambda_target" {
# #   rule      = aws_cloudwatch_event_rule.custodian_schedule.name
# #   target_id = "custodianLambda"
# #   arn       = aws_lambda_function.custodian.arn
# # }

# # resource "aws_lambda_permission" "allow_cloudwatch" {
# #   statement_id  = "AllowExecutionFromCloudWatch"
# #   action        = "lambda:InvokeFunction"
# #   function_name = aws_lambda_function.custodian.function_name
# #   principal     = "events.amazonaws.com"
# #   source_arn    = aws_cloudwatch_event_rule.custodian_schedule.arn
# # }

# provider "aws" {
#   region = "us-east-1" # Change to your preferred region
# }

# # S3 Bucket for storing Cloud Custodian policies
# resource "aws_s3_bucket" "custodian_bucket" {
#   bucket = "momoh-custodian-policies-bucket-123456"
#   acl    = "private"
# }

# resource "aws_s3_object" "my_file_upload" {
#   bucket = aws_s3_bucket.custodian_bucket.id
#   key    = "path/lambda_layer.zip"                    # The key (path) within the S3 bucket
#   source = "${path.module}/lambda_layer.zip"          # The local path to the file you want to upload
#   etag   = filemd5("${path.module}/lambda_layer.zip") # Ensures Terraform detects content changes
# }

# resource "aws_lambda_layer_version" "custodian_layer" {
#   layer_name = "custodian-layer"
#   s3_bucket  = aws_s3_bucket.custodian_bucket.id
#   s3_key     = aws_s3_object.my_file_upload.key

#   compatible_runtimes = ["python3.12"]

#   description = "Cloud Custodian (c7n) Lambda Layer"
# }

# # IAM Role for Cloud Custodian Lambda
# resource "aws_iam_role" "custodian_role" {
#   name = "custodian-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = {
#         Service = "lambda.amazonaws.com"
#       }
#     }]
#   })
# }

# # IAM Policy for Cloud Custodian Lambda to allow EC2 and S3 actions
# resource "aws_iam_policy" "custodian_policy" {
#   name        = "cloud-custodian-policy"
#   description = "Cloud Custodian Policy"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "ec2:DescribeInstances",
#           "ec2:StopInstances",
#           "ec2:StartInstances",
#           "ec2:TerminateInstances"
#         ]
#         Effect   = "Allow"
#         Resource = "*"
#       },
#       {
#         Action   = "s3:PutObject"
#         Effect   = "Allow"
#         Resource = "arn:aws:s3:::${aws_s3_bucket.custodian_bucket.bucket}/*"
#       }
#     ]
#   })
# }

# # Attach the IAM policy to the Lambda role
# resource "aws_iam_role_policy_attachment" "custodian_policy_attachment" {
#   role       = aws_iam_role.custodian_role.name
#   policy_arn = aws_iam_policy.custodian_policy.arn
# }

# resource "aws_iam_role_policy_attachment" "custodian_lambda_policy_attach" {
#   role       = aws_iam_role.custodian_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
# }

# # Lambda function for Cloud Custodian execution
# resource "aws_lambda_function" "custodian_lambda" {
#   function_name = "cloud-custodian-lambda"

#   # The Lambda function's deployment package (your code)
#   filename = data.archive_file.custodian_zip.output_path
#   # filename         = "path/to/your/lambda/code.zip"  # Replace with your Lambda code zip
#   # source_code_hash = filebase64sha256(data.archive_file.custodian_zip.output_path)


#   handler = "handler.lambda_handler"
#   # handler = "your_lambda_file.lambda_handler"  # Replace with your Lambda handler
#   runtime     = "python3.12"
#   timeout     = 300
#   memory_size = 512

#   role = aws_iam_role.custodian_role.arn

#   layers = [
#     aws_lambda_layer_version.custodian_layer.arn
#   ]

#   depends_on = [aws_s3_bucket.custodian_bucket, aws_s3_object.my_file_upload]
# }

# # CloudWatch Event Rule to trigger Cloud Custodian Lambda every hour
# resource "aws_cloudwatch_event_rule" "custodian_rule" {
#   name                = "cloud-custodian-rule"
#   description         = "Trigger Cloud Custodian Lambda"
#   schedule_expression = "rate(1 hour)" # You can adjust this to your needs

#   depends_on = [aws_s3_bucket.custodian_bucket, aws_s3_object.my_file_upload]
# }

# # CloudWatch Event Target to link the event rule to the Lambda function
# resource "aws_cloudwatch_event_target" "custodian_target" {
#   rule      = aws_cloudwatch_event_rule.custodian_rule.name
#   target_id = "custodian-lambda-target"
#   arn       = aws_lambda_function.custodian_lambda.arn

#   depends_on = [aws_s3_bucket.custodian_bucket, aws_s3_object.my_file_upload]
# }

# # Lambda Permission to allow CloudWatch Events to invoke the Lambda
# resource "aws_lambda_permission" "custodian_lambda_permission" {
#   statement_id  = "AllowCloudWatchInvoke"
#   action        = "lambda:InvokeFunction"
#   principal     = "events.amazonaws.com"
#   function_name = aws_lambda_function.custodian_lambda.function_name
#   source_arn    = aws_cloudwatch_event_rule.custodian_rule.arn

#   depends_on = [aws_s3_bucket.custodian_bucket, aws_s3_object.my_file_upload]
# }

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "momoh-custodian-policies-bucket-12345"
    key    = "custodian-lambda/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_iam_role" "custodian_lambda_role" {
  name = "custodian-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.custodian_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_layer_version" "custodian_layer" {
  layer_name = "custodian-layer"
  # s3_bucket  = aws_s3_bucket.custodian_bucket.id
  # s3_key     = aws_s3_object.my_file_upload.key

  compatible_runtimes = ["python3.9"]

  description = "Cloud Custodian (c7n) Lambda Layer"

  # Path to the zip file that contains the c7n package
  filename            = "build/custodian_lambda.zip"
  
  # This ensures the lambda layer is updated only if the zip file changes
  source_code_hash    = filebase64sha256("build/custodian_lambda.zip")
}

resource "aws_lambda_function" "custodian" {
  function_name = "custodian-policy-runner"
  role          = aws_iam_role.custodian_lambda_role.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.9"
  timeout       = 900  # Max allowed for Lambda

  # filename         = "build/custodian_lambda.zip"
  filename         = "${path.module}/build/custodian_lambda.zip"
  # source_code_hash = filebase64sha256("build/custodian_lambda.zip")
  source_code_hash = filebase64sha256("${path.module}/build/custodian_lambda.zip")

  # Include the layer containing the Cloud Custodian (c7n) dependency
  layers = [
    aws_lambda_layer_version.custodian_layer.arn
  ]
}

resource "aws_cloudwatch_event_rule" "custodian_schedule" {
  name                = "custodian-daily-rule"
  # schedule_expression = "cron(0 1 * * ? *)"  # Runs daily at 01:00 UTC
  schedule_expression = "rate(10 minutes)" # You can adjust this to your needs
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.custodian_schedule.name
  target_id = "CustodianLambda"
  arn       = aws_lambda_function.custodian.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.custodian.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.custodian_schedule.arn
}
