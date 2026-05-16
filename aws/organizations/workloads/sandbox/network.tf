module "vpc" {
  source                    = "../../../../modules/aws/vpc"
  organization_account_name = local.organization_account
  cidr_block                = "10.2.0.0/16"
  cluster_name              = local.organization_account

  enable_sts_endpoint         = true
  enable_ecr_endpoints        = true
  enable_logs_endpoint        = true
  enable_execute_api_endpoint = true
  nat_gateway_count           = 1
}
