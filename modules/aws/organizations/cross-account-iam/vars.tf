variable "account_id" {
  description = "The AWS Account ID where the terraform role will be created"
  type        = string
}

variable "github_organization" {
  description = "GitHub organization name for OIDC subject condition (e.g. 'my-org')"
  type        = string
}

variable "github_repos" {
  description = "GitHub repos allowed to assume this role via OIDC. Use [\"*\"] to allow all repos in the org. Use [\"repo-a\", \"repo-b\"] to restrict."
  type        = list(string)
  default     = ["*"]
}

variable "github_oidc_thumbprint" {
  description = "GitHub OIDC provider TLS certificate thumbprint. GitHub rotates their certificate periodically. Update this if OIDC auth breaks. Obtain current value: openssl s_client -servername token.actions.githubusercontent.com -connect token.actions.githubusercontent.com:443 2>/dev/null | openssl x509 -fingerprint -sha1 -noout | cut -d= -f2 | tr -d : | tr '[:upper:]' '[:lower:]'"
  type        = string
  default     = "6938fd4d98bab03faadb97b34396831e3780aea1"
}

variable "terraform_role_managed_policy_arns" {
  description = "AWS managed policy ARNs to attach to the terraform execution role. Default is AdministratorAccess. For production, prefer scoping to actual needed services."
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds for the terraform role"
  type        = number
  default     = 3600
}
