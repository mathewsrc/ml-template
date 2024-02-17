
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

# Create an S3 bucket
resource "aws_s3_bucket" "bucket" {
  depends_on = [ data.external.envs ]
  bucket        = "${data.external.envs.result.project_name}"
  force_destroy = true

  tags = {
    Name        = "${var.bucket_name} Bucket"
    Environment = var.environment
    Application = var.application_name
  }
}


# Create an S3 bucket object for each PDF file in the documents directory
resource "aws_s3_object" "object" {
  # Recursively look for pdf files inside documents/ 
  bucket   = aws_s3_bucket.bucket.id
  for_each = fileset("../data/", "**/*.csv")
  key      = each.value
  source   = "../data/${each.value}"
  etag     = filemd5("../data/${each.value}")

  tags = {
    Name        = "${var.bucket_name} Bucket"
    Environment = var.environment
    Application = var.application_name
  }

  depends_on = [
    aws_s3_bucket.bucket,
  ]
}