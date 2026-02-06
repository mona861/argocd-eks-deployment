# Create IAM Role
resource "aws_iam_role" "eks_alb_role" {
  name = "${var.ENV}-AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
      Effect  = "Allow"
      Sid    = "webidenity"
      "Action": "sts:AssumeRoleWithWebIdentity"

      Principal = {
        Federated = "${aws_iam_openid_connect_provider.oidc_provider.arn}"
      }

      # Condition: Only this specific ServiceAccount can assume the role
      Condition = {
            StringEquals = {  
              "${local.oidc_provider_url}:sub":"system:serviceaccount:kube-system:aws-load-balancer-controller",
              "${local.oidc_provider_url}:aud":"sts.amazonaws.com"

            }
      }
    
    }
    ]
  })
    inline_policy {
    name = "eks-alb-access-policy"

    policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": "elasticloadbalancing.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAddresses",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeVpcs",
                "ec2:DescribeVpcPeeringConnections",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeInstances",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeTags",
                "ec2:GetCoipPoolUsage",
                "ec2:DescribeCoipPools",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeListenerCertificates",
                "elasticloadbalancing:DescribeSSLPolicies",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:DescribeTags"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cognito-idp:DescribeUserPoolClient",
                "acm:ListCertificates",
                "acm:DescribeCertificate",
                "iam:ListServerCertificates",
                "iam:GetServerCertificate",
                "waf-regional:GetWebACL",
                "waf-regional:GetWebACLForResource",
                "waf-regional:AssociateWebACL",
                "waf-regional:DisassociateWebACL",
                "wafv2:GetWebACL",
                "wafv2:GetWebACLForResource",
                "wafv2:AssociateWebACL",
                "wafv2:DisassociateWebACL",
                "shield:GetSubscriptionState",
                "shield:DescribeProtection",
                "shield:CreateProtection",
                "shield:DeleteProtection"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:CreateSecurityGroup",
                "ec2:DeleteSecurityGroup"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Resource": "arn:aws:ec2:*:*:security-group/*",
            "Condition": {
                "StringEquals": {
                    "ec2:CreateAction": "CreateSecurityGroup"
                },
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:SetIpAddressType",
                "elasticloadbalancing:SetSecurityGroups",
                "elasticloadbalancing:SetSubnets",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:AddListenerCertificates",
                "elasticloadbalancing:RemoveListenerCertificates",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:RemoveTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/*/*"
            ],
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false",
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
         {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:*"
            ],
            "Resource": "*"
        }
    ]
    })
    }
}


resource "null_resource" "enable_alb" {
  # Run this only when needed
  triggers = {
    external_alb_installed = "true"
  }

  provisioner "local-exec" {
    command = <<EOT
      #!/bin/bash
      set -e

      # Ensure helm repo is added
      aws eks update-kubeconfig --name "${aws_eks_cluster.eks_cluster.name}" --region ${var.AWS_REGION} --profile ${var.AWS_PROFILE}
      if ! kubectl get serviceaccount aws-load-balancer-controller -n kube-system &>/dev/null; then
        kubectl create serviceaccount aws-load-balancer-controller -n kube-system
        kubectl annotate serviceaccount aws-load-balancer-controller -n kube-system eks.amazonaws.com/role-arn=${aws_iam_role.eks_alb_role.arn}
     fi  
      
      
      helm repo list
      helm repo add eks https://aws.github.io/eks-charts --force-update
      helm repo update

      helm uninstall aws-load-balancer-controller -n kube-system --ignore-not-found
   
      helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=${local.cluster_prefix}cluster \
        --set serviceAccount.create=false \
        --set serviceAccount.name=aws-load-balancer-controller --set region=${var.AWS_REGION} --set vpcId=${data.aws_vpc.vpc.id}
      kubectl apply -f https://raw.githubusercontent.com/aws/eks-charts/master/stable/aws-load-balancer-controller/crds/crds.yaml
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [aws_eks_node_group.eks_ng_private]
}