# Terraform Provider Block
provider "aws" {
  region  = "us-east-1"
  profile = var.AWS_PROFILE
  default_tags {
    tags = local.common_tags
  }
}

// Getting availability zones
data "aws_availability_zones" "availability_zones" {

  state = "available"

}

// Getting VPC
data "aws_vpc" "vpc" {

  filter {
    name = "tag:Name"
    values = [
    "${var.VPC_NAME}"]
  }
}

// Getting subnets
data "aws_subnets" "public_subnets" {
  count = length(var.PUBLIC_SUBNETS_AZ)

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["public-subnet-${var.VPC_NAME}"]
  }

  filter {
    name   = "availabilityZone"
    values = [var.PUBLIC_SUBNETS_AZ[count.index]]
  }
}

data "aws_subnets" "private_subnets" {
  count = length(var.PRIVATE_SUBNETS_AZ)

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["private-subnet-${var.VPC_NAME}"]
  }

  filter {
    name   = "availabilityZone"
    values = [var.PRIVATE_SUBNETS_AZ[count.index]]
  }
}


# Create AWS EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "${local.cluster_prefix}cluster"
  role_arn = aws_iam_role.eks_master_role.arn
  version  = var.CLUSTER_VERSION

  bootstrap_self_managed_addons = true //set to false for auto-mode

   access_config {
    authentication_mode = "API_AND_CONFIG_MAP" //"CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  compute_config {
    enabled = false //set to true for auto-mode
  }

  storage_config {
    block_storage {
      enabled = false //set to true for auto-mode
    }
  }

  vpc_config {
    subnet_ids              = local.public_subnet_ids
    endpoint_private_access = var.CLUSTER_ENDPOINT_PRIVATE_ACCESS
    endpoint_public_access  = var.CLUSTER_ENDPOINT_PUBLIC_ACCESS
    public_access_cidrs     = var.CLUSTER_ENDPOINT_PUBLIC_ACCESS_CIDRS
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = false //set to true for auto-mode
    }
    service_ipv4_cidr = var.CLUSTER_SERVICE_IPV4_CIDR
  }

  # Enable EKS Cluster Control Plane Logging
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
  ]
}

resource "aws_eks_addon" "addons" {
  for_each          = { for addon in var.addons : addon.name => addon }
  cluster_name      = aws_eks_cluster.eks_cluster.id
  addon_name        = each.value.name
  addon_version     = each.value.version
  depends_on = [aws_eks_node_group.eks_ng_private]
}
