# ################################################################################
# # Lambda IAM role to assume the role
# ################################################################################
# resource "aws_iam_role" "lambda_role" {
#   name = "lambda_execution_role"
#   assume_role_policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [{
#       "Effect" : "Allow",
#       "Principal" : {
#         "Service" : "lambda.amazonaws.com"
#       },
#       "Action" : "sts:AssumeRole"
#     }]
#   })
# }

# ################################################################################
# # Assign policy to the role
# ################################################################################
# resource "aws_iam_policy_attachment" "lambda_basic_execution" {
#   name       = "lambda_basic_execution"
#   roles      = [aws_iam_role.lambda_role.name]
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }
