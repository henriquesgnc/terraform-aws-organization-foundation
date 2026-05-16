# GitHub OIDC

## Overview

This project uses **GitHub Actions OIDC** for CI/CD authentication. No AWS access keys or long-lived credentials are stored in GitHub.

## How it Works

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

## Prerequisites

1. The `cross-account-iam` stack has been applied (creates OIDC provider + `terraform` role)
2. GitHub Actions variable `TERRAFORM_ROLE` is set
3. The `terraform` role's trust policy includes your GitHub org/repo

## Required GitHub Actions Setup

### 1. Variable

```
Settings → Secrets and variables → Actions → Variables
  TERRAFORM_ROLE = arn:aws:iam::MANAGEMENT_ACCOUNT_ID:role/terraform
```

### 2. Environments (optional, for approval protection)

```
Settings → Environments
  organizations       → Required reviewers: Infrastructure team
  identity            → Required reviewers: Infrastructure team
  cross-account-iam   → Required reviewers: Infrastructure team
```

## OIDC Trust Policy

The trust policy is scoped to your GitHub organization and repos:

```json
{
  "Effect": "Allow",
  "Principal": {
    "Federated": "arn:aws:iam::ACCOUNT:oidc-provider/token.actions.githubusercontent.com"
  },
  "Action": "sts:AssumeRoleWithWebIdentity",
  "Condition": {
    "ForAnyValue:StringLike": {
      "token.actions.githubusercontent.com:sub": "repo:YOUR_ORG/*:*"
    }
  }
}
```

## Thumbprint Rotation

GitHub rotates their OIDC certificate periodically. If OIDC auth breaks, obtain the current thumbprint:

```bash
openssl s_client -servername token.actions.githubusercontent.com \
  -connect token.actions.githubusercontent.com:443 2>/dev/null \
  | openssl x509 -fingerprint -sha1 -noout | cut -d= -f2 \
  | tr -d : | tr '[:upper:]' '[:lower:]'
```

Update the `github_oidc_thumbprint` variable in the `cross-account-iam` module and re-apply.
