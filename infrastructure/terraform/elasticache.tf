# Call the local ElastiCache module
module "redis" {
  source             = "./modules/elasticache"
  project_name       = var.project_name
  vpc_id             = aws_vpc.main.id
  vpc_cidr           = aws_vpc.main.cidr_block
  private_subnet_ids = [aws_subnet.private_1a.id, aws_subnet.private_1b.id]
}

# Output the Redis URL for your Kubernetes teammate
output "redis_endpoint" {
  description = "The ElastiCache Redis connection URL for the Django app"
  value       = module.redis.redis_endpoint
}
