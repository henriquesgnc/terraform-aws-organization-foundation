resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [var.github_oidc_thumbprint]
}

resource "aws_iam_role" "terraform_execution_role" {
  name                 = "terraform"
  max_session_duration = var.max_session_duration

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowRootAccountAssumption",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        },
        Action = "sts:AssumeRole"
      },
      {
        Sid    = "AllowGitHubOIDC",
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          "ForAnyValue:StringLike" : {
            "token.actions.githubusercontent.com:sub" : (
              length(var.github_repos) == 1 && var.github_repos[0] == "*"
              ? ["repo:${var.github_organization}/*:*"]
              : [for repo in var.github_repos : "repo:${var.github_organization}/${repo}:*"]
            )
          }
        }
      }
    ]
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "terraform_execution_role_policies" {
  for_each = toset(var.terraform_role_managed_policy_arns)

  policy_arn = each.value
  role       = aws_iam_role.terraform_execution_role.name
}
