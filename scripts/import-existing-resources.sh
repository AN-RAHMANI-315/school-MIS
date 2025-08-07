#!/bin/bash

# Import existing AWS resources into Terraform state
# This script helps resolve "already exists" errors

set -e

echo "🔧 Importing existing AWS resources into Terraform state..."

# Get current directory
TERRAFORM_DIR="/Users/abdulnaseebrahmani/Downloads/School-MIS/terraform"
cd "$TERRAFORM_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if terraform is initialized
if [ ! -d ".terraform" ]; then
    print_status "Initializing Terraform..."
    terraform init
fi

print_status "Importing existing AWS resources..."

# Import IAM roles if they exist
print_status "Checking IAM roles..."

# ECS Task Execution Role
if aws iam get-role --role-name "school-m-prod-ecs-task-execution-role" >/dev/null 2>&1; then
    print_warning "Importing existing ECS task execution role..."
    terraform import aws_iam_role.ecs_task_execution_role "school-m-prod-ecs-task-execution-role" || true
else
    print_status "ECS task execution role doesn't exist, will be created"
fi

# ECS Task Role
if aws iam get-role --role-name "school-m-prod-ecs-task-role" >/dev/null 2>&1; then
    print_warning "Importing existing ECS task role..."
    terraform import aws_iam_role.ecs_task_role "school-m-prod-ecs-task-role" || true
else
    print_status "ECS task role doesn't exist, will be created"
fi

# Auto Scaling Role
if aws iam get-role --role-name "school-m-prod-ecs-auto-scaling-role" >/dev/null 2>&1; then
    print_warning "Importing existing auto scaling role..."
    terraform import 'aws_iam_role.ecs_auto_scaling_role[0]' "school-m-prod-ecs-auto-scaling-role" || true
else
    print_status "Auto scaling role doesn't exist, will be created"
fi

# VPC Flow Log Role
if aws iam get-role --role-name "school-m-prod-vpc-flow-log-role" >/dev/null 2>&1; then
    print_warning "Importing existing VPC flow log role..."
    terraform import aws_iam_role.flow_log "school-m-prod-vpc-flow-log-role" || true
else
    print_status "VPC flow log role doesn't exist, will be created"
fi

# Import Secrets Manager secrets
print_status "Checking Secrets Manager secrets..."

# MongoDB URL secret
if aws secretsmanager describe-secret --secret-id "school-m-prod-mongo-url" >/dev/null 2>&1; then
    print_warning "Importing existing MongoDB URL secret..."
    terraform import aws_secretsmanager_secret.mongo_url "school-m-prod-mongo-url" || true
else
    print_status "MongoDB URL secret doesn't exist, will be created"
fi

# Database name secret
if aws secretsmanager describe-secret --secret-id "school-m-prod-db-name" >/dev/null 2>&1; then
    print_warning "Importing existing database name secret..."
    terraform import aws_secretsmanager_secret.db_name "school-m-prod-db-name" || true
else
    print_status "Database name secret doesn't exist, will be created"
fi

# Import ECR repositories
print_status "Checking ECR repositories..."

# Backend repository
if aws ecr describe-repositories --repository-names "school-m-prod-backend" >/dev/null 2>&1; then
    print_warning "Importing existing backend ECR repository..."
    terraform import aws_ecr_repository.backend "school-m-prod-backend" || true
else
    print_status "Backend ECR repository doesn't exist, will be created"
fi

# Frontend repository
if aws ecr describe-repositories --repository-names "school-m-prod-frontend" >/dev/null 2>&1; then
    print_warning "Importing existing frontend ECR repository..."
    terraform import aws_ecr_repository.frontend "school-m-prod-frontend" || true
else
    print_status "Frontend ECR repository doesn't exist, will be created"
fi

# Import CloudWatch log groups
print_status "Checking CloudWatch log groups..."

LOG_GROUPS=(
    "/aws/ecs/cluster/school-m-prod:aws_cloudwatch_log_group.ecs_cluster"
    "/aws/ecs/school-m-prod/backend:aws_cloudwatch_log_group.backend"
    "/aws/ecs/school-m-prod/frontend:aws_cloudwatch_log_group.frontend"
    "/aws/vpc/flowlogs/school-m-prod:aws_cloudwatch_log_group.vpc_flow_logs"
)

for log_group in "${LOG_GROUPS[@]}"; do
    IFS=':' read -r log_name terraform_resource <<< "$log_group"
    if aws logs describe-log-groups --log-group-name-prefix "$log_name" --query 'logGroups[?logGroupName==`'$log_name'`]' --output text | grep -q "$log_name"; then
        print_warning "Importing existing log group: $log_name"
        terraform import "$terraform_resource" "$log_name" || true
    else
        print_status "Log group $log_name doesn't exist, will be created"
    fi
done

# Import Load Balancer if it exists
print_status "Checking Application Load Balancer..."

ALB_ARN=$(aws elbv2 describe-load-balancers --names "school-m-prod-alb" --query 'LoadBalancers[0].LoadBalancerArn' --output text 2>/dev/null || echo "None")
if [ "$ALB_ARN" != "None" ] && [ "$ALB_ARN" != "null" ]; then
    print_warning "Importing existing ALB..."
    terraform import aws_lb.main "$ALB_ARN" || true
else
    print_status "ALB doesn't exist, will be created"
fi

# Import Target Groups
print_status "Checking Target Groups..."

BACKEND_TG_ARN=$(aws elbv2 describe-target-groups --names "school-m-prod-backend-tg" --query 'TargetGroups[0].TargetGroupArn' --output text 2>/dev/null || echo "None")
if [ "$BACKEND_TG_ARN" != "None" ] && [ "$BACKEND_TG_ARN" != "null" ]; then
    print_warning "Importing existing backend target group..."
    terraform import aws_lb_target_group.backend "$BACKEND_TG_ARN" || true
else
    print_status "Backend target group doesn't exist, will be created"
fi

FRONTEND_TG_ARN=$(aws elbv2 describe-target-groups --names "school-m-prod-frontend-tg" --query 'TargetGroups[0].TargetGroupArn' --output text 2>/dev/null || echo "None")
if [ "$FRONTEND_TG_ARN" != "None" ] && [ "$FRONTEND_TG_ARN" != "null" ]; then
    print_warning "Importing existing frontend target group..."
    terraform import aws_lb_target_group.frontend "$FRONTEND_TG_ARN" || true
else
    print_status "Frontend target group doesn't exist, will be created"
fi

print_success "Import process completed!"
print_status "Running terraform plan to check the current state..."

# Run terraform plan to see what needs to be done
terraform plan -no-color

print_success "Import script finished. You can now run 'terraform apply' to update the infrastructure."
