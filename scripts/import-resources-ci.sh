#!/bin/bash

# This script should be run in the CI/CD pipeline where AWS credentials are available
# Import existing AWS resources to avoid "already exists" errors

set -e

echo "🔧 Importing existing AWS resources into Terraform state..."

# Import IAM roles
echo "Importing IAM roles..."
terraform import aws_iam_role.ecs_task_execution_role "school-m-prod-ecs-task-execution-role" || echo "Role import failed or already imported"
terraform import aws_iam_role.ecs_task_role "school-m-prod-ecs-task-role" || echo "Role import failed or already imported"
terraform import 'aws_iam_role.ecs_auto_scaling_role[0]' "school-m-prod-ecs-auto-scaling-role" || echo "Role import failed or already imported"
terraform import aws_iam_role.flow_log "school-m-prod-vpc-flow-log-role" || echo "Role import failed or already imported"

# Import Secrets Manager secrets
echo "Importing Secrets Manager secrets..."
terraform import aws_secretsmanager_secret.mongo_url "school-m-prod-mongo-url" || echo "Secret import failed or already imported"
terraform import aws_secretsmanager_secret.db_name "school-m-prod-db-name" || echo "Secret import failed or already imported"

# Import ECR repositories
echo "Importing ECR repositories..."
terraform import aws_ecr_repository.backend "school-m-prod-backend" || echo "ECR import failed or already imported"
terraform import aws_ecr_repository.frontend "school-m-prod-frontend" || echo "ECR import failed or already imported"

# Import CloudWatch log groups
echo "Importing CloudWatch log groups..."
terraform import aws_cloudwatch_log_group.ecs_cluster "/aws/ecs/cluster/school-m-prod" || echo "Log group import failed or already imported"
terraform import aws_cloudwatch_log_group.backend "/aws/ecs/school-m-prod/backend" || echo "Log group import failed or already imported"
terraform import aws_cloudwatch_log_group.frontend "/aws/ecs/school-m-prod/frontend" || echo "Log group import failed or already imported"
terraform import aws_cloudwatch_log_group.vpc_flow_logs "/aws/vpc/flowlogs/school-m-prod" || echo "Log group import failed or already imported"

# Import ALB and target groups (get ARNs dynamically)
echo "Importing Load Balancer resources..."

# Get ALB ARN
ALB_ARN=$(aws elbv2 describe-load-balancers --names "school-m-prod-alb" --query 'LoadBalancers[0].LoadBalancerArn' --output text 2>/dev/null || echo "None")
if [ "$ALB_ARN" != "None" ] && [ "$ALB_ARN" != "null" ]; then
    terraform import aws_lb.main "$ALB_ARN" || echo "ALB import failed or already imported"
fi

# Get Target Group ARNs
BACKEND_TG_ARN=$(aws elbv2 describe-target-groups --names "school-m-prod-backend-tg" --query 'TargetGroups[0].TargetGroupArn' --output text 2>/dev/null || echo "None")
if [ "$BACKEND_TG_ARN" != "None" ] && [ "$BACKEND_TG_ARN" != "null" ]; then
    terraform import aws_lb_target_group.backend "$BACKEND_TG_ARN" || echo "Backend TG import failed or already imported"
fi

FRONTEND_TG_ARN=$(aws elbv2 describe-target-groups --names "school-m-prod-frontend-tg" --query 'TargetGroups[0].TargetGroupArn' --output text 2>/dev/null || echo "None")
if [ "$FRONTEND_TG_ARN" != "None" ] && [ "$FRONTEND_TG_ARN" != "null" ]; then
    terraform import aws_lb_target_group.frontend "$FRONTEND_TG_ARN" || echo "Frontend TG import failed or already imported"
fi

echo "✅ Import process completed. Running terraform plan..."
terraform plan -no-color
