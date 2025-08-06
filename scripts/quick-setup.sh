#!/bin/bash

# School MIS - Quick Setup Script
# This script prepares the environment for deployment

set -e

echo "🏫 School MIS - Quick Setup Script"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if we're in the right directory
if [[ ! -f "docker-compose.yml" ]]; then
    print_error "Please run this script from the School-MIS root directory"
    exit 1
fi

print_status "Setting up School MIS deployment environment..."

# Check required tools
print_status "Checking required tools..."

# Check Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi
print_success "Docker is installed"

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi
print_success "Docker Compose is installed"

# Check Terraform
if ! command -v terraform &> /dev/null; then
    print_warning "Terraform is not installed. Install it for AWS deployment."
    print_status "You can download it from: https://www.terraform.io/downloads.html"
else
    print_success "Terraform is installed"
fi

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    print_warning "AWS CLI is not installed. Install it for AWS deployment."
    print_status "You can install it with: pip install awscli"
else
    print_success "AWS CLI is installed"
fi

# Create .env file if it doesn't exist
print_status "Setting up environment configuration..."

if [[ ! -f ".env" ]]; then
    if [[ -f ".env.example" ]]; then
        cp .env.example .env
        print_success "Created .env file from .env.example"
        print_warning "Please review and update the .env file with your configuration"
    else
        cat > .env << EOF
# Application Configuration
NODE_ENV=development
REACT_APP_API_URL=http://localhost:8000

# Database Configuration
MONGODB_URI=mongodb://localhost:27017/school_mis

# AWS Configuration (for deployment)
AWS_REGION=us-east-1
AWS_ACCOUNT_ID=your-account-id

# Optional: Slack notifications
SLACK_WEBHOOK_URL=
EOF
        print_success "Created .env file with default values"
        print_warning "Please update the .env file with your configuration"
    fi
else
    print_success ".env file already exists"
fi

# Make scripts executable
print_status "Making scripts executable..."
find scripts -name "*.sh" -exec chmod +x {} \;
print_success "Scripts are now executable"

# Build local development environment
print_status "Building local development environment..."

if docker-compose build; then
    print_success "Docker images built successfully"
else
    print_error "Failed to build Docker images"
    exit 1
fi

# Test local environment
print_status "Testing local environment..."

# Start services in detached mode
if docker-compose up -d; then
    print_success "Local services started"
    
    # Wait a moment for services to start
    sleep 5
    
    # Check if services are running
    if docker-compose ps | grep -q "Up"; then
        print_success "Services are running successfully"
        
        # Display service URLs
        echo
        print_status "Local development URLs:"
        echo "  🌐 Frontend: http://localhost:3000"
        echo "  🔧 Backend API: http://localhost:8000"
        echo "  📊 API Docs: http://localhost:8000/docs"
        echo "  🗄️  MongoDB: mongodb://localhost:27017"
        
        # Show running containers
        echo
        print_status "Running containers:"
        docker-compose ps
        
    else
        print_warning "Some services may not be running properly"
        print_status "Check logs with: docker-compose logs"
    fi
else
    print_error "Failed to start local services"
fi

echo
print_status "Setup complete! Next steps:"
echo

# Deployment options
echo "📝 For local development:"
echo "   docker-compose up    # Start all services"
echo "   docker-compose down  # Stop all services"
echo "   docker-compose logs  # View logs"
echo

echo "🚀 For AWS deployment:"
echo "   1. Configure AWS credentials: aws configure"
echo "   2. Update .env file with your AWS account ID"
echo "   3. Review terraform/terraform.tfvars"
echo "   4. Run: ./scripts/setup-terraform-backend.sh"
echo "   5. Run: cd terraform && terraform init -backend-config=backend.hcl"
echo "   6. Run: terraform plan && terraform apply"
echo

echo "🔄 For CI/CD deployment:"
echo "   1. Add GitHub secrets (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)"
echo "   2. Push to main branch: git push origin main"
echo

print_success "School MIS setup is ready! 🎉"

# Optional: Open browser
if command -v open &> /dev/null; then
    read -p "Open frontend in browser? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sleep 2
        open http://localhost:3000
    fi
fi
