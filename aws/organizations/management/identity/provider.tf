provider "aws" {
  region  = local.account_region
  profile = "bootstrapper"

  assume_role {
    role_arn = format("arn:aws:iam::%s:role/OrganizationAccountAccessRole", data.aws_ssm_parameter.account_id["identity"].value)
  }
}

provider "aws" {
  region  = local.account_region
  alias   = "management"
  profile = "bootstrapper"
}
