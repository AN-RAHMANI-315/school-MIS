# School MIS - Production Deployment Guide

## Overview
This guide provides step-by-step instructions for deploying the School MIS application to AWS using our CI/CD pipeline.

## Prerequisites

### 1. AWS Setup
- AWS Account with appropriate permissions
- AWS CLI configured locally (for manual deployment)
- GitHub repository secrets configured

### 2. Required GitHub Secrets
Add the following secrets to your GitHub repository:

```
AWS_ACCESS_KEY_ID: Your AWS access key
AWS_SECRET_ACCESS_KEY: Your AWS secret key
SLACK_WEBHOOK_URL: (Optional) Slack webhook for notifications
```

To add secrets:
1. Go to your GitHub repository
2. Navigate to Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add each secret with the corresponding value

## Deployment Options

### Option 1: Automatic Deployment (Recommended)

The CI/CD pipeline automatically deploys when you push to the `main` branch:

```bash
git add .
git commit -m "Deploy to production"
git push origin main
```

The pipeline will:
1. 🧪 Run tests
2. 🏗️ Build Docker images
3. 🔒 Perform security scans
4. 📦 Push images to ECR
5. 🏗️ Create/update AWS infrastructure
6. 🚀 Deploy to ECS

### Option 2: Manual Deployment

For manual deployment or troubleshooting:

#### Step 1: Setup Terraform Backend
```bash
# Navigate to the project directory
cd /path/to/School-MIS

# Run the backend setup script
cd scripts
chmod +x setup-terraform-backend.sh
./setup-terraform-backend.sh
```

#### Step 2: Initialize Terraform with Backend
```bash
cd terraform

# Initialize with S3 backend
terraform init -backend-config=backend.hcl

# Or initialize with local state (for testing)
terraform init
```

#### Step 3: Deploy Infrastructure
```bash
# Review the deployment plan
terraform plan

# Apply the infrastructure changes
terraform apply
```

#### Step 4: Build and Push Docker Images
```bash
# Build images
docker-compose build

# Tag and push to ECR (replace with your account ID and region)
docker tag school-mis-backend:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/school-mis-backend:latest
docker tag school-mis-frontend:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/school-mis-frontend:latest

# Push images
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/school-mis-backend:latest
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/school-mis-frontend:latest
```

## Infrastructure Components

### AWS Resources Created
- **VPC**: Custom VPC with public/private subnets
- **ECS Cluster**: Fargate cluster for container orchestration
- **ALB**: Application Load Balancer for traffic distribution
- **ECR**: Container registry for Docker images
- **CloudWatch**: Logging and monitoring
- **Security Groups**: Network security rules
- **IAM Roles**: Service permissions

### Backend Configuration Options

#### 1. S3 Backend (Production)
- **File**: `terraform/backend.hcl`
- **Purpose**: Shared state storage with locking
- **Setup**: Run `scripts/setup-terraform-backend.sh` first
- **Usage**: `terraform init -backend-config=backend.hcl`

#### 2. Local Backend (Development)
- **Purpose**: Local state storage for development/testing
- **Usage**: `terraform init` (default)

## Configuration Files

### Environment Variables
Create `.env` file in the root directory:
```env
# Application Configuration
NODE_ENV=production
REACT_APP_API_URL=http://your-alb-dns-name

# Database Configuration
MONGODB_URI=mongodb://localhost:27017/school_mis

# AWS Configuration (for local development)
AWS_REGION=us-east-1
AWS_ACCOUNT_ID=123456789012
```

### Terraform Variables
Customize deployment in `terraform/terraform.tfvars`:
```hcl
# Project Configuration
project_name = "school-mis"
environment  = "production"
aws_region   = "us-east-1"

# Container Configuration
backend_image  = "your-account.dkr.ecr.us-east-1.amazonaws.com/school-mis-backend"
frontend_image = "your-account.dkr.ecr.us-east-1.amazonaws.com/school-mis-frontend"

# Infrastructure Sizing
backend_cpu    = 256
backend_memory = 512
frontend_cpu   = 256
frontend_memory = 512
```

## Monitoring and Troubleshooting

### Application Logs
```bash
# View ECS service logs
aws logs tail /ecs/school-mis-backend --follow
aws logs tail /ecs/school-mis-frontend --follow
```

### Infrastructure Status
```bash
# Check Terraform state
terraform show

# View infrastructure outputs
terraform output
```

### Common Issues

#### 1. ECR Repository Not Found
**Error**: Repository does not exist
**Solution**: Run the CI/CD pipeline or create ECR repositories manually

#### 2. S3 Backend Access Denied
**Error**: Access denied for S3 bucket
**Solution**: Verify AWS credentials and run `setup-terraform-backend.sh`

#### 3. Container Image Pull Errors
**Error**: Unable to pull image
**Solution**: Ensure images are pushed to ECR and IAM roles have ECR permissions

## Scaling and Updates

### Scaling Services
Update task counts in `terraform/ecs.tf`:
```hcl
resource "aws_ecs_service" "backend" {
  desired_count = 2  # Increase for more backend instances
}
```

### Rolling Updates
The ECS service performs rolling updates automatically when new images are deployed.

### Blue-Green Deployment
For zero-downtime deployments, the ALB target groups support blue-green deployment patterns.

## Security Best Practices

### 1. Network Security
- Private subnets for application containers
- Security groups with minimal required access
- ALB in public subnets only

### 2. Image Security
- Regular security scans in CI/CD pipeline
- Minimal base images (Alpine Linux)
- Non-root container users

### 3. Access Control
- IAM roles with minimal permissions
- Encrypted S3 backend storage
- CloudWatch logs encryption

## Cost Optimization

### 1. Right-sizing
- Monitor CloudWatch metrics
- Adjust CPU/memory allocations
- Use spot instances for development

### 2. Resource Cleanup
```bash
# Destroy infrastructure when not needed
terraform destroy
```

### 3. Image Lifecycle
- ECR lifecycle policies for old images
- Regular cleanup of unused resources

## Support and Maintenance

### Regular Updates
1. Update Docker base images
2. Update Terraform providers
3. Review and update AWS security groups
4. Monitor CloudWatch alerts

### Backup Strategy
- Terraform state is backed up in S3
- Application data should be backed up separately
- Configuration files are version controlled

---

For additional support or questions about the deployment process, please refer to the project documentation or contact the DevOps team.
