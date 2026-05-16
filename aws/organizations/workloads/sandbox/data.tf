data "aws_ssm_parameter" "account_id" {
  provider = aws.management
  for_each = toset(["sandbox"])
  name     = format("/organizations/accounts/%s", each.value)
}
