# Platform Team Example

Designed for platform engineering teams managing infrastructure for multiple product squads.

## Configuration

- 3+ workload accounts (one per squad or domain)
- CI/CD pipeline with approval gates on production
- SCP guardrails enforced at root level
- IAM Identity Center groups mapped to specific accounts

## Additional Considerations

- Enable VPN Gateway for shared-services if remote access is needed
- Use 3 NAT Gateways in production for high availability
- Set up GitHub Environments for all stacks with required reviewers
