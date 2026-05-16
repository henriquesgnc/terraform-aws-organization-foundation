# Apply Order

Terraform stacks must be applied in a specific order due to cross-account dependencies:

## Dependency Graph

```
organizations ──► identity
       │
       └───────► cross-account-iam ──► shared-services
                                     ├── production
                                     └── sandbox
```

## Detailed Order

| # | Stack | What it creates | Dependencies |
|---|-------|----------------|--------------|
| 1 | `organizations` | AWS Organization, OUs, member accounts, SCPs | None |
| 2 | `identity` | IAM Identity Center (SSO), permission sets, group assignments | Account IDs from `organizations` |
| 3 | `cross-account-iam` | `terraform` execution role + GitHub OIDC per account | Account IDs from `organizations` |
| 4 | `shared-services` | Core VPC + networking in shared-services account | `terraform` role from `cross-account-iam` |
| 5 | `production` | Production VPC + resources | `terraform` role from `cross-account-iam` |
| 6 | `sandbox` | Sandbox VPC + resources | `terraform` role from `cross-account-iam` |

## Why this order?

1. **organizations must come first**: creates accounts that all other stacks depend on
2. **identity before cross-account-iam**: SSO setup is independent but needs account IDs
3. **cross-account-iam before networking stacks**: creates the `terraform` role needed to assume into member accounts
4. **shared-services, production, sandbox**: can be applied in any order once `cross-account-iam` is done (they are independent of each other)

## First Apply Note

The first apply of each stack MUST be done locally because the `terraform` role doesn't exist yet in member accounts. After `cross-account-iam` creates the role in all accounts, CI can apply everything.
