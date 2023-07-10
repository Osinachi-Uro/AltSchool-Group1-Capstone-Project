# Data for availability Zones
data "aws_availability_zones" "azs" {}

# Create VPC
module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  version         = "3.19.0"
  name            = "Capstone-vpc"
  cidr            = var.vpc_cidr_block
  private_subnets = var.private_subnet_cidr_blocks
  public_subnets  = var.public_subnet_cidr_blocks
  azs             = slice(data.aws_availability_zones.azs.names, 0, 2)

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_flow_log      = false

  # tags = {
  #   "kubernetes.io/cluster/capstone-cluster" = "shared"
  # }

  public_subnet_tags = {
    "kubernetes.io/cluster/capstone-cluster" = "shared"
    "kubernetes.io/role/elb"                         = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/capstone-cluster" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}
