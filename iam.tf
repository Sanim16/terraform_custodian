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

resource "aws_iam_policy" "policy" {
  name        = "lambda_policy"
  path        = "/"
  description = "Lambda policy"


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "ec2:StopInstances",
          "ec2:StartInstances",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:SuspendProcesses",
          "autoscaling:ResumeProcesses"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

data "aws_iam_policy_document" "cloud_custodian" {
  statement {
    sid    = "CloudCustodianRDSOffhours"
    effect = "Allow"
    actions = [
      "rds:DescribeDBInstances",
      "rds:StopDBInstance",
      "rds:StartDBInstance",
      "rds:ListTagsForResource",
      "rds:AddTagsToResource",
      "rds:RemoveTagsFromResource",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CloudCustodianLambdaPermissions"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/custodian-*:*"
    ]
  }

  statement {
    sid    = "CloudCustodianS3Permissions"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = [
      "arn:aws:s3:::*custodian*/*"
    ]
  }
}

resource "aws_iam_policy" "cloud_custodian" {
  name   = "cloud-custodian-policy"
  policy = data.aws_iam_policy_document.cloud_custodian.json
}

################################################################################
# Assign policy to the role
################################################################################
resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "lambda_basic_execution"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# resource "aws_iam_role_policy_attachment" "custodian_lambda_policy_attach" {
#   role       = aws_iam_role.lambda_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
# }

resource "aws_iam_role_policy_attachment" "custodian_lambda_policy_attach1" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_role_policy_attachment" "custodian_lambda_policy_attach2" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.cloud_custodian.arn
}

################################################################################
# Scheduler IAM role to assume the role
################################################################################
resource "aws_iam_role" "scheduler_role" {
  name = "custodian-scheduler-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "scheduler.amazonaws.com"
      },
      "Action" : "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "custodian_scheduler_policy" {
  name        = "scheduler_policy"
  description = "Scheduler policy"


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

################################################################################
# Assign policy to the role
################################################################################
resource "aws_iam_role_policy_attachment" "custodian_scheduler_policy" {
  role       = aws_iam_role.scheduler_role.name
  policy_arn = aws_iam_policy.custodian_scheduler_policy.arn
}
