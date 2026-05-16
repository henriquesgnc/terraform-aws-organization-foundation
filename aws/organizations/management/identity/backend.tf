terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 0.55"
    }
  }
}

terraform {
  backend "s3" {
    bucket         = "SET_YOUR_PROJECT_NAME-s3-tfstate"
    key            = "aws/organizations/security/identity/terraform.tfstate"
    region         = "us-east-1"
    profile        = "bootstrapper"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
