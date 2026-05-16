# Startup Basic Example

Use this example if you need a simple AWS Organization with:

- Management account (root/billing)
- Identity account (IAM Identity Center SSO)
- Shared Services account (VPC + networking)
- Production account
- Sandbox account
- Basic SCP guardrails

## Configuration

Copy the example config and edit with your values:

```bash
cp config/foundation.example.tfvars config/foundation.auto.tfvars
```

## Account Structure

```
Root
├── Management OU
│   ├── Management Account
│   └── Shared Services Account
├── Security OU
│   └── Identity Account
└── Workloads OU
    ├── Production Account
    └── Sandbox Account
```

## Apply Order

```bash
make organizations plan && make organizations apply
make identity plan && make identity apply
make cross-account-iam plan && make cross-account-iam apply
make shared-services plan && make shared-services apply
make production plan && make production apply
make sandbox plan && make sandbox apply
```
