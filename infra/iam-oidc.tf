# OIDC provider + trust policy
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

data "aws_iam_policy_document" "gha_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main",
        "repo:${var.github_org}/${var.github_repo}:pull_request"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "gha_deploy" {
  name               = "${local.name}-gha-deploy"
  assume_role_policy = data.aws_iam_policy_document.gha_assume.json
  tags               = local.tags
}

# --- CI/CD policy for deploy role ---
data "aws_iam_policy_document" "gha_policy" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:CreateRepository",
      "ecr:DescribeRepositories",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:BatchGetImage"
    ]
    resources = ["*"]
  }
  statement {
    actions   = ["sts:GetCallerIdentity"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "gha_policy" {
  name   = "${local.name}-gha-ecr-policy"
  policy = data.aws_iam_policy_document.gha_policy.json
}

resource "aws_iam_role_policy_attachment" "gha_attach" {
  role       = aws_iam_role.gha_deploy.name
  policy_arn = aws_iam_policy.gha_policy.arn
}
