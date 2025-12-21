################################################################################
# Creating lambda layer for requests python library
################################################################################
resource "aws_lambda_layer_version" "custodian_layer" {
  s3_bucket           = aws_s3_bucket.custodian_bucket.id
  s3_key              = aws_s3_object.my_file_upload.key
  layer_name          = local.layer_name
  compatible_runtimes = ["${var.runtime}"]
  depends_on          = [aws_s3_object.my_file_upload]
  source_code_hash    = data.aws_s3_object.layer_object.checksum_sha256
  description         = "Cloud Custodian (c7n) Lambda Layer"
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
  runtime       = var.runtime
  handler       = "custodian.lambda_handler"
  layers        = [aws_lambda_layer_version.custodian_layer.arn]
  memory_size   = 512
  timeout       = 300

  role = aws_iam_role.lambda_role.arn

  source_code_hash = data.archive_file.lambda_function_archive.output_base64sha256

  environment {
    variables = {
      POLICY_S3_BUCKET = aws_s3_bucket.custodian_bucket.bucket
      POLICY_S3_KEY    = aws_s3_object.custodian_policy.key
    }
  }

  depends_on = [null_resource.lambda_layer, aws_s3_object.custodian_policy]
}
