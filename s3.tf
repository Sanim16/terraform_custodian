# S3 Bucket for storing Cloud Custodian policies
resource "aws_s3_bucket" "custodian_bucket" {
  bucket = "custodian-policies-bucket-123456"
}

resource "aws_s3_object" "my_file_upload" {
  bucket = aws_s3_bucket.custodian_bucket.id
  key    = "lambda_layers/${local.layer_name}/${local.layer_zip_path}"
  source = "${path.module}/${local.layer_zip_path}"
  # source_hash = filemd5("${path.module}/${local.layer_zip_path}")
  depends_on = [null_resource.lambda_layer]
}

# Upload the Cloud Custodian policy YAML file(s) to S3
resource "aws_s3_object" "custodian_policy" {
  bucket     = aws_s3_bucket.custodian_bucket.id
  key        = "policies/custodian-policy.yml"
  source     = "${path.module}/policies/custodian-policy.yml"
  etag       = filemd5("${path.module}/policies/custodian-policy.yml")
  depends_on = [aws_s3_bucket.custodian_bucket]
}
