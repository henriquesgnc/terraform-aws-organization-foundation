output "root_id" {
  description = "Organization root ID"
  value       = aws_organizations_organization.this.roots[0].id
}

output "account_ids" {
  description = "Map of AWS Organization Account names to Account IDs"
  value       = { for k, v in aws_organizations_account.accounts : k => v.id }
}

output "account_emails" {
  description = "Map of AWS Organization Account names to emails"
  value       = { for k, v in aws_organizations_account.accounts : k => v.email }
}

output "account_names" {
  description = "Map of AWS Organization Account names to names"
  value       = { for k, v in aws_organizations_account.accounts : k => v.name }
}

output "organization_units" {
  description = "Map of OU names to OU IDs"
  value       = { for k, v in aws_organizations_organizational_unit.ou : k => v.id }
}
