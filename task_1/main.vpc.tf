module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.namespace}-${local.environment}"
  cidr = local.cidr

  azs                 = local.azs
  private_subnets     = [for k, v in local.azs : cidrsubnet(local.cidr, 8, k)]
  public_subnets      = [for k, v in local.azs : cidrsubnet(local.cidr, 8, k + 4)]
  database_subnets    = [for k, v in local.azs : cidrsubnet(local.cidr, 8, k + 8)]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  create_database_subnet_group = true


  tags = local.tags
}