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


data "aws_eks_cluster" "Capstone-eks-app-cluster" {
  name = "Capstone-eks-app-cluster"
}
data "aws_eks_cluster_auth" "Capstone-eks-app-cluster_auth" {
  name = "Capstone-eks-app-cluster_auth"
}


provider "aws" {
  region     = "us-east-1"
}

provider "helm" {
    kubernetes {
      config_path = "~/.kube/config"
    }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "kubectl" {
   load_config_file = false
   host                   = data.aws_eks_cluster.ClusterName.endpoint
   cluster_ca_certificate = base64decode(data.aws_eks_cluster.ClusterName.certificate_authority[0].data)
   token                  = data.aws_eks_cluster_auth.ClusterName_auth.token
    config_path = "~/.kube/config"
    }
