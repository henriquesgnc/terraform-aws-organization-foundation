# =============================================================================
# AWS Organization Foundation — Configuration
# =============================================================================
# Copy this file to foundation.auto.tfvars and adjust values for your environment.
#   cp config/foundation.example.tfvars config/foundation.auto.tfvars
# =============================================================================

project_name          = "mycompany"
management_account_id = "111111111111"
domain                = "mycompany.com"
github_org            = "mycompany"
default_region        = "us-east-1"

# -----------------------------------------------------------------------------
# Member Accounts
# -----------------------------------------------------------------------------
accounts = {
  identity = {
    email = "aws+security-identity@mycompany.com"
    ou    = "security"
  }
  shared_services = {
    email = "aws+management-shared-services@mycompany.com"
    ou    = "management"
  }
  production = {
    email = "aws+workloads-production@mycompany.com"
    ou    = "workloads"
  }
  sandbox = {
    email = "aws+workloads-sandbox@mycompany.com"
    ou    = "workloads"
  }
}

# -----------------------------------------------------------------------------
# SSO Users (IAM Identity Center)
# -----------------------------------------------------------------------------
sso_users = {
  "admin@mycompany.com" = {
    group_membership = ["administrators"]
    user_name        = "admin@mycompany.com"
    given_name       = "Admin"
    family_name      = "User"
    email            = "admin@mycompany.com"
  }
}

# -----------------------------------------------------------------------------
# GitHub OIDC Thumbprint
# -----------------------------------------------------------------------------
# Obtain current value:
#   openssl s_client -servername token.actions.githubusercontent.com \
#     -connect token.actions.githubusercontent.com:443 2>/dev/null \
#     | openssl x509 -fingerprint -sha1 -noout | cut -d= -f2 \
#     | tr -d : | tr '[:upper:]' '[:lower:]'
github_oidc_thumbprint = "6938fd4d98bab03faadb97b34396831e3780aea1"
