# Networking

## VPC Module

Each stack (shared-services, production, sandbox) deploys a VPC using the reusable `modules/aws/vpc` module.

## Architecture per VPC

- **Public subnets**: 3 (one per AZ), hosts Internet-facing resources (load balancers, bastions)
- **Private subnets**: 3 (one per AZ), hosts application workloads
- **Internet Gateway**: for public subnet egress
- **NAT Gateway**: for private subnet egress
  - 1 NAT GW for shared-services and sandbox (~$36/mo)
  - 3 NAT GWs for production (multi-AZ HA, ~$108/mo)

## CIDR Allocation

| Stack | CIDR | Usable Size |
|-------|------|-------------|
| `shared-services` | `10.0.0.0/16` | 65,536 IPs |
| `production` | `10.1.0.0/16` | 65,536 IPs |
| `sandbox` | `10.2.0.0/16` | 65,536 IPs |

Each /16 is subdivided into /20 subnets (4,096 IPs per subnet).

## VPC Endpoints

### Gateway Endpoints (free)

- **S3**: enabled by default
- **DynamoDB**: disabled by default

### Interface Endpoints (~$7.20/mo each)

- **STS**: enabled in all stacks
- **ECR (api + dkr)**: enabled in all stacks
- **CloudWatch Logs**: enabled in all stacks
- **API Gateway (execute-api)**: enabled in all stacks

## VPC Flow Logs

- Enabled by default on all VPCs
- Logs sent to CloudWatch Logs
- 30-day retention (configurable)
- Captures ALL traffic

## EKS Support

All subnets are tagged for EKS auto-discovery:

```hcl
tags = {
  "kubernetes.io/cluster/<name>" = "shared"
  "kubernetes.io/role/elb"       = "1"
  "kubernetes.io/role/internal-elb" = "1"
}
```

## VPN Gateway

Disabled by default. Enable with `enable_vpn_gateway = true` at ~$36/mo.

## Cost Notes

Per-endpoint and per-resource cost estimates are documented in the module variable descriptions (`modules/aws/vpc/vars.tf`).
