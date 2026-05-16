data "aws_ssm_parameter" "account_id" {
  provider = aws.management
  for_each = toset(["production"])
  name     = format("/organizations/accounts/%s", each.value)
}
