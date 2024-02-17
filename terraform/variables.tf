variable "name" {
  default     = "example-2024-02"
  description = "Application name"
}

variable "environment" {
  description = "The environment the bucket is used in [DEV, STAG, PROD]"
  default     = "DEV"
  validation {
    condition     = contains(["DEV", "STAG", "PROD"], var.environment)
    error_message = "Environment must be one of DEV, STAG, PROD"
  }
}