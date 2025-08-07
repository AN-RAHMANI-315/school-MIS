#!/bin/bash

# This script should be run in the CI/CD pipeline where AWS credentials are available
# Import existing AWS resources to avoid "already exists" errors

set -e

echo "🔧 Importing existing AWS resources into Terraform state..."

# Change to terraform directory
cd "$(dirname "$0")/../terraform"
echo "Working directory: $(pwd)"

# Function to safely import resources
import_resource() {
    local resource_type="$1"
    local resource_name="$2"
    local resource_id="$3"
    
    echo "Importing $resource_type: $resource_name"
    if terraform import "$resource_name" "$resource_id" 2>/dev/null; then
        echo "✅ Successfully imported $resource_name"
    else
        echo "⚠️  Failed to import $resource_name (may already be imported or not exist)"
    fi
}

# Import IAM roles
echo "📋 Importing IAM roles..."
import_resource "IAM Role" "aws_iam_role.ecs_task_execution_role" "school-m-prod-ecs-task-execution-role"
import_resource "IAM Role" "aws_iam_role.ecs_task_role" "school-m-prod-ecs-task-role"
import_resource "IAM Role" "aws_iam_role.ecs_auto_scaling_role[0]" "school-m-prod-ecs-auto-scaling-role"
import_resource "IAM Role" "aws_iam_role.flow_log" "school-m-prod-vpc-flow-log-role"

# Import Secrets Manager secrets
echo "🔐 Importing Secrets Manager secrets..."
import_resource "Secret" "aws_secretsmanager_secret.mongo_url" "school-m-prod-mongo-url"
import_resource "Secret" "aws_secretsmanager_secret.db_name" "school-m-prod-db-name"

# Import ECR repositories
echo "📦 Importing ECR repositories..."
import_resource "ECR Repository" "aws_ecr_repository.backend" "school-m-prod-backend"
import_resource "ECR Repository" "aws_ecr_repository.frontend" "school-m-prod-frontend"

# Import CloudWatch log groups
echo "📊 Importing CloudWatch log groups..."
import_resource "Log Group" "aws_cloudwatch_log_group.ecs_cluster" "/aws/ecs/cluster/school-m-prod"
import_resource "Log Group" "aws_cloudwatch_log_group.backend" "/aws/ecs/school-m-prod/backend"
import_resource "Log Group" "aws_cloudwatch_log_group.frontend" "/aws/ecs/school-m-prod/frontend"
import_resource "Log Group" "aws_cloudwatch_log_group.vpc_flow_logs" "/aws/vpc/flowlogs/school-m-prod"

# Import ALB and target groups (get ARNs dynamically)
echo "🔗 Importing Load Balancer resources..."

# Get ALB ARN
echo "Getting ALB ARN for school-m-prod-alb..."
ALB_ARN=$(aws elbv2 describe-load-balancers --names "school-m-prod-alb" --query 'LoadBalancers[0].LoadBalancerArn' --output text 2>/dev/null || echo "None")
if [ "$ALB_ARN" != "None" ] && [ "$ALB_ARN" != "null" ] && [ "$ALB_ARN" != "" ]; then
    import_resource "ALB" "aws_lb.main" "$ALB_ARN"
else
    echo "⚠️  ALB school-m-prod-alb not found"
fi

# Get Target Group ARNs
echo "Getting Target Group ARNs..."
BACKEND_TG_ARN=$(aws elbv2 describe-target-groups --names "school-m-prod-backend-tg" --query 'TargetGroups[0].TargetGroupArn' --output text 2>/dev/null || echo "None")
if [ "$BACKEND_TG_ARN" != "None" ] && [ "$BACKEND_TG_ARN" != "null" ] && [ "$BACKEND_TG_ARN" != "" ]; then
    import_resource "Target Group" "aws_lb_target_group.backend" "$BACKEND_TG_ARN"
else
    echo "⚠️  Backend target group school-m-prod-backend-tg not found"
fi

FRONTEND_TG_ARN=$(aws elbv2 describe-target-groups --names "school-m-prod-frontend-tg" --query 'TargetGroups[0].TargetGroupArn' --output text 2>/dev/null || echo "None")
if [ "$FRONTEND_TG_ARN" != "None" ] && [ "$FRONTEND_TG_ARN" != "null" ] && [ "$FRONTEND_TG_ARN" != "" ]; then
    import_resource "Target Group" "aws_lb_target_group.frontend" "$FRONTEND_TG_ARN"
else
    echo "⚠️  Frontend target group school-m-prod-frontend-tg not found"
fi

echo "✅ Import process completed!"
echo ""
echo "📋 Running terraform plan to check current state..."
terraform plan -no-color || echo "⚠️  Plan failed, but continuing with apply..."
