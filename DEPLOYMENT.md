# 🏫 School Management Information System - DevOps & Deployment Guide

## 🚀 Complete CI/CD Pipeline & Production Deployment

This project implements a comprehensive DevOps pipeline with modern best practices for deploying a School Management Information System to AWS using containerization, infrastructure as code, and automated CI/CD.

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [CI/CD Pipeline](#cicd-pipeline)
- [Security Features](#security-features)
- [Infrastructure](#infrastructure)
- [Quick Start](#quick-start)
- [Deployment Guide](#deployment-guide)
- [Monitoring & Logging](#monitoring--logging)
- [Troubleshooting](#troubleshooting)

## 🏗️ Architecture Overview

### Technology Stack

**Frontend:**
- React 19 with TypeScript support
- Tailwind CSS for styling
- Nginx for production serving
- Multi-language support (EN/DE)

**Backend:**
- FastAPI (Python 3.11)
- MongoDB with Motor (async driver)
- Pydantic for data validation
- CORS middleware for cross-origin requests

**DevOps & Infrastructure:**
- Docker - Containerization
- GitHub Actions - CI/CD pipeline
- Terraform - Infrastructure as Code
- AWS ECS Fargate - Container orchestration
- AWS ECR - Container registry
- AWS ALB - Load balancing
- AWS CloudWatch - Logging and monitoring

**Security:**
- Multi-stage Docker builds
- Non-root container users
- VPC with private subnets
- Security groups with minimal access
- Secrets management with AWS Secrets Manager
- Vulnerability scanning with Trivy

## 🔄 CI/CD Pipeline

### Pipeline Stages

#### 1. Test and Build 🧪
- **Python Tests**: Unit tests with pytest and coverage reporting
- **Frontend Tests**: React component tests with Jest
- **Code Quality**: Linting and formatting checks
- **Build Artifacts**: React production build upload

#### 2. Security Scan 🔒
- **Dependency Scanning**: npm audit for Node.js dependencies
- **Python Security**: Safety and Bandit security checks
- **Code Vulnerability**: Trivy filesystem scanning
- **Report Upload**: Security reports to GitHub Security tab

#### 3. Docker Build & Push 🐳
- **Multi-stage Builds**: Optimized container images
- **ECR Push**: Automated push to Amazon ECR
- **Image Scanning**: Container vulnerability scanning
- **Layer Caching**: GitHub Actions cache optimization

#### 4. Infrastructure Deploy 🏗️
- **Terraform Validation**: Configuration validation
- **Infrastructure Planning**: Change preview
- **AWS Deployment**: Automated infrastructure provisioning

#### 5. Application Deploy 🚀
- **ECS Task Update**: Rolling deployment to ECS Fargate
- **Health Checks**: Application health verification
- **Service Stability**: Wait for deployment completion

#### 6. Notification 📢
- **Slack Integration**: Deployment status notifications
- **Application URL**: Live application endpoint
- **Monitoring Links**: CloudWatch and ECS console links

## 🔐 Security Features

### Infrastructure Security
- **VPC Isolation**: Private subnets for ECS tasks
- **Security Groups**: Minimal required access rules
- **IAM Roles**: Least privilege principle
- **HTTPS Support**: SSL/TLS via Application Load Balancer
- **VPC Flow Logs**: Network traffic monitoring

### Container Security
- **Multi-stage Builds**: Minimal attack surface
- **Non-root Users**: Containers run as unprivileged users
- **Image Scanning**: Automated vulnerability detection
- **Base Image Updates**: Regular security updates

### CI/CD Security
- **Secrets Management**: GitHub Secrets for sensitive data
- **Branch Protection**: Required reviews and status checks
- **Supply Chain Security**: Dependency vulnerability audits
- **SARIF Reports**: Security findings in GitHub Security tab

## 🏗️ Infrastructure

### AWS Resources Created

#### Networking
- VPC with public/private subnets across 2 AZs
- Internet Gateway and NAT Gateways
- Route tables and security groups
- VPC Flow Logs for monitoring

#### Container Platform
- ECS Fargate cluster with Container Insights
- Application Load Balancer with SSL termination
- Target groups for backend/frontend services
- Auto Scaling policies for high availability

#### Storage & Secrets
- ECR repositories for container images
- S3 buckets for ALB logs and backups
- Secrets Manager for sensitive configuration
- CloudWatch Log Groups with retention policies

#### Monitoring & Alerting
- CloudWatch Dashboard with key metrics
- CloudWatch Alarms for CPU, memory, response time
- SNS topics for alert notifications
- Custom application metrics

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose
- Node.js 18+ and Python 3.11+
- AWS CLI (for production deployment)
- Terraform (for infrastructure management)

### Local Development

1. **Clone and Setup**
   ```bash
   git clone <repository-url>
   cd School-MIS
   ./deploy.sh setup
   ```

2. **Start Local Environment**
   ```bash
   ./deploy.sh start
   ```

3. **Access Applications**
   - Frontend: http://localhost
   - Backend: http://localhost:8000
   - API Documentation: http://localhost:8000/docs

4. **Run Tests**
   ```bash
   ./deploy.sh test
   ```

5. **Stop Environment**
   ```bash
   ./deploy.sh stop
   ```

## 🚢 Deployment Guide

### GitHub Actions Setup

1. **Repository Secrets**
   Configure these secrets in your GitHub repository:
   ```
   AWS_ACCESS_KEY_ID=your_access_key
   AWS_SECRET_ACCESS_KEY=your_secret_key
   SLACK_WEBHOOK_URL=your_slack_webhook (optional)
   ```

2. **Branch Protection**
   - Enable branch protection for `main` branch
   - Require status checks to pass
   - Require pull request reviews

### AWS Infrastructure Setup

1. **S3 Backend for Terraform State**
   ```bash
   aws s3 mb s3://school-mis-terraform-state
   aws dynamodb create-table \
     --table-name school-mis-terraform-locks \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
   ```

2. **Deploy Infrastructure**
### 4. Deploy Infrastructure with Terraform

#### Option A: Automated Setup (Recommended)
```bash
# Setup Terraform backend (S3 + DynamoDB)
./scripts/setup-terraform-backend.sh

# Deploy infrastructure
cd terraform/
terraform init
terraform plan
terraform apply
```

#### Option B: Manual Setup
See [Terraform Backend Setup Guide](docs/TERRAFORM_BACKEND_SETUP.md) for detailed instructions.

#### Option C: Local State (Development)
```bash
cd terraform/
cp main-local.tf main.tf
terraform init
terraform plan
terraform apply
```3. **Update Task Definition**
   Update `.aws/task-definition.json` with your AWS account ID and resource ARNs.

### Production Deployment

1. **Automatic Deployment**
   - Push to `main` branch triggers full deployment pipeline
   - Pull requests trigger tests and security scans only

2. **Manual Deployment**
   ```bash
   ./deploy.sh deploy
   ```

## 📊 Monitoring & Logging

### CloudWatch Dashboard
- ECS service CPU and memory utilization
- Application Load Balancer metrics
- Request count, response times, error rates
- Application logs from both frontend and backend

### Alerts and Notifications
- High CPU utilization (>80%)
- High memory utilization (>85%)
- Slow response times (>2 seconds)
- HTTP 5XX errors (>10 in 5 minutes)
- Application error logs

### Log Aggregation
- Centralized logging in CloudWatch
- Structured JSON logs with correlation IDs
- Log retention policies (7 days by default)
- Real-time log streaming and search

### Health Checks
- Container health checks via Docker HEALTHCHECK
- Load balancer health checks via `/health` endpoints
- ECS service health monitoring
- Auto-recovery for failed containers

## 🔧 Configuration

### Environment Variables

**Backend (.env)**
```bash
MONGO_URL=mongodb://user:pass@host:port/db
DB_NAME=school_mis
ENVIRONMENT=production
LOG_LEVEL=INFO
```

**Frontend**
```bash
REACT_APP_BACKEND_URL=https://your-alb-dns-name.amazonaws.com
```

### Terraform Variables

**terraform/terraform.tfvars**
```hcl
aws_region = "us-east-1"
environment = "production"
project_name = "school-mis"
certificate_arn = "arn:aws:acm:region:account:certificate/cert-id"
domain_name = "school-mis.yourdomain.com"
```

## 🛠️ Troubleshooting

### Common Issues

#### Container Health Check Failures
```bash
# Check container logs
docker logs school-mis-backend
docker logs school-mis-frontend

# Verify health endpoints
curl http://localhost:8000/api/health
curl http://localhost/health
```

#### Database Connection Issues
```bash
# Test MongoDB connection
docker exec -it school-mis-mongo mongo school_mis

# Check environment variables
docker exec school-mis-backend env | grep MONGO
```

#### Load Balancer 502 Errors
- Check target group health in AWS Console
- Verify security group rules allow traffic
- Check ECS service events for deployment issues

#### CI/CD Pipeline Failures
- Review GitHub Actions logs
- Verify AWS credentials and permissions
- Check Terraform plan for resource conflicts

### Useful Commands

```bash
# View container logs
docker-compose logs -f backend
docker-compose logs -f frontend

# Scale services locally
docker-compose up --scale backend=2

# Connect to running container
docker exec -it school-mis-backend bash

# View AWS ECS service logs
aws logs tail /aws/ecs/school-mis-production/backend --follow

# Check ECS service status
aws ecs describe-services --cluster school-mis-cluster --services school-mis-service
```

## 📈 Scaling and Performance

### Auto Scaling Configuration
- CPU-based scaling: Scale out at >70% utilization
- Memory-based scaling: Scale out at >80% utilization
- Min capacity: 1 container
- Max capacity: 10 containers

### Performance Optimization
- Multi-stage Docker builds for smaller images
- CDN integration for static assets
- Database connection pooling
- Gzip compression via nginx
- Browser caching headers

### Cost Optimization
- Fargate Spot instances for dev environments
- ECR lifecycle policies for image cleanup
- CloudWatch log retention policies
- S3 lifecycle policies for backups

## 🤝 Contributing

1. Create a feature branch from `develop`
2. Implement changes with tests
3. Ensure all CI checks pass
4. Create pull request to `develop`
5. After review, merge to `main` for deployment

## 📝 License

This project is licensed under the MIT License. See LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the GitHub repository
- Check the troubleshooting section
- Review CloudWatch logs and metrics
- Contact the development team via Slack

---

**🎉 Congratulations! Your School MIS is now ready for production deployment with enterprise-grade DevOps practices.**
