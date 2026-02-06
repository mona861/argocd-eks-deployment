output "public_subnets" {
  value = data.aws_subnets.public_subnets
}

output "private_subnets" {
  value = data.aws_subnets.private_subnets
}

