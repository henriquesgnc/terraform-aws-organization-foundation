# SCP Guardrails

Service Control Policies (SCPs) are applied at the root of the AWS Organization and affect all member accounts.

## Applied SCPs

| SCP | Type | Effect |
|-----|------|--------|
| **DenyLeavingOrganization** | Always enabled | Prevents member accounts from leaving the org |
| **DenyRootUserAccess** | Always enabled | Blocks actions from root user in member accounts |
| **DenyDisablingCloudTrail** | Always enabled | Protects CloudTrail from being stopped/deleted/modified |
| **DenyDisablingConfigRules** | Always enabled | Protects AWS Config from being disabled |
| **DenyDisablingGuardDuty** | Always enabled | Protects GuardDuty from being disabled |
| **DenyPublicS3Buckets** | Enabled by default | Blocks public S3 bucket creation |
| **RequireVPCLambda** | Disabled by default | Enforces Lambda functions in VPC |

## Configuration

Configure SCP options in `aws/organizations/management/organizations/organizations.tf`:

```hcl
module "scp_policies" {
  source = "../../../../modules/aws/organizations/scp"

  root_id              = module.aws_organizations.root_id
  enable_s3_public_block = true   # Enabled by default
  enable_lambda_vpc      = false  # Disabled by default
}
```

## Adding Custom SCPs

Add new SCP resources to `modules/aws/organizations/scp/main.tf` and attach them in `modules/aws/organizations/scp/attachments.tf`.

## Important Notes

- SCPs do **not** affect the management account
- SCPs are a preventive control, not a detective control
- For detective controls, use AWS Config rules and Security Hub
- Test new SCPs on a sandbox OU before applying to root
