module "iam_management" {
  source = "../../../../modules/aws/organizations/cross-account-iam"
  providers = {
    aws = aws.management
  }
  account_id          = data.aws_ssm_parameter.account_id["management"].value
  github_organization = "SET_YOUR_GITHUB_ORG"
}

module "iam_identity" {
  source = "../../../../modules/aws/organizations/cross-account-iam"
  providers = {
    aws = aws.identity
  }
  account_id          = data.aws_ssm_parameter.account_id["identity"].value
  github_organization = "SET_YOUR_GITHUB_ORG"
}

module "iam_shared_services" {
  source = "../../../../modules/aws/organizations/cross-account-iam"
  providers = {
    aws = aws.shared-services
  }
  account_id          = data.aws_ssm_parameter.account_id["shared-services"].value
  github_organization = "SET_YOUR_GITHUB_ORG"
}

module "iam_production" {
  source = "../../../../modules/aws/organizations/cross-account-iam"
  providers = {
    aws = aws.production
  }
  account_id          = data.aws_ssm_parameter.account_id["production"].value
  github_organization = "SET_YOUR_GITHUB_ORG"
}

module "iam_sandbox" {
  source = "../../../../modules/aws/organizations/cross-account-iam"
  providers = {
    aws = aws.sandbox
  }
  account_id          = data.aws_ssm_parameter.account_id["sandbox"].value
  github_organization = "SET_YOUR_GITHUB_ORG"
}
