variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "train_test_bucket"
}

variable "environment" {
  description = "The environment the bucket is used in [DEV, STAG, PROD]"
  validation {
    condition     = contains(["DEV", "STAG", "PROD"], var.environment)
    error_message = "Environment must be one of DEV, STAG, PROD"
  }
}

variable "application_name" {
  description = "Application name"
}