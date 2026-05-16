# Terraform AWS Organization Foundation

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/terraform-%3E%3D1.5.0-623CE4?logo=terraform)](https://registry.terraform.io/providers/hashicorp/aws/latest)
[![AWS Provider](https://img.shields.io/badge/aws-%3E%3D5.0-FF9900?logo=amazonaws)](https://registry.terraform.io/providers/hashicorp/aws/latest)

A production-ready **Terraform blueprint** for building a secure AWS Organization foundation.

This repository helps platform engineering, DevOps, and cloud security teams bootstrap a multi-account AWS landing zone with Organizational Units, member accounts, SCP guardrails, IAM Identity Center, GitHub OIDC, Terraform remote state, and baseline networking.

## Who is this for?

This project is designed for:

- **Platform engineering teams** building an AWS multi-account foundation
- **Startups** creating their first production-ready AWS landing zone
- **DevOps teams** standardizing AWS account governance
- **Security teams** implementing baseline SCP guardrails
- **Engineers** looking for a practical Terraform AWS Organizations blueprint

## What this project is not

This is **not** a full AWS Control Tower replacement, but a lightweight and transparent Terraform-based foundation for teams that want direct control over their AWS Organization structure, accounts, SCPs, IAM Identity Center, and networking baseline.

## Architecture

```
Root Organization
├── Management OU
│   ├── Management Account  (billing, root, organizations)
│   └── Shared Services     (VPC, CI/CD, VPN, monitoring)
├── Security OU
│   └── Identity            (IAM Identity Center / SSO)
└── Workloads OU
    ├── Production
    └── Sandbox
```

## Key Features

| Feature | Description |
|---------|-------------|
| **AWS Organizations** | Multi-account structure with Organizational Units |
| **SSM Parameter Store** | Cross-account references via `/organizations/accounts/<name>` |
| **IAM Identity Center** | Centralized SSO with permission sets and group assignments |
| **SCP Guardrails** | Deny leaving org, deny root user, protect CloudTrail/Config/GuardDuty, block public S3 |
| **GitHub OIDC** | Federated CI/CD access without long-lived credentials |
| **Terraform Roles** | Cross-account execution role (`terraform`) per account |
| **VPC Module** | Public/private subnets, NAT Gateway, VPC Endpoints, Flow Logs |
| **Remote State** | S3 backend with DynamoDB state locking |

## Repository Structure

```
terraform-aws-organization-foundation/
├── bootstrap/                          # Manual bootstrap guide
│   └── README.md
├── config/
│   └── foundation.example.tfvars       # Configuration template
├── docs/                               # Detailed documentation
│   ├── architecture.md
│   ├── bootstrap.md
│   ├── apply-order.md
│   ├── github-oidc.md
│   ├── iam-identity-center.md
│   ├── scp-guardrails.md
│   └── networking.md
├── examples/                           # Usage scenarios
│   ├── startup-basic/
│   ├── platform-team/
│   ├── security-first/
│   └── enterprise-multi-account/
├── modules/                            # Reusable Terraform modules
│   └── aws/
│       ├── organizations/              # Organization, OU, and account management
│       │   ├── cross-account-iam/      # Terraform role + GitHub OIDC per account
│       │   └── scp/                    # Service Control Policy templates
│       └── vpc/                        # VPC with subnets, endpoints, flow logs
├── aws/
│   └── organizations/
│       ├── management/
│       │   ├── organizations/          # Root org: create OUs + accounts
│       │   ├── identity/               # IAM Identity Center (SSO)
│       │   ├── cross-account-iam/      # Deploy terraform roles per account
│       │   └── shared-services/        # Core VPC and networking
│       └── workloads/
│           ├── production/             # Production VPC and resources
│           └── sandbox/                # Sandbox VPC and resources
├── Makefile
└── README.md
```

## Quick Start

See [bootstrap/README.md](bootstrap/README.md) for the complete step-by-step guide.

### TL;DR

```bash
# 1. Create S3 bucket and DynamoDB table (see bootstrap guide)

# 2. Copy and customize the configuration file
cp config/foundation.example.tfvars config/foundation.auto.tfvars
# Edit foundation.auto.tfvars with your project name, account IDs, emails, etc.

# 3. Replace remaining placeholders in .tf files (domain, github org, SSO users)

# 4. Apply in order:
make organizations plan
make organizations apply

make identity plan
make identity apply

make cross-account-iam plan
make cross-account-iam apply

make shared-services plan
make shared-services apply

make production plan
make production apply

make sandbox plan
make sandbox apply
```

## Makefile Targets

```bash
make help                        # Show all available targets
make fmt                         # Format all Terraform files
make validate-all                # Initialize and validate all stacks

make organizations plan|apply     # Root organization + accounts + SCPs
make identity plan|apply          # IAM Identity Center SSO
make cross-account-iam plan|apply # Terraform role + GitHub OIDC
make shared-services plan|apply   # Core VPC + networking
make production plan|apply        # Production VPC + resources
make sandbox plan|apply           # Sandbox VPC + resources
```

## Apply Order

Apply Terraform components in this order:

```
1. organizations       (creates AWS Organization, OUs, accounts, SCPs)
2. identity            (configures IAM Identity Center / SSO)
3. cross-account-iam   (creates terraform execution roles + GitHub OIDC)
4. shared-services     (creates core VPC and networking)
5. production          (creates production VPC and resources)
6. sandbox             (creates sandbox VPC and resources)
```

## Expected Outputs

After applying all stacks, the following resources will be provisioned:

### Organization (`organizations` stack)

| Output | Description |
|--------|-------------|
| `aws_organizations_organization.root` | AWS Organization with all features enabled |
| `aws_organizations_organizational_unit.management` | Management OU |
| `aws_organizations_organizational_unit.security` | Security OU |
| `aws_organizations_organizational_unit.workloads` | Workloads OU |
| `aws_organizations_account.identity` | Identity account (Security OU) |
| `aws_organizations_account.shared-services` | Shared Services account (Management OU) |
| `aws_organizations_account.production` | Production account (Workloads OU) |
| `aws_organizations_account.sandbox` | Sandbox account (Workloads OU) |
| SCPs (7 policies) | DenyLeavingOrganization, DenyRootUserAccess, DenyDisablingCloudTrail, DenyDisablingConfigRules, DenyDisablingGuardDuty, DenyPublicS3Buckets, RequireVPCLambda |

### SSM Parameters (cross-account references)

```
/organizations/accounts/management      → 111111111111
/organizations/accounts/identity        → 222222222222
/organizations/accounts/shared-services → 333333333333
/organizations/accounts/production      → 444444444444
/organizations/accounts/sandbox         → 555555555555
```

### Identity (`identity` stack)

| Output | Description |
|--------|-------------|
| IAM Identity Center users | SSO users created with email-based login |
| Permission sets | AdministratorAccess, PowerUserAccess, ReadOnlyAccess, Billing |
| Group assignments | Users mapped to permission sets per account |

### Cross-Account IAM (`cross-account-iam` stack)

| Output | Description |
|--------|-------------|
| `terraform` role (all accounts) | Cross-account execution role with AdministratorAccess |
| GitHub OIDC provider | Federated access for GitHub Actions (`token.actions.githubusercontent.com`) |
| GitHub OIDC role | `arn:aws:iam::*:role/github-actions` with trust policy scoped to repo |

### Networking

| Stack | CIDR | NAT GWs | Endpoints |
|-------|------|---------|-----------|
| `shared-services` | `10.0.0.0/16` | 1 | STS, ECR, Logs, execute-api |
| `production` | `10.1.0.0/16` | 3 (HA) | STS, ECR, Logs, execute-api |
| `sandbox` | `10.2.0.0/16` | 1 | STS, ECR, Logs, execute-api |

Each VPC includes: public/private subnets across 3 AZs, Internet Gateway, VPC Flow Logs (CloudWatch, 30-day retention), S3 + DynamoDB Gateway endpoints, and resource tags for EKS auto-discovery.

## Security SCPs

The following Service Control Policies are applied at the root level:

| SCP | Effect |
|-----|--------|
| `DenyLeavingOrganization` | Prevents member accounts from leaving the org |
| `DenyRootUserAccess` | Blocks actions from root user in member accounts |
| `DenyDisablingCloudTrail` | Protects CloudTrail from being stopped/deleted |
| `DenyDisablingConfigRules` | Protects AWS Config from being disabled |
| `DenyDisablingGuardDuty` | Protects GuardDuty from being disabled |
| `DenyPublicS3Buckets` | Blocks public S3 bucket creation (optional, enabled by default) |
| `RequireVPCLambda` | Enforces Lambda in VPC (optional, disabled by default) |

## CI/CD Pipelines

### How it Works

The pipeline uses **GitHub Actions OIDC** to assume the `terraform` role in the management account. No long-lived credentials. The same OIDC session is mirrored to `bootstrapper` and `management` AWS profiles so Terraform providers work transparently in CI.

```
GitHub OIDC Token
      │
      ▼
aws-actions/configure-aws-credentials
      │  assume role: arn:aws:iam::MANAGEMENT:role/terraform
      ▼
AWS env vars (AWS_ACCESS_KEY_ID, ...)
      │
      ├─► aws configure set --profile bootstrapper  (for state + cross-account)
      └─► aws configure set --profile management     (for management ops)
```

### PR Validation (`terraform-plan.yaml`)

Triggered on every PR that changes `aws/**` or `modules/**`.

| Step | What it does |
|------|-------------|
| `detect-changes` | Only runs affected stacks via `dorny/paths-filter` |
| `plan` (matrix) | `fmt -check` → `validate` → `plan` → posts result as PR comment |

### Manual Apply (`terraform-apply.yaml`)

Triggered via **Actions → Terraform Apply → Run workflow**.

| Input | Description |
|-------|-------------|
| `stack` | Which stack to apply (`organizations`, `identity`, `cross-account-iam`, `shared-services`, `production`, `sandbox`) |
| `auto_approve` | Skip approval gate (use for sandbox/dev, never for production) |

**Approval gate** (when `auto_approve = false`):
1. Creates a GitHub issue in the repo with the plan output
2. Waits up to 60 minutes for a reviewer to comment `approve` or `reject`
3. On `approve`: proceeds with `terraform apply`
4. On `reject` or timeout: cancels

### Required Setup

**1. GitHub Actions Variable:**

```
Settings → Secrets and variables → Actions → Variables
  TERRAFORM_ROLE = arn:aws:iam::MANAGEMENT_ACCOUNT_ID:role/terraform
```

**2. GitHub Environments** (optional, for approval protection):

```
Settings → Environments
  organizations       → Required reviewers: Infrastructure team
  identity            → Required reviewers: Infrastructure team
  cross-account-iam   → Required reviewers: Infrastructure team
  shared-services     → No protection (auto-deploy)
```

**3. OIDC Trust in the `terraform` role** (already configured by `cross-account-iam`):

```json
{
  "Effect": "Allow",
  "Principal": { "Federated": "arn:aws:iam::ACCOUNT:oidc-provider/token.actions.githubusercontent.com" },
  "Action": "sts:AssumeRoleWithWebIdentity",
  "Condition": {
    "ForAnyValue:StringLike": {
      "token.actions.githubusercontent.com:sub": "repo:YOUR_ORG/*:*"
    }
  }
}
```

### Apply Order in CI

The same order as local applies, but `auto_approve` is critical:

```bash
# Bootstrap: manually apply organizations + identity + cross-account-iam once
# to create the terraform roles and OIDC trust.

# After bootstrap, CI can apply any stack:
#  1. auto_approve=true  for sandbox/dev stacks
#  2. auto_approve=false for production stacks (requires human approval)
```

> **Note**: The first apply of each stack MUST be done locally because the `terraform` role doesn't exist yet for member accounts. After `cross-account-iam` creates the role in all accounts, CI can apply everything.

## Configuration

See [config/foundation.example.tfvars](config/foundation.example.tfvars) for the configuration template. Copy and customize:

```bash
cp config/foundation.example.tfvars config/foundation.auto.tfvars
```

Edit the file with your project name, management account ID, domain, GitHub organization, account emails, and SSO users.

## Customization

### Adding Accounts

Edit `aws/organizations/management/organizations/organizations.tf`:

```hcl
accounts = [
  # ... existing accounts ...
  {
    name              = "my-new-account"
    email             = "aws+workloads-my-new-account@mycompany.com"
    organization_unit = "workloads"
  },
]
```

Then update the SSO account assignments in `aws/organizations/management/identity/main.tf` and re-apply `cross-account-iam`.

### Adding SSO Users

Edit `aws/organizations/management/identity/main.tf` `locals.sso_users`:

```hcl
"new.user@mycompany.com" : {
  group_membership = ["engineers"]
  user_name        = "new.user@mycompany.com"
  given_name       = "New"
  family_name      = "User"
  email            = "new.user@mycompany.com"
}
```

## Roadmap

- [ ] Add reusable `tfvars` examples per scenario
- [ ] Add Control Tower comparison guide
- [ ] Add organization-wide CloudTrail module
- [ ] Add AWS Config aggregator module
- [ ] Add GuardDuty delegated administrator setup
- [ ] Add Security Hub delegated administrator setup
- [ ] Add IAM Identity Center group examples
- [ ] Add GitHub Actions reusable workflows
- [ ] Add cost estimation notes
- [ ] Publish module examples for Terraform Registry

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on setup, code style, and pull requests.

## References

- [AWS Organizations Best Practices](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_best-practices.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [IAM Identity Center Module](https://registry.terraform.io/modules/aws-ia/iam-identity-center/aws)

## License

MIT - See LICENSE file for details.
