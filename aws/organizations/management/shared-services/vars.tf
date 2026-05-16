locals {
  project_name         = "SET_YOUR_PROJECT_NAME"
  organization_name    = "management"
  account_name         = "shared-services"
  account_region       = "us-east-1"
  organization_account = format("%s-%s", local.organization_name, local.account_name)
}
