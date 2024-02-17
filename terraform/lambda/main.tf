# Create an IAM policy document for the lambda
data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["*"]
  }

  statement {
    sid    = "CloudWatchAccess"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:${data.aws_region.current.name}:*:*"]
  }

  statement {
    sid = "S3Access"

    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }
}

# Create an IAM policy for the lambda
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "IAM policy for lambda"
  policy      = data.aws_iam_policy_document.lambda_policy.json
}

# Create an IAM role for the lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# Attach the policy to the lambda role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Get current AWS region
data "aws_region" "current" {}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

resource "null_resource" "package_lambda" {
  triggers = {
    files = "${filebase64sha256("${path.module}/../../Dockerfile")}"
    files = "${filebase64sha256("${path.module}/../../api/main.py")}"
    files = "${filebase64sha256("${path.module}/../../deploy.sh")}"
  }
  provisioner "local-exec" {
    command     = "chmod +x ${path.module}/../../deploy.sh; ${path.module}/../../deploy.sh"
    interpreter = ["bash", "-c"]
  }
}

data "external" "envs" {
  program = ["bash", "-c", <<-EOSCRIPT
    : "$${PROJECT_NAME:?Missing environment variable PROJECT_NAME}"
    jq --arg PROJECT_NAME "$(printenv PROJECT_NAME)" \
       --arg SHA "$(git rev-parse HEAD)" \
       -n '{ "project_name": $PROJECT_NAME, 
             "sha": $SHA}'
  EOSCRIPT
  ]
}

# Create a Lambda Function
resource "aws_lambda_function" "func" {
  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attachment,
    null_resource.package_lambda,
    data.external.envs
  ]
  role          = aws_iam_role.lambda_role.arn
  image_uri     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${data.external.envs.result.project_name}:${data.external.envs.result.sha}"
  function_name = var.lambda_function_name
  description   = "Model serving function for ${var.application_name}"
  memory_size   = var.memory_size
  timeout       = var.timeout
  package_type  = "Image"
  architectures = ["x86_64"]


  environment {
    variables = {
      BUCKET_NAME    = var.s3_bucket_id
      REGION         = data.aws_region.current.name
    }
  }

  tags = {
    Name        = var.lambda_function_name
    Environment = var.environment
    Application = var.application_name
  }
}

# Allow the Lambda function to be invoked by the S3 bucket
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.func.arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn
}

# Create an S3 bucket notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.s3_bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.func.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }
  depends_on = [aws_lambda_permission.allow_bucket]
}



