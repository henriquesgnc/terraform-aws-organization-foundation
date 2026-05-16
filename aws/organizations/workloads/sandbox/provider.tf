provider "aws" {
  region  = local.account_region
  profile = "bootstrapper"

  assume_role {
    role_arn = format("arn:aws:iam::%s:role/terraform", data.aws_ssm_parameter.account_id["sandbox"].value)
  }
}

provider "aws" {
  region  = local.account_region
  alias   = "management"
  profile = "bootstrapper"
}
