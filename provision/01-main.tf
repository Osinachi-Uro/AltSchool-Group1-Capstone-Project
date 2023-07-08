provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
  }
}

# Data for aws caller identity
data "aws_caller_identity" "current" {}


locals {
  name         = join("-", ["Django-Sch", "eks", "cluster"])
  vpc_name     = join("", ["Django-Sch", "eks", "cluster"])
  cluster_name = join("", ["Django-Sch", "eks", "cluster"])
  azs          = slice(data.aws_availability_zones.available.names, 0, 2)

  vpc_cidr = "10.0.0.0/16"

  tags = {
    name   = local.name
    school = "Django-Sch"
  }

}

#########################################################################################################################################################

#########################################################################################################################################################

# Data for availability Zones
data "aws_availability_zones" "available" {}
# Create VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = local.vpc_name
  cidr                 = local.vpc_cidr
  azs                  = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets      = ["10.0.2.0/24", "10.0.4.0/24"]
  public_subnets       = ["10.0.3.0/24", "10.0.6.0/24"]
  intra_subnets        = ["10.0.10.0/24", "10.0.12.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_flow_log      = false


  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
