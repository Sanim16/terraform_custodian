# resource "aws_iam_role" "custodian_lambda_role" {
#   name = "custodian-lambda-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action    = "sts:AssumeRole",
#         Principal = { Service = "lambda.amazonaws.com" },
#         Effect    = "Allow"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "custodian_lambda_policy_attach" {
#   role       = aws_iam_role.custodian_lambda_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
# }
