output "alb_dns_name" {
  description = "DNS name of the application load balancer"
  value       = module.alb.lb_dns_name
}

output "db_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = module.database.db_endpoint
}

output "ecr_backend_url" {
  value = module.ecr.backend_repo_url
}

output "ecr_frontend_url" {
  value = module.ecr.frontend_repo_url
}
