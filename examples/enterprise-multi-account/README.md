# Enterprise Multi-Account Example

Designed for large organizations with complex governance needs.

## Configuration

- Multiple workload OUs (Dev, Staging, Prod, Data, Sandbox)
- Separate security tooling account
- Dedicated logging/audit account
- Network account with Transit Gateway
- Organization-wide AWS Config aggregation
- Organization-wide CloudTrail

## Architecture

```
Root
├── Management OU
│   ├── Management Account
│   ├── Shared Services Account
│   └── Network Account (Transit Gateway)
├── Security OU
│   ├── Identity Account (SSO)
│   ├── Audit/Logging Account
│   └── Security Tooling Account
├── Workloads OU
│   ├── Dev Account
│   ├── Staging Account
│   ├── Prod Account
│   └── Data Account
└── Sandbox OU
    ├── Dev-Sandbox Account
    └── Experiments Account
```

This blueprint provides the foundation. Extend with Transit Gateway, CloudTrail organization trail, and AWS Config aggregator modules.
