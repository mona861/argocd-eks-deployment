# Create AWS EKS Private Node Group
resource "aws_eks_node_group" "eks_ng_private" {
  cluster_name = aws_eks_cluster.eks_cluster.name

  node_group_name = "${local.cluster_prefix}ng-private"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = local.private_subnet_ids
  #version = var.cluster_version

  ami_type       = "AL2023_x86_64_STANDARD"
  capacity_type  = "ON_DEMAND"
  disk_size      = 20
  instance_types = ["t3.small"]

  scaling_config {
    desired_size = 3
    min_size     = 1
    max_size     = 3 
  }

  node_repair_config {
    enabled = false
  }
  update_config {
    max_unavailable = 1
    #max_unavailable_percentage = 50    # ANY ONE TO USE
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
  ]
  tags = {
    Name = "Private-Node-Group"
  }
}
