output "eks_cluster_name" {
  description = "The name of the EKS cluster for your teammate"
  value       = aws_eks_cluster.main.name
}

output "rds_endpoint" {
  description = "The PostgreSQL connection URL for the Django app"
  value       = aws_db_instance.postgres.endpoint
}
