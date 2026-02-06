data "aws_partition" "current" {}

locals {
  oidc_provider_url = replace(
    aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer,
    "https://",
    ""
  )
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.${data.aws_partition.current.dns_suffix}"]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer

  tags = merge(
    {
      Name = "${local.cluster_prefix}-oidc"
    },
    local.common_tags
  )
}

data "aws_iam_policy_document" "external_secrets_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.oidc_provider.arn]
    }

    # Condition: Only this specific ServiceAccount can assume the role
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_url}:sub"
      values = [
        "system:serviceaccount:${var.ENV}:${var.ENV}-demo-eks-sa"
      ]
    }

    # Condition: Audience must be sts.amazonaws.com
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

locals {
  aws_iam_oidc_connect_provider_extract_from_arn = element(split("oidc-provider/", "${aws_iam_openid_connect_provider.oidc_provider.arn}"), 1)
}

output "aws_iam_openid_connect_provider_arn" {
  description = "AWS IAM Open ID Connect Provider ARN"
  value       = aws_iam_openid_connect_provider.oidc_provider.arn
}

output "aws_iam_openid_connect_provider_extract_from_arn" {
  description = "AWS IAM Open ID Connect Provider extract from ARN"
  value       = local.aws_iam_oidc_connect_provider_extract_from_arn
}
