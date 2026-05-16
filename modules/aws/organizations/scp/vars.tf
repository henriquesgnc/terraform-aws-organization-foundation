variable "root_id" {
  description = "The root organization ID to attach SCPs to (from organizations module output)"
  type        = string
}

variable "enable_s3_public_block" {
  description = "Enable SCP to deny public S3 buckets"
  type        = bool
  default     = true
}

variable "enable_lambda_vpc" {
  description = "Enable SCP to require Lambda in VPC"
  type        = bool
  default     = false
}
