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

# Import Network resources (VPC, Subnets, EIPs and NAT Gateways)
echo "🌐 Importing Network resources..."

# Import VPC
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=school-m-prod-vpc" --query 'Vpcs[0].VpcId' --output text 2>/dev/null || echo "None")
if [ "$VPC_ID" != "None" ] && [ "$VPC_ID" != "null" ] && [ "$VPC_ID" != "" ]; then
    import_resource "VPC" "aws_vpc.main" "$VPC_ID"
else
    echo "⚠️  VPC school-m-prod-vpc not found"
fi

# Import Internet Gateway
IGW_ID=$(aws ec2 describe-internet-gateways --filters "Name=tag:Name,Values=school-m-prod-igw" --query 'InternetGateways[0].InternetGatewayId' --output text 2>/dev/null || echo "None")
if [ "$IGW_ID" != "None" ] && [ "$IGW_ID" != "null" ] && [ "$IGW_ID" != "" ]; then
    import_resource "Internet Gateway" "aws_internet_gateway.main" "$IGW_ID"
else
    echo "⚠️  Internet Gateway school-m-prod-igw not found"
fi

# Import Route Tables
PUBLIC_RT_ID=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=school-m-prod-public-rt" --query 'RouteTables[0].RouteTableId' --output text 2>/dev/null || echo "None")
if [ "$PUBLIC_RT_ID" != "None" ] && [ "$PUBLIC_RT_ID" != "null" ] && [ "$PUBLIC_RT_ID" != "" ]; then
    import_resource "Route Table" "aws_route_table.public" "$PUBLIC_RT_ID"
else
    echo "⚠️  Public route table school-m-prod-public-rt not found"
fi

# Get existing EIP allocation IDs
echo "Getting existing EIP allocation IDs..."
EIP_ALLOCS=$(aws ec2 describe-addresses --filters "Name=tag:Name,Values=school-m-prod-nat-eip-*" --query 'Addresses[].AllocationId' --output text 2>/dev/null || echo "")
if [ -n "$EIP_ALLOCS" ]; then
    EIP_ARRAY=($EIP_ALLOCS)
    for i in "${!EIP_ARRAY[@]}"; do
        import_resource "EIP" "aws_eip.nat[$i]" "${EIP_ARRAY[$i]}"
    done
else
    echo "⚠️  No existing EIPs found with school-m-prod-nat-eip pattern"
fi

# Get existing NAT Gateway IDs
echo "Getting existing NAT Gateway IDs..."
NAT_GW_IDS=$(aws ec2 describe-nat-gateways --filter "Name=tag:Name,Values=school-m-prod-nat-gw-*" --query 'NatGateways[].NatGatewayId' --output text 2>/dev/null || echo "")
if [ -n "$NAT_GW_IDS" ]; then
    NAT_ARRAY=($NAT_GW_IDS)
    for i in "${!NAT_ARRAY[@]}"; do
        import_resource "NAT Gateway" "aws_nat_gateway.main[$i]" "${NAT_ARRAY[$i]}"
    done
else
    echo "⚠️  No existing NAT Gateways found with school-m-prod-nat-gw pattern"
fi

# Import ALB and target groups (get ARNs dynamically)
echo "🔗 Importing Load Balancer resources..."

# Import Security Groups first
echo "🛡️  Importing Security Groups..."

# Get ALB Security Group ID
ALB_SG_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=school-m-prod-alb-*" --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null || echo "None")
if [ "$ALB_SG_ID" != "None" ] && [ "$ALB_SG_ID" != "null" ] && [ "$ALB_SG_ID" != "" ]; then
    import_resource "Security Group" "aws_security_group.alb" "$ALB_SG_ID"
else
    echo "⚠️  ALB security group not found"
fi

# Get ECS Tasks Security Group ID
ECS_SG_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=school-m-prod-ecs-tasks-*" --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null || echo "None")
if [ "$ECS_SG_ID" != "None" ] && [ "$ECS_SG_ID" != "null" ] && [ "$ECS_SG_ID" != "" ]; then
    import_resource "Security Group" "aws_security_group.ecs_tasks" "$ECS_SG_ID"
else
    echo "⚠️  ECS tasks security group not found"
fi

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
