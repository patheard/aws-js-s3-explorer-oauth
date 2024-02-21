#
# Cognito at edge
# https://github.com/awslabs/cognito-at-edge
#
data "archive_file" "cognito_at_edge" {
  type        = "zip"
  source_dir  = "${path.module}/cognito-at-edge"
  excludes    = ["${local_file.cognito_at_edge_index.filename}.tmpl"]
  output_path = "/tmp/cognito-at-edge.zip"
}

#
# A local file is used to generate the index.js because Lambda@Edge 
# does not support environment variables
#
resource "local_file" "cognito_at_edge_index" {
  content = sensitive(templatefile("${path.module}/cognito-at-edge/index.js.tmpl", {
    REGION                       = var.region
    COGNITO_USER_POOL_ID         = aws_cognito_user_pool.users.id
    COGNITO_USER_POOL_APP_ID     = aws_cognito_user_pool_client.cognito.id
    COGNITO_USER_POOL_APP_SECRET = aws_cognito_user_pool_client.cognito.client_secret
    COGNITO_USER_DOMAIN          = "${aws_cognito_user_pool_domain.users.domain}.auth.${var.region}.amazoncognito.com"
  }))
  filename = "${path.module}/cognito-at-edge/index.js"
}

resource "aws_lambda_function" "cognito_at_edge" {
  provider = aws.us-east-1

  function_name    = "cognito-at-edge"
  filename         = "/tmp/cognito-at-edge.zip"
  role             = aws_iam_role.cognito_at_edge.arn
  handler          = "index.handler"
  timeout          = 5
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.cognito_at_edge.output_base64sha256

  # CloudFront requires a qualified ARN
  publish = true

  tracing_config {
    mode = "PassThrough"
  }
}

resource "aws_iam_role" "cognito_at_edge" {
  name               = "cognito-at-edge"
  assume_role_policy = data.aws_iam_policy_document.cognito_at_edge.json
}

resource "aws_iam_policy" "cognito_at_edge" {
  name   = "cognito_at_edge"
  path   = "/"
  policy = data.aws_iam_policy_document.cognito_at_edge_cloudwatch.json
}

resource "aws_iam_role_policy_attachment" "cognito_at_edge" {
  role       = aws_iam_role.cognito_at_edge.name
  policy_arn = aws_iam_policy.cognito_at_edge.arn
}

data "aws_iam_policy_document" "cognito_at_edge" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = [
        "lambda.amazonaws.com", 
        "edgelambda.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "cognito_at_edge_cloudwatch" {
  statement {
    sid    = "CloudWatchAccess"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "*"
    ]
  }
}
