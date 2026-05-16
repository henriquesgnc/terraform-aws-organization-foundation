locals {
  project_name         = "SET_YOUR_PROJECT_NAME"
  organization_name    = "workloads"
  account_name         = "sandbox"
  account_region       = "us-east-1"
  organization_account = format("%s-%s", local.organization_name, local.account_name)
}
