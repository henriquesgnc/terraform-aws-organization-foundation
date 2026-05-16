resource "aws_organizations_policy" "deny_leaving_organization" {
  name        = "DenyLeavingOrganization"
  description = "Prevents member accounts from leaving the organization"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyLeaveOrganization"
        Effect   = "Deny"
        Action   = ["organizations:LeaveOrganization"]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_organizations_policy" "deny_root_user" {
  name        = "DenyRootUserAccess"
  description = "Denies actions by root user in member accounts"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyRootUser"
        Effect   = "Deny"
        Action   = ["*"]
        Resource = ["*"]
        Condition = {
          StringLike = {
            "aws:PrincipalArn" : ["arn:aws:iam::*:root"]
          }
        }
      }
    ]
  })
}

resource "aws_organizations_policy" "deny_cloudtrail_disable" {
  name        = "DenyDisablingCloudTrail"
  description = "Prevents stopping or deleting CloudTrail"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyCloudTrailChanges"
        Effect = "Deny"
        Action = [
          "cloudtrail:StopLogging",
          "cloudtrail:DeleteTrail",
          "cloudtrail:UpdateTrail",
          "cloudtrail:PutEventSelectors"
        ]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_organizations_policy" "deny_disable_config" {
  name        = "DenyDisablingConfigRules"
  description = "Prevents disabling or modifying AWS Config"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyConfigChanges"
        Effect = "Deny"
        Action = [
          "config:StopConfigurationRecorder",
          "config:DeleteDeliveryChannel",
          "config:DeleteConfigurationRecorder"
        ]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_organizations_policy" "deny_disable_guardduty" {
  name        = "DenyDisablingGuardDuty"
  description = "Prevents disabling GuardDuty or disassociating from master"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyGuardDutyChanges"
        Effect = "Deny"
        Action = [
          "guardduty:DeleteDetector",
          "guardduty:DisassociateFromMasterAccount",
          "guardduty:DisassociateMembers"
        ]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_organizations_policy" "deny_public_s3" {
  name        = "DenyPublicS3Buckets"
  description = "Denies making S3 buckets public"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyPublicS3"
        Effect   = "Deny"
        Action   = ["s3:PutBucketPublicAccessBlock"]
        Resource = ["*"]
        Condition = {
          "StringNotEquals" : {
            "s3:PublicAccessBlockConfiguration.RestrictPublicBuckets" : "true"
          }
        }
      }
    ]
  })
}

resource "aws_organizations_policy" "require_vpc_lambda" {
  name        = "RequireVPCLambda"
  description = "Requires Lambda functions to be attached to a VPC"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyLambdaWithoutVPC"
        Effect = "Deny"
        Action = [
          "lambda:CreateFunction",
          "lambda:UpdateFunctionConfiguration"
        ]
        Resource = ["*"]
        Condition = {
          "Null" : {
            "lambda:VpcIds" : "true"
          }
        }
      }
    ]
  })
}
