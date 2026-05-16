locals {
  sso_users = {
    "YOUR_EMAIL@example.com" : {
      group_membership = ["administrators"]
      user_name        = "YOUR_EMAIL@example.com"
      given_name       = "YourFirstName"
      family_name      = "YourLastName"
      email            = "YOUR_EMAIL@example.com"
    }
  }
}

module "iam_identity_center" {
  providers = {
    aws = aws.management
  }
  source  = "aws-ia/iam-identity-center/aws"
  version = "~> 1.0"

  sso_groups = {
    administrators : {
      group_name        = "administrators"
      group_description = "Administrators with full AWS access"
    }
    engineers : {
      group_name        = "engineers"
      group_description = "Engineers with read access and development permissions"
    }
    security-engineers : {
      group_name        = "security-engineers"
      group_description = "Security Engineers with audit and security tool access"
    }
  }

  sso_users = local.sso_users

  permission_sets = {
    administrator = {
      description      = "Provides AWS full access permissions"
      session_duration = "PT4H"
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/AdministratorAccess"
      ]
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = "sts:AssumeRole"
            Resource = [
              for id in [for k, v in data.aws_ssm_parameter.account_id : nonsensitive(v.value)] :
              "arn:aws:iam::${id}:role/terraform"
            ]
          },
          {
            Sid    = "BillingFullAccess"
            Effect = "Allow"
            Action = [
              "aws-portal:*",
              "budgets:*",
              "billing:*",
              "account:*",
              "ce:*",
              "cur:*",
              "freetier:*",
              "invoicing:*",
              "payments:*",
              "tax:*",
              "consolidatedbilling:*"
            ]
            Resource = "*"
          }
        ]
      })
      tags = { ManagedBy = "Terraform" }
    }
    read-only = {
      description      = "Provides AWS view only permissions"
      session_duration = "PT3H"
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
      ]
      tags = { ManagedBy = "Terraform" }
    }
    engineers = {
      description      = "Engineers with read access and common development permissions"
      session_duration = "PT3H"
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
      ]
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid      = "SecretsManagerFullAccess"
            Effect   = "Allow"
            Action   = "secretsmanager:*"
            Resource = "*"
          },
          {
            Sid    = "DevelopmentAccess"
            Effect = "Allow"
            Action = [
              "rds:*",
              "s3:*",
              "cloudwatch:*",
              "logs:*",
              "dynamodb:*",
              "sqs:*",
              "events:*"
            ]
            Resource = "*"
          }
        ]
      })
      tags = { ManagedBy = "Terraform" }
    }
    security-engineers = {
      description      = "Security Engineers with access to audit and security tools"
      session_duration = "PT4H"
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/SecurityAudit",
        "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess",
        "arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess"
      ]
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = "WAFFullAccess"
            Effect = "Allow"
            Action = [
              "wafv2:*",
              "waf:*",
              "waf-regional:*"
            ]
            Resource = "*"
          },
          {
            Sid    = "SecurityToolsAccess"
            Effect = "Allow"
            Action = [
              "guardduty:*",
              "securityhub:*",
              "inspector2:*",
              "access-analyzer:*",
              "config:*",
              "cloudtrail:LookupEvents",
              "cloudtrail:GetTrail",
              "cloudtrail:GetEventSelectors",
              "cloudtrail:DescribeTrails",
              "cloudtrail:ListTrails",
              "macie2:*"
            ]
            Resource = "*"
          },
          {
            Sid    = "AuditAccess"
            Effect = "Allow"
            Action = [
              "iam:Get*",
              "iam:List*",
              "iam:Generate*",
              "organizations:Describe*",
              "organizations:List*",
              "account:Get*",
              "account:List*"
            ]
            Resource = "*"
          }
        ]
      })
      tags = { ManagedBy = "Terraform" }
    }
  }

  account_assignments = {
    administrators : {
      principal_name  = "administrators"
      principal_type  = "GROUP"
      principal_idp   = "INTERNAL"
      permission_sets = ["administrator"]
      account_ids = [
        for id in [for k, v in data.aws_ssm_parameter.account_id : nonsensitive(v.value)] : id
      ]
    }
    engineers : {
      principal_name  = "engineers"
      principal_type  = "GROUP"
      principal_idp   = "INTERNAL"
      permission_sets = ["engineers"]
      account_ids = [
        nonsensitive(data.aws_ssm_parameter.account_id["sandbox"].value),
        nonsensitive(data.aws_ssm_parameter.account_id["production"].value),
      ]
    }
    security-engineers : {
      principal_name  = "security-engineers"
      principal_type  = "GROUP"
      principal_idp   = "INTERNAL"
      permission_sets = ["security-engineers"]
      account_ids = [
        for id in [for k, v in data.aws_ssm_parameter.account_id : nonsensitive(v.value)] : id
      ]
    }
  }
}
