data "aws_eks_cluster_auth" "eks_cluster" {
  name = aws_eks_cluster.eks_cluster.name
}

provider "kubernetes" {
  host                   = aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_cluster.token
}

resource "kubernetes_namespace" "dev" {
  count = var.ENV != "default" ? 1 : 0
  metadata {
    name = local.namespace
  }
  depends_on = [data.aws_eks_cluster_auth.eks_cluster, aws_eks_cluster.eks_cluster]
}

