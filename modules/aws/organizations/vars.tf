variable "root_account_id" {
  description = "The AWS Root Account ID (management account)"
  type        = string
}

variable "organization_units" {
  description = "List of Organizational Units (OUs) names"
  type        = list(string)
}

variable "accounts" {
  description = "List of AWS accounts to create and manage in the organization"
  type = list(object({
    name              = string
    email             = string
    organization_unit = string
  }))
}
