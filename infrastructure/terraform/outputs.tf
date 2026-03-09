output "eks_cluster_name" {
  description = "The name of the EKS cluster for your teammate"
  value       = module.eks.cluster_name
}

output "rds_endpoint" {
  description = "The PostgreSQL connection URL for the Django app"
  value       = module.db.db_instance_endpoint
}
