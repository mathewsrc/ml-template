# Get current AWS region
data "aws_region" "current" {}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

data "aws_ecr_authorization_token" "token" {}


# resource "null_resource" "package_lambda" {
#   triggers = {
#     dockerfilehash = "${filebase64sha256("${path.module}/../../Dockerfile")}"
#     apihash = "${filebase64sha256("${path.module}/../../api/main.py")}"
#     deployhash = "${filebase64sha256("${path.module}/../../deploy.sh")}"
#   }
#   provisioner "local-exec" {
#     command     = "chmod +x ${path.module}/../../deploy.sh; ${path.module}/../../deploy.sh"
#     interpreter = ["bash", "-c"]
#   }
# }

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

resource "aws_ecr_repository" "repository" {
  name                 = "lambda-${exeternal.envs.result.project_name}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  lifecycle {
    ignore_changes = all
  }

  # Ref: https://stackoverflow.com/questions/69907325/terraform-aws-lambda-function-requires-docker-image-in-ecr
  provisioner "local-exec" {
    #    This is a 1-time execution to put a dummy image into the ECR repo, so 
    #    terraform provisioning works on the lambda function. Otherwise there is
    #    a chicken-egg scenario where the lambda can't be provisioned because no
    #    image exists in the ECR
    command     = <<EOF
      docker login ${data.aws_ecr_authorization_token.token.proxy_endpoint} -u AWS -p ${data.aws_ecr_authorization_token.token.password}
      docker pull alpine
      docker tag alpine ${aws_ecr_repository.repository.repository_url}:${data.external.envs.result.sha}
      docker push ${aws_ecr_repository.repository.repository_url}:${data.external.envs.result.sha}
      EOF
  }
}

# Create a Lambda Function
resource "aws_lambda_function" "func" {
  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attachment,
    #null_resource.package_lambda,
    data.external.envs
  ]
  role          = aws_iam_role.lambda_role.arn
  image_uri     = "${aws_ecr_repository.image_storage.repository_url}:${data.external.envs.result.sha}"
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



