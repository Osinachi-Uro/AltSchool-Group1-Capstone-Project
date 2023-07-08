# Create AWS IAM role for EKS Cluster
resource "aws_iam_role" "EKS-Cluster-Role" {
  name = "EKS-Cluster-Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}


# Attachments
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.EKS-Cluster-Role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.EKS-Cluster-Role.name
}


# Create AWS IAM role for NodeGroup
resource "aws_iam_role" "Node-Group-Role" {
  name = "EKS-Node-Group-Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Allows EKS worker nodes to connect to EKS Clusters
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.Node-Group-Role.name
}

# Provides read-only access to Amazon EC2 Container Registry repositories
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.Node-Group-Role.name
}

# Allows VPC CNI Plugin (amazon-vpc-cni-k8s) the permissions it requires to modify the IP address configuration on your EKS worker nodes
resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.Node-Group-Role.name
}


# Create EKS Cluster
resource "aws_eks_cluster" "eks-cluster" {
  name     = local.cluster_name
  role_arn = aws_iam_role.EKS-Cluster-Role.arn

  vpc_config {
    security_group_ids = [aws_security_group.clustersg.id, aws_security_group.node-clustersg.id]
    subnet_ids         = flatten([module.vpc.private_subnets, module.vpc.private_subnets])

  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
    module.vpc,
    aws_security_group.clustersg,
    aws_security_group.node-clustersg,
  ]

}


# Node Group with 2 EC2 Instances
resource "aws_eks_node_group" "node-1" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "node-1"
  node_role_arn   = aws_iam_role.Node-Group-Role.arn
  subnet_ids      = flatten(module.vpc.private_subnets)
  # remote_access {
  #   ec2_ssh_key = "k8"
  # }

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  instance_types = ["t2.medium"]
  disk_size      = 20

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    module.vpc,
    aws_security_group.clustersg,
    aws_security_group.node-clustersg,
  ]

  tags = {
    node_group = "node-1"
  }

}

# Data for Cluster Auth
data "aws_eks_cluster" "eks_cluster" {
  name = aws_eks_cluster.eks-cluster.name
}

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = aws_eks_cluster_auth.eks-cluster.name
}
