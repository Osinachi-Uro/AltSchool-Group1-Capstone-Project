# Security group for Cluster
resource "aws_security_group" "clustersg" {
  name        = "EKS-clustersg"
  description = "Cluster communication with worker nodes"
  vpc_id      = module.vpc.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "eks-clustersg"
  }
}

resource "aws_security_group_rule" "eks-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.clustersg.id
  source_security_group_id = aws_security_group.node-clustersg.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress_nodes_ephemeral_ports_tcp" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.clustersg.id
  source_security_group_id = aws_security_group.node-clustersg.id
  to_port                  = 22
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress_rule" {
  description              = "Allow ingress"
  from_port                = 0
  protocol                 = "tcp"
  security_group_id        = aws_security_group.clustersg.id
  source_security_group_id = aws_security_group.node-clustersg.id
  to_port                  = 65535
  type                     = "ingress"
}

#################################################################################################################################################################################################################################################################################################################

#################################################################################################################################################################################################################################################################################################################

# Security Group for Nodes
resource "aws_security_group" "node-clustersg" {
  name_prefix = "EKS-node-clustersg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = module.vpc.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group_rule" "node-clustersg-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.node-clustersg.id
  source_security_group_id = aws_security_group.node-clustersg.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "node-clustersg-ingress-cluster-https" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node-clustersg.id
  source_security_group_id = aws_security_group.clustersg.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "node-clustersg-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node-clustersg.id
  source_security_group_id = aws_security_group.clustersg.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "node-clustersg-ingress-cluster-ephemeral_ports_tcp" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node-clustersg.id
  source_security_group_id = aws_security_group.clustersg.id
  to_port                  = 22
  type                     = "ingress"
}
