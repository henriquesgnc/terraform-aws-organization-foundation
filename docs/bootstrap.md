# Bootstrap Guide

## Overview

This guide walks you through the **initial manual setup** required before Terraform can manage your AWS Organization. The bootstrap process creates the foundation: an S3 bucket for Terraform state, a DynamoDB table for state locking, and a `bootstrapper` AWS CLI profile.

## Prerequisites

- A **new AWS account** (this will become your **management account**)
- An email address with **plus addressing** support (e.g. `aws+xxx@domain.com`) for member account emails
- Terraform >= 1.5.0 installed
- AWS CLI installed and configured

## Step 1: Configure AWS Management Account Credentials

Configure an administrative AWS CLI profile for the management account.

```bash
aws configure --profile management
# Use an IAM user or federated administrative session.
# Avoid using root credentials except for actions that strictly require root.
# Region: us-east-1
```

Enable IAM Identity Center in the management account:

```bash
aws sso-admin enable-sso --instance-arn arn:aws:sso:::instance/ssoins-XXXXX --profile management
```

## Step 2: Create Terraform State Resources

```bash
# Create S3 bucket for Terraform state
aws s3api create-bucket \
  --bucket YOUR_PROJECT_NAME-s3-tfstate \
  --region us-east-1 \
  --profile management

# Enable versioning on the state bucket
aws s3api put-bucket-versioning \
  --bucket YOUR_PROJECT_NAME-s3-tfstate \
  --versioning-configuration Status=Enabled \
  --profile management

# Enable server-side encryption
aws s3api put-bucket-encryption \
  --bucket YOUR_PROJECT_NAME-s3-tfstate \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }' \
  --profile management

# Block public access
aws s3api put-public-access-block \
  --bucket YOUR_PROJECT_NAME-s3-tfstate \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true \
  --profile management
```

## Step 3: Create DynamoDB Table for State Locking

```bash
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --profile management \
  --region us-east-1
```

## Step 4: Clone and Configure This Template

```bash
git clone https://github.com/YOUR_ORG/terraform-aws-organization-foundation.git
cd terraform-aws-organization-foundation
```

### Configuration

Copy and customize the configuration file:

```bash
cp config/foundation.example.tfvars config/foundation.auto.tfvars
```

Edit `config/foundation.auto.tfvars` with your values:

- `project_name` -> your project name (e.g. `mycompany`)
- `management_account_id` -> your management AWS account ID
- `domain` -> your domain (e.g. `mycompany.com`)
- `github_org` -> your GitHub organization (e.g. `mycompany`)
- `sso_users` -> your SSO users

### Replace remaining placeholders in .tf files

Find all remaining placeholders:

```bash
grep -r "SET_YOUR" --include="*.tf" .
```

Replace:
- `SET_YOUR_PROJECT_NAME` in backend.tf files
- `SET_YOUR_MANAGEMENT_ACCOUNT_ID` in vars.tf
- `SET_YOUR_DOMAIN.com` in organizations.tf
- `SET_YOUR_GITHUB_ORG` in cross-account-iam/main.tf
- `YOUR_EMAIL@example.com` in identity/main.tf

## Step 5: Apply Organizations

```bash
cd aws/organizations/management/organizations
terraform init
terraform plan
terraform apply
```

> **Note**: Creating member accounts takes a few minutes. Wait for all accounts to be created before proceeding.

## Step 6: Apply Identity (IAM Identity Center)

```bash
cd aws/organizations/management/identity
terraform init
terraform plan
terraform apply
```

## Step 7: Apply Cross-Account IAM

```bash
cd aws/organizations/management/cross-account-iam
terraform init
terraform plan
terraform apply
```

## Step 8: Apply Shared Services (VPC + Networking)

```bash
cd aws/organizations/management/shared-services
terraform init
terraform plan
terraform apply
```

## Bootstrap Complete

After the bootstrap, your AWS Organization structure is:

```
Root
├── Management OU
│   ├── Management Account (root/billing)
│   └── Shared Services (VPC, CI/CD, VPN)
├── Security OU
│   └── Identity (IAM Identity Center / SSO)
└── Workloads OU
    ├── Production
    └── Sandbox
```

### Next Steps

1. Add workload accounts in `aws/organizations/management/organizations/organizations.tf`
2. Set up CI/CD using the GitHub OIDC roles (see [github-oidc.md](github-oidc.md))
3. Configure GuardDuty, Security Hub, and CloudTrail organization-wide
4. Begin deploying application infrastructure

### Troubleshooting

**"OrganizationAccountAccessRole not found"**
The member accounts may still be initializing. Wait 1-2 minutes and retry.

**State lock errors**

```bash
aws dynamodb scan --table-name terraform-state-lock --profile management
# If needed, manually delete the lock item
```

**Permission denied during assume role**
Ensure you're using the `bootstrapper` profile and your IAM user is in the `bootstrapper` group created by the organizations module.
