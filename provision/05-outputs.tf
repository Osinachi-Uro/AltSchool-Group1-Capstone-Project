output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  value = aws_eks_cluster.eks-cluster.name
}


output "endpoint" {
  value = aws_eks_cluster.eks-cluster.endpoint
}
