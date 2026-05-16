locals {
  accounts = ["management", "identity", "shared-services", "production", "sandbox"]
}

data "aws_ssm_parameter" "account_id" {
  provider = aws.management
  for_each = toset(local.accounts)
  name     = format("/organizations/accounts/%s", each.value)
}
