variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "yifat-avishag-roman-status-page"
}

variable "avishag_iam_arn" {
  description = "The IAM User ARN for Avishag to access EKS"
  type        = string
}

variable "db_username" {
  description = "The username for the RDS PostgreSQL database"
  type        = string
  default     = "status_admin" 
}

variable "db_password" {
  description = "The password for the RDS PostgreSQL database"
  type        = string
  sensitive   = true
}
