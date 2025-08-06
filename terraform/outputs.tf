# Output values
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "private_subnets" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnets" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "security_group_ids" {
  description = "Security group IDs"
  value = {
    alb       = aws_security_group.alb.id
    ecs_tasks = aws_security_group.ecs_tasks.id
  }
}

output "load_balancer_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "load_balancer_zone_id" {
  description = "The canonical hosted zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.main.name
}

output "ecr_repository_urls" {
  description = "URLs of the ECR repositories"
  value = {
    backend  = aws_ecr_repository.backend.repository_url
    frontend = aws_ecr_repository.frontend.repository_url
  }
}

output "cloudwatch_log_groups" {
  description = "Names of CloudWatch log groups"
  value = {
    backend  = aws_cloudwatch_log_group.backend.name
    frontend = aws_cloudwatch_log_group.frontend.name
  }
}

output "secrets_manager_arns" {
  description = "ARNs of Secrets Manager secrets"
  value = {
    mongo_url = aws_secretsmanager_secret.mongo_url.arn
    db_name   = aws_secretsmanager_secret.db_name.arn
  }
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = aws_sns_topic.alerts.arn
}

output "dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

output "application_url" {
  description = "URL of the application"
  value       = var.certificate_arn != "" ? "https://${aws_lb.main.dns_name}" : "http://${aws_lb.main.dns_name}"
}

# output "backup_s3_bucket" {
#   description = "S3 bucket name for backups"
#   value       = var.enable_backup ? aws_s3_bucket.backup[0].bucket : null
# }

output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    environment           = var.environment
    region               = var.aws_region
    vpc_cidr             = var.vpc_cidr
    availability_zones   = local.azs
    container_insights   = var.container_insights
    auto_scaling_enabled = var.enable_auto_scaling
    # backup_enabled       = var.enable_backup
    ssl_enabled         = var.certificate_arn != ""
  }
}
