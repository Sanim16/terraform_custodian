# S3 Bucket for storing Cloud Custodian policies
resource "aws_s3_bucket" "custodian_bucket" {
  bucket = "momoh-custodian-policies-bucket-123456"
  acl    = "private"
}

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

# create zip file from requirements.txt. Triggers only when the file is updated
resource "null_resource" "lambda_layer" {
  triggers = {
    requirements = filesha1(local.requirements_path)
  }
  # the command to install python and dependencies to the machine and zips
  provisioner "local-exec" {
    command = <<EOT
        echo "creating layers with requirements.txt packages..."

        cd ${path.module}
        # rm -rf ${var.dir_name}
        mkdir ${var.dir_name}

        # Create and activate virtual environment environment using python -m venv...
        ${var.runtime} -m venv env_${var.function_name}
        source ${path.cwd}/env_${var.function_name}/bin/activate

        # Installing python dependencies...
        if [ -f ${local.requirements_path} ]; then
            echo "From: requirement.txt file exists..."  

            pip install -r ${local.requirements_path} -t ${var.dir_name}/
            zip -r ${local.layer_zip_path} ${var.dir_name}/
         else
            echo "Error: requirement.txt does not exist!"
        fi

        # Deactivate virtual environment...
        deactivate

        #deleting the python dist package modules
        rm -rf ${var.dir_name}
        
    EOT
  }
  depends_on = [aws_s3_bucket.custodian_bucket] # triggered only if the s3 bucket is created
}

resource "aws_s3_object" "my_file_upload" {
  bucket = aws_s3_bucket.custodian_bucket.id
  key    = "lambda_layers/${local.layer_name}/${local.layer_zip_path}" # The key (path) within the S3 bucket
  source = "${path.module}/${local.layer_zip_path}"                    # The local path to the file you want to upload
  #   etag       = filemd5("${path.module}/${local.layer_zip_path}")           # Ensures Terraform detects content changes
  depends_on = [null_resource.lambda_layer] # triggered only if the zip file is created
}



################################################################################
# Lambda IAM role to assume the role
################################################################################
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "lambda.amazonaws.com"
      },
      "Action" : "sts:AssumeRole"
    }]
  })
}

################################################################################
# Assign policy to the role
################################################################################
resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "lambda_basic_execution"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "custodian_lambda_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


################################################################################
# Creating lambda layer for requests python library
################################################################################
resource "aws_lambda_layer_version" "custodian_layer" {
  s3_bucket = aws_s3_bucket.custodian_bucket.id
  s3_key    = aws_s3_object.my_file_upload.key
  #   filename            = "${path.module}/custodian_layer.zip"
  layer_name          = local.layer_name
  compatible_runtimes = ["${var.runtime}"]
  depends_on          = [aws_s3_object.my_file_upload] # triggered only if the zip file is uploaded to the bucket
  source_code_hash    = data.aws_s3_object.layer_object.checksum_sha256
  #   source_code_hash    = filebase64sha256("${path.module}/custodian_layer.zip")
  description = "Cloud Custodian (c7n) Lambda Layer"
}

data "aws_s3_object" "layer_object" {
  bucket = aws_s3_bucket.custodian_bucket.id
  key    = aws_s3_object.my_file_upload.key
}

################################################################################
# Compressing lambda_handler function code
################################################################################
data "archive_file" "lambda_function_archive" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda_function.zip"
}

################################################################################
# Creating Lambda Function
################################################################################
resource "aws_lambda_function" "custodian_lambda_function" {
  function_name = var.function_name
  filename      = "${path.module}/lambda_function.zip"

  runtime     = var.runtime
  handler     = "custodian.lambda_handler"
  layers      = [aws_lambda_layer_version.custodian_layer.arn]
  memory_size = 512
  timeout     = 300

  environment {}

  source_code_hash = data.archive_file.lambda_function_archive.output_base64sha256

  role = aws_iam_role.lambda_role.arn

  depends_on = [null_resource.lambda_layer]
}

# ################################################################################
# # Creating Lambda Function URL for accessing it via browser
# ################################################################################
# resource "aws_lambda_function_url" "custodian_function_url" {
#   function_name      = aws_lambda_function.custodian_lambda_function.function_name
#   authorization_type = "NONE" # Change to "AWS_IAM" for restricted access
# }


################################################################################
# Creating CloudWatch Log group for Lambda Function
################################################################################
resource "aws_cloudwatch_log_group" "custodian_lambda_function_cloudwatch" {
  name              = "/aws/lambda/${aws_lambda_function.custodian_lambda_function.function_name}"
  retention_in_days = 30
}

# EventBridge rule to run every 6 hours
resource "aws_cloudwatch_event_rule" "custodian_schedule" {
  name        = "custodian-schedule"
  description = "Trigger Cloud Custodian Lambda"
  #   schedule_expression = "rate(1 hour)"
  #   schedule_expression = "cron(0 1 * * ? *)"  # Runs daily at 01:00 UTC
  schedule_expression = "rate(10 minutes)" # You can adjust this to your needs
}

resource "aws_cloudwatch_event_target" "custodian_lambda_target" {
  rule      = aws_cloudwatch_event_rule.custodian_schedule.name
  target_id = "custodianLambda"
  arn       = aws_lambda_function.custodian_lambda_function.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.custodian_lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.custodian_schedule.arn
}