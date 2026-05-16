module "aws_organizations" {
  source = "../../../../modules/aws/organizations"

  root_account_id    = local.account_id
  organization_units = ["management", "security", "workloads"]

  accounts = [
    {
      name              = "identity"
      email             = "aws+security-identity@SET_YOUR_DOMAIN.com"
      organization_unit = "security"
    },
    {
      name              = "shared-services"
      email             = "aws+management-shared-services@SET_YOUR_DOMAIN.com"
      organization_unit = "management"
    },
    {
      name              = "production"
      email             = "aws+workloads-production@SET_YOUR_DOMAIN.com"
      organization_unit = "workloads"
    },
    {
      name              = "sandbox"
      email             = "aws+workloads-sandbox@SET_YOUR_DOMAIN.com"
      organization_unit = "workloads"
    },
  ]
}

resource "aws_organizations_delegated_administrator" "identity_sso" {
  account_id        = module.aws_organizations.account_ids["identity"]
  service_principal = "sso.amazonaws.com"
}

module "scp_policies" {
  source = "../../../../modules/aws/organizations/scp"

  root_id = module.aws_organizations.root_id
}
