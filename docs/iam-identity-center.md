# IAM Identity Center

## Overview

IAM Identity Center (formerly AWS SSO) provides centralized single sign-on across all accounts in the AWS Organization.

## Permission Sets

| Permission Set | Policies | Session Duration |
|---------------|----------|-----------------|
| **Administrator** | AdministratorAccess + AssumeRole | 4 hours |
| **Read-Only** | ViewOnlyAccess | 3 hours |
| **Engineers** | ViewOnlyAccess + development inline policy | 3 hours |
| **Security Engineers** | SecurityAudit + WAF + GuardDuty + Security Hub + Config + IAM read | 4 hours |

## Groups

| Group | Permission Sets | Accounts |
|-------|----------------|----------|
| **Administrators** | Administrator | All accounts |
| **Engineers** | Engineers | Production, Sandbox |
| **Security Engineers** | Security Engineers | All accounts |

## Adding SSO Users

Edit `aws/organizations/management/identity/main.tf`:

```hcl
locals {
  sso_users = {
    "new.user@mycompany.com" : {
      group_membership = ["engineers"]
      user_name        = "new.user@mycompany.com"
      given_name       = "New"
      family_name      = "User"
      email            = "new.user@mycompany.com"
    }
  }
}
```

## Adding Permission Sets

Add to the `permission_sets` map in the same file:

```hcl
devops-access = {
  description      = "DevOps team with EKS and CI/CD access"
  session_duration = "PT4H"
  aws_managed_policies = [
    "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
  ]
  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["eks:*", "codepipeline:*"]
        Resource = "*"
      }
    ]
  })
  tags = { ManagedBy = "Terraform" }
}
```

## Account Assignments

Map groups to permission sets and accounts in `account_assignments`:

```hcl
devops : {
  principal_name  = "devops"
  principal_type  = "GROUP"
  principal_idp   = "INTERNAL"
  permission_sets = ["devops-access"]
  account_ids = [
    nonsensitive(data.aws_ssm_parameter.account_id["shared-services"].value),
    nonsensitive(data.aws_ssm_parameter.account_id["production"].value),
  ]
}
```
