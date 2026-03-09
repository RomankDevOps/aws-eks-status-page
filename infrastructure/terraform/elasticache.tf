# Call the local ElastiCache module
module "redis" {
  source             = "./modules/elasticache"
  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = module.vpc.vpc_cidr_block
  private_subnet_ids = module.vpc.private_subnets
}

# Output the Redis URL for your Kubernetes teammate
output "redis_endpoint" {
  description = "The ElastiCache Redis connection URL for the Django app"
  value       = module.redis.redis_endpoint
}
