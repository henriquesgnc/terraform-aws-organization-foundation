# Troubleshooting

## Common Issues

### "OrganizationAccountAccessRole not found"

Member accounts may still be initializing after creation. Wait 1-2 minutes and retry.

```bash
# Verify the account status
aws organizations describe-account --account-id <ACCOUNT_ID> --profile management
```

### State lock errors

```bash
aws dynamodb scan --table-name terraform-state-lock --profile management
# If needed, manually delete the lock item
aws dynamodb delete-item \
  --table-name terraform-state-lock \
  --key '{"LockID": {"S": "aws/organizations/management/organizations/terraform.tfstate-md5"}}' \
  --profile management
```

### Permission denied during assume role

Ensure you're using the `bootstrapper` profile and your IAM user is in the `bootstrapper` group created by the organizations module.

```bash
# Verify group membership
aws iam list-groups-for-user --user-name <YOUR_USER> --profile management

# Verify the bootstrapper policy
aws iam list-attached-group-policies --group-name bootstrapper --profile management
```

### GitHub OIDC authentication fails

1. Check the thumbprint is current:
   ```bash
   openssl s_client -servername token.actions.githubusercontent.com \
     -connect token.actions.githubusercontent.com:443 2>/dev/null \
     | openssl x509 -fingerprint -sha1 -noout | cut -d= -f2 \
     | tr -d : | tr '[:upper:]' '[:lower:]'
   ```
2. Verify the trust policy in the `terraform` role
3. Check the `TERRAFORM_ROLE` variable matches the role ARN
4. Verify the OIDC subject condition includes your repo

### terraform init fails with S3 access denied

Ensure the `bootstrapper` profile has the correct credentials and the S3 bucket exists:

```bash
aws s3 ls s3://YOUR_PROJECT_NAME-s3-tfstate --profile bootstrapper
```

### Provider version mismatch

If the `.terraform.lock.hcl` file is stale (different platform), delete it and re-init:

```bash
find . -name '.terraform.lock.hcl' -delete
terraform init
```
