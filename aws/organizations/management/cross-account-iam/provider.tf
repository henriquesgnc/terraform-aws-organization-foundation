provider "aws" {
  region  = local.account_region
  profile = "bootstrapper"

  assume_role {
    role_arn = format("arn:aws:iam::%s:role/OrganizationAccountAccessRole", data.aws_ssm_parameter.account_id["management"].value)
  }
}

provider "aws" {
  region  = local.account_region
  alias   = "management"
  profile = "bootstrapper"
}

provider "aws" {
  region  = local.account_region
  alias   = "identity"
  profile = "bootstrapper"

  assume_role {
    role_arn = format("arn:aws:iam::%s:role/OrganizationAccountAccessRole", data.aws_ssm_parameter.account_id["identity"].value)
  }
}

provider "aws" {
  region  = local.account_region
  alias   = "shared-services"
  profile = "bootstrapper"

  assume_role {
    role_arn = format("arn:aws:iam::%s:role/OrganizationAccountAccessRole", data.aws_ssm_parameter.account_id["shared-services"].value)
  }
}

provider "aws" {
  region  = local.account_region
  alias   = "production"
  profile = "bootstrapper"

  assume_role {
    role_arn = format("arn:aws:iam::%s:role/OrganizationAccountAccessRole", data.aws_ssm_parameter.account_id["production"].value)
  }
}

provider "aws" {
  region  = local.account_region
  alias   = "sandbox"
  profile = "bootstrapper"

  assume_role {
    role_arn = format("arn:aws:iam::%s:role/OrganizationAccountAccessRole", data.aws_ssm_parameter.account_id["sandbox"].value)
  }
}
