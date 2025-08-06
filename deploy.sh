#!/bin/bash

# School MIS Deployment Script
# This script handles the initial setup and deployment of the School MIS application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        log_warning "AWS CLI is not installed. Required for production deployment."
    fi
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        log_warning "Terraform is not installed. Required for infrastructure deployment."
    fi
    
    log_success "Prerequisites check completed"
}

# Setup environment
setup_environment() {
    log_info "Setting up environment..."
    
    if [ ! -f .env ]; then
        log_info "Creating .env file from template..."
        cp .env.example .env
        log_warning "Please update .env file with your configuration"
    fi
    
    log_success "Environment setup completed"
}

# Build Docker images
build_images() {
    log_info "Building Docker images..."
    
    # Build backend image
    log_info "Building backend image..."
    docker build -t school-mis-backend:latest ./backend/
    
    # Build frontend image
    log_info "Building frontend image..."
    docker build -t school-mis-frontend:latest ./frontend/
    
    log_success "Docker images built successfully"
}

# Run tests
run_tests() {
    log_info "Running tests..."
    
    # Backend tests
    log_info "Running backend tests..."
    cd backend
    python -m pytest tests/ -v --cov=. --cov-report=term-missing
    cd ..
    
    # Frontend tests
    log_info "Running frontend tests..."
    cd frontend
    npm test -- --coverage --watchAll=false
    cd ..
    
    log_success "All tests passed"
}

# Start local development
start_local() {
    log_info "Starting local development environment..."
    
    docker-compose up -d
    
    log_success "Local environment started"
    log_info "Frontend: http://localhost"
    log_info "Backend: http://localhost:8000"
    log_info "Backend API: http://localhost:8000/api/"
}

# Stop local development
stop_local() {
    log_info "Stopping local development environment..."
    
    docker-compose down
    
    log_success "Local environment stopped"
}

# Deploy to AWS
deploy_aws() {
    log_info "Deploying to AWS..."
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    # Initialize Terraform
    log_info "Initializing Terraform..."
    cd terraform
    terraform init
    
    # Plan infrastructure
    log_info "Planning infrastructure changes..."
    terraform plan
    
    # Apply infrastructure
    log_info "Applying infrastructure changes..."
    terraform apply -auto-approve
    
    cd ..
    
    log_success "AWS deployment completed"
}

# Clean up
cleanup() {
    log_info "Cleaning up..."
    
    # Remove unused Docker images
    docker image prune -f
    
    # Remove dangling images
    docker rmi $(docker images -f "dangling=true" -q) 2>/dev/null || true
    
    log_success "Cleanup completed"
}

# Main script
main() {
    echo "🏫 School Management Information System Deployment Script"
    echo "========================================================"
    
    case "$1" in
        "check")
            check_prerequisites
            ;;
        "setup")
            check_prerequisites
            setup_environment
            ;;
        "build")
            build_images
            ;;
        "test")
            run_tests
            ;;
        "start")
            setup_environment
            build_images
            start_local
            ;;
        "stop")
            stop_local
            ;;
        "deploy")
            check_prerequisites
            setup_environment
            build_images
            run_tests
            deploy_aws
            ;;
        "clean")
            cleanup
            ;;
        *)
            echo "Usage: $0 {check|setup|build|test|start|stop|deploy|clean}"
            echo ""
            echo "Commands:"
            echo "  check   - Check prerequisites"
            echo "  setup   - Setup environment files"
            echo "  build   - Build Docker images"
            echo "  test    - Run tests"
            echo "  start   - Start local development environment"
            echo "  stop    - Stop local development environment"
            echo "  deploy  - Deploy to AWS (requires AWS credentials)"
            echo "  clean   - Clean up Docker images and temporary files"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
