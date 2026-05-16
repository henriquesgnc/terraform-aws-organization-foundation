resource "aws_organizations_organization" "this" {
  feature_set = "ALL"

  aws_service_access_principals = [
    "access-analyzer.amazonaws.com",
    "account.amazonaws.com",
    "aws-artifact-account-sync.amazonaws.com",
    "backup.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "compute-optimizer.amazonaws.com",
    "config.amazonaws.com",
    "ds.amazonaws.com",
    "fms.amazonaws.com",
    "iam.amazonaws.com",
    "license-manager.amazonaws.com",
    "member.org.stacksets.cloudformation.amazonaws.com",
    "ram.amazonaws.com",
    "servicecatalog.amazonaws.com",
    "ssm.amazonaws.com",
    "sso.amazonaws.com",
    "tagpolicies.tag.amazonaws.com",
  ]

  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
  ]
}

resource "aws_organizations_organizational_unit" "ou" {
  for_each  = { for ou in var.organization_units : ou => ou }
  name      = each.value
  parent_id = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_account" "accounts" {
  for_each = { for acc in var.accounts : acc.name => acc }

  name      = each.value.name
  email     = each.value.email
  role_name = "OrganizationAccountAccessRole"
  parent_id = aws_organizations_organizational_unit.ou[each.value.organization_unit].id

  lifecycle {
    ignore_changes = [role_name]
  }
}

resource "aws_ssm_parameter" "organization_units" {
  for_each = { for ou in var.organization_units : ou => ou }
  name     = format("/organizations/units/%s", each.value)
  type     = "String"
  value    = aws_organizations_organizational_unit.ou[each.value].id
}

resource "aws_ssm_parameter" "accounts" {
  for_each = { for acc in var.accounts : acc.name => acc }
  name     = format("/organizations/accounts/%s", each.key)
  type     = "String"
  value    = aws_organizations_account.accounts[each.key].id
}

resource "aws_iam_policy" "grant_access_to_member_accounts" {
  name        = "GrantAccessToOrganizationAccountAccessRole"
  description = "Allows access to OrganizationAccountAccessRole in member accounts"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sts:AssumeRole",
        Resource = [for account in aws_organizations_account.accounts : "arn:aws:iam::${account.id}:role/OrganizationAccountAccessRole"]
      }
    ]
  })
}

resource "aws_iam_group" "bootstrapper" {
  name = "bootstrapper"
}

resource "aws_iam_group_policy_attachment" "attach_policy_to_group" {
  group      = aws_iam_group.bootstrapper.name
  policy_arn = aws_iam_policy.grant_access_to_member_accounts.arn
}
