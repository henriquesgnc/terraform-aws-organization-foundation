resource "aws_organizations_policy_attachment" "deny_leaving" {
  policy_id = aws_organizations_policy.deny_leaving_organization.id
  target_id = var.root_id
}

resource "aws_organizations_policy_attachment" "deny_root" {
  policy_id = aws_organizations_policy.deny_root_user.id
  target_id = var.root_id
}

resource "aws_organizations_policy_attachment" "cloudtrail" {
  policy_id = aws_organizations_policy.deny_cloudtrail_disable.id
  target_id = var.root_id
}

resource "aws_organizations_policy_attachment" "config" {
  policy_id = aws_organizations_policy.deny_disable_config.id
  target_id = var.root_id
}

resource "aws_organizations_policy_attachment" "guardduty" {
  policy_id = aws_organizations_policy.deny_disable_guardduty.id
  target_id = var.root_id
}

resource "aws_organizations_policy_attachment" "s3_public_block" {
  count = var.enable_s3_public_block ? 1 : 0

  policy_id = aws_organizations_policy.deny_public_s3.id
  target_id = var.root_id
}

resource "aws_organizations_policy_attachment" "lambda_vpc" {
  count = var.enable_lambda_vpc ? 1 : 0

  policy_id = aws_organizations_policy.require_vpc_lambda.id
  target_id = var.root_id
}
