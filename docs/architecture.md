# Architecture

## AWS Organization Structure

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

## Account Responsibilities

| Account | Purpose |
|---------|---------|
| **Management** | Root organization, billing, SCP attachments |
| **Identity** | IAM Identity Center (SSO), delegated administration |
| **Shared Services** | Core VPC, CI/CD tooling, monitoring |
| **Production** | Production workloads and applications |
| **Sandbox** | Development, testing, and experimentation |

## Terraform Stack Design

Each stack is a self-contained Terraform root module with its own state file:

| Stack | State Key | Profile | Dependencies |
|-------|-----------|---------|-------------|
| `organizations` | `aws/.../organizations/terraform.tfstate` | `management` | None |
| `identity` | `aws/.../identity/terraform.tfstate` | `bootstrapper` | `organizations` |
| `cross-account-iam` | `aws/.../cross-account-iam/terraform.tfstate` | `bootstrapper` | `organizations` |
| `shared-services` | `aws/.../shared-services/terraform.tfstate` | `bootstrapper` | `cross-account-iam` |
| `production` | `aws/.../production/terraform.tfstate` | `bootstrapper` | `cross-account-iam` |
| `sandbox` | `aws/.../sandbox/terraform.tfstate` | `bootstrapper` | `cross-account-iam` |

## Cross-Account Communication

SSM Parameter Store is used for cross-account references:

```
/organizations/accounts/<name>         → Account ID
/organizations/units/<name>            → OU ID
```

These parameters are written by the `organizations` stack and read by all downstream stacks via the `management` provider alias.
