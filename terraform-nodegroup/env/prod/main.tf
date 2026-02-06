module "main" {
  source = "../../"
  # Generic Variables
  AWS_PROFILE = "demo"
  AWS_REGION  = "us-east-1"
  ENV         = "prod"

  # VPC Variables
  VPC_NAME           = "eks-vpc"
  PUBLIC_SUBNETS_AZ  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  PRIVATE_SUBNETS_AZ = ["us-east-1a", "us-east-1c"]

  VPC_CIDR_BLOCK = "10.0.0.0/16"
  VPC_PUBLIC_SUBNETS                     = ["10.0.101.0/24", "10.0.102.0/24"]
  VPC_PRIVATE_SUBNETS                    = ["10.0.1.0/24", "10.0.2.0/24"]
  VPC_DATABASE_SUBNETS                   = ["10.0.151.0/24", "10.0.152.0/24"]
}