# IAM Role for the EKS Control Plane
resource "aws_iam_role" "eks_cluster" {
  name = "${var.project_name}-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "eks.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# The EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  vpc_config {
    subnet_ids = [aws_subnet.public_1a.id, aws_subnet.public_1b.id]
  }
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# IAM Role for Worker Nodes
resource "aws_iam_role" "eks_nodes" {
  name = "${var.project_name}-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

# 1. The On-Demand Node Group (The reliable backbone)
resource "aws_eks_node_group" "on_demand" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-on-demand-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = [aws_subnet.public_1a.id, aws_subnet.public_1b.id]
  capacity_type   = "ON_DEMAND"
  instance_types  = ["t3.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_read_only,
  ]
}

# 2. The Spot Node Group (The cost-effective workers)
resource "aws_eks_node_group" "spot" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-spot-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = [aws_subnet.public_1a.id, aws_subnet.public_1b.id]
  capacity_type   = "SPOT"
  instance_types  = ["t3.medium"]

  scaling_config {
    desired_size = 0
    max_size     = 1
    min_size     = 0
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_read_only,
  ]
}

# Create the standard access entry for Avishag
resource "aws_eks_access_entry" "avishag_admin" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.avishag_iam_arn
  type          = "STANDARD"
}

# Attach the official EKS Cluster Admin policy to her entry
resource "aws_eks_access_policy_association" "avishag_admin_policy" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.avishag_iam_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  
  access_scope {
    type = "cluster"
  }
}
