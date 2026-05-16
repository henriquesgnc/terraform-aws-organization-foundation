locals {
  resource_type = "vpc"
  resource_name = var.identifier != null ? format("%s-%s-%s", var.organization_account_name, var.identifier, local.resource_type) : format("%s-%s", var.organization_account_name, local.resource_type)
}

variable "identifier" {
  description = "Optional identifier suffix for the VPC name"
  type        = string
  default     = null
}

variable "organization_account_name" {
  description = "Organization-account name for naming convention (e.g. 'management-shared-services')"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "destination_logs_arn" {
  description = "ARN for CloudWatch Logs destination (optional)"
  type        = string
  default     = null
}

variable "cluster_name" {
  description = "Cluster name for EKS-related tags"
  type        = string
  default     = "cluster"
}

variable "tags" {
  description = "Tags to apply to VPC resources"
  type        = map(string)
  default     = {}
}

variable "enable_s3_endpoint" {
  description = "Enable VPC Endpoint for S3 (Gateway, free)"
  type        = bool
  default     = true
}

variable "enable_dynamodb_endpoint" {
  description = "Enable VPC Endpoint for DynamoDB (Gateway, free)"
  type        = bool
  default     = false
}

variable "enable_ecr_endpoints" {
  description = "Enable VPC Endpoints for ECR (Interface, ~$7/month per endpoint)"
  type        = bool
  default     = false
}

variable "enable_logs_endpoint" {
  description = "Enable VPC Endpoint for CloudWatch Logs (Interface, ~$7/month)"
  type        = bool
  default     = false
}

variable "enable_eks_endpoint" {
  description = "Enable VPC Endpoint for EKS (Interface, ~$7/month)"
  type        = bool
  default     = false
}

variable "enable_sts_endpoint" {
  description = "Enable VPC Endpoint for STS (Interface, ~$7/month)"
  type        = bool
  default     = false
}

variable "enable_execute_api_endpoint" {
  description = "Enable VPC Endpoint for API Gateway execute-api (Interface, ~$7/month)"
  type        = bool
  default     = false
}

variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway (~$36/month)"
  type        = bool
  default     = false
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways. 1 = single AZ (~$36/m), 3 = multi-AZ HA (~$108/m). Set to 0 to disable all NAT GWs."
  type        = number
  default     = 1
}

variable "flow_log_retention_in_days" {
  description = "Retention in days for VPC Flow Logs"
  type        = number
  default     = 30
}
