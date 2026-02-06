data "aws_caller_identity" "current" {}

// Local variables
locals {
  private_subnet_ids = flatten([for network in data.aws_subnets.private_subnets : network.ids])
  public_subnet_ids  = flatten([for network in data.aws_subnets.public_subnets : network.ids])
  cluster_prefix     = "${var.ENV}-${var.PROJECT_NAME}-"
  namespace          = var.ENV 
  common_tags = {
    environment = var.ENV
    project     = var.PROJECT_NAME
  }

}