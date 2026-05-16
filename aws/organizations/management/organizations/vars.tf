locals {
  project_name         = "SET_YOUR_PROJECT_NAME"
  organization_name    = "management"
  account_name         = "organizations"
  account_region       = "us-east-1"
  organization_account = format("%s-%s", local.organization_name, local.account_name)
  account_id           = "SET_YOUR_MANAGEMENT_ACCOUNT_ID"
}
