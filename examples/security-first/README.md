# Security-First Example

Designed for teams with strict compliance requirements.

## Configuration

- All SCP guardrails enabled (including RequireVPCLambda)
- IAM Identity Center with security-engineers permission set
- SecurityAudit + GuardDuty + Security Hub access for security team
- Flow Logs enabled on all VPCs with extended retention

## Additional Considerations

- Review GitHub OIDC trust policy repo scope carefully
- Consider adding organization-wide CloudTrail trail
- Enable GuardDuty delegated administrator
- Set S3 public block SCP to mandatory (not optional)
