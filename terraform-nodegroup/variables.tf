variable "PROJECT_NAME" {
  type    = string
  default = "demo-eks"
}
variable "ENV" {}

variable "AWS_PROFILE" {}

variable "AWS_REGION" {}

variable "VPC_NAME" {}

variable "VPC_CIDR_BLOCK" {}

variable "PUBLIC_SUBNETS_AZ" {
  type = list(string)
}

variable "PRIVATE_SUBNETS_AZ" {
  type = list(string)
}

variable "VPC_PUBLIC_SUBNETS" {
  type = list(string)
}

variable "VPC_PRIVATE_SUBNETS" {
  type = list(string)
}

variable "VPC_DATABASE_SUBNETS" {
  type = list(string)
}



variable "CLUSTER_SERVICE_IPV4_CIDR" {
  description = "service ipv4 cidr for the kubernetes cluster"
  type        = string
  default     = null
}

variable "CLUSTER_VERSION" {
  description = "Kubernetes minor version to use for the EKS cluster (for example 1.21)"
  type        = string
  default     = "1.34"
}
variable "CLUSTER_ENDPOINT_PRIVATE_ACCESS" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = false
}

variable "CLUSTER_ENDPOINT_PUBLIC_ACCESS" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. When it's set to `false` ensure to have a proper private access with `cluster_endpoint_private_access = true`."
  type        = bool
  default     = true
}

variable "CLUSTER_ENDPOINT_PUBLIC_ACCESS_CIDRS" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))

  default = [
    {
      name    = "aws-secrets-store-csi-driver-provider"
      version = "v2.1.1-eksbuild.1"
    },
    {
      name    = "kube-proxy"
      version = "v1.34.0-eksbuild.2"
    },
    {
      name    = "vpc-cni"
      version = "v1.20.4-eksbuild.2"
    },
    {
      name    = "coredns"
      version = "v1.12.3-eksbuild.1"
    },
    {
      name    = "eks-pod-identity-agent"
      version = "v1.3.10-eksbuild.2"
    }/*,
    {
      name    = "aws-ebs-csi-driver"
      version = "v1.54.0-eksbuild.1"
    }
    //*/
  ]
}