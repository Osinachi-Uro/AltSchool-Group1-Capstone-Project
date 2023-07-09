#Add providers
terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }

    kubernetes = {
        version = ">= 2.0.0"
        source = "hashicorp/kubernetes"
    }

    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

# Data for Cluster Auth
data "aws_eks_cluster_auth" "eks_cluster" {
  name = "capstone-cluster"
}

data "aws_eks_cluster" "eks_cluster" {
  name = "capstone-cluster"
}

provider "aws" {
  region     = "eu-west-1"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
#  config_path = pathexpand(var.kube_config)
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks_cluster.token
  load_config_file       = false
  config_path            = "~/.kube/config"
}

# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.eks_cluster.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority.0.data)
#   token                  = data.aws_eks_cluster_auth.eks_cluster.token
#   load_config_file       = false
# }
