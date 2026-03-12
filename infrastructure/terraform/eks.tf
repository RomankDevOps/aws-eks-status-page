module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                = "${var.project_name}-cluster"
  cluster_version             = "1.29"
  create_cloudwatch_log_group = false

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.public_subnets
  cluster_endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true
  authentication_mode                      = "API_AND_CONFIG_MAP"

  iam_role_use_name_prefix = false
  iam_role_name            = "yar-eks-cluster-role"

  access_entries = {
    avishag_admin = {
      principal_arn = var.avishag_iam_arn
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  eks_managed_node_groups = {
    on_demand = {
      name = "on-demand"

      create_iam_role = false
      iam_role_arn    = "arn:aws:iam::992382545251:role/EksLabRole"

      instance_types = ["t3.medium"]
      min_size       = 2
      max_size       = 2
      desired_size   = 2
      capacity_type  = "ON_DEMAND"

      associate_public_ip_address = true

      tags = {
        Environment = "dev"
        Project     = "status-page"
        Owner       = "student"
      }
    }
  }
}
