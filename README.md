# 🏫 School Management Information System (MIS)

A comprehensive school management system built with modern web technologies, featuring automated CI/CD deployment to AWS.

## 🌟 Features

- **👥 Student Management** - Registration, profiles, academic records
- **📚 Course Management** - Curriculum, scheduling, assignments  
- **👨‍🏫 Teacher Portal** - Grade management, attendance tracking
- **📊 Analytics Dashboard** - Performance metrics and reporting
- **🔐 Role-based Access** - Student, Teacher, Admin permissions
- **📱 Responsive Design** - Mobile-friendly interface

## 🛠️ Technology Stack

### Frontend
- **React** - Modern UI framework
- **Tailwind CSS** - Utility-first styling
- **Craco** - Create React App Configuration Override

### Backend  
- **FastAPI** - High-performance Python web framework
- **MongoDB** - NoSQL database for flexible data storage
- **Pydantic** - Data validation and serialization

### DevOps & Infrastructure
- **Docker** - Containerization
- **GitHub Actions** - CI/CD pipeline
- **AWS ECS** - Container orchestration  
- **Terraform** - Infrastructure as Code
- **AWS ALB** - Load balancing
- **ECR** - Container registry

## 🚀 Quick Start

### One-Command Setup
```bash
# Clone the repository
git clone <your-repo-url>
cd School-MIS

# Run the quick setup script
./scripts/quick-setup.sh
```

This script will:
- ✅ Check all required tools
- 🏗️ Build Docker images  
- 🔧 Setup environment files
- 🚀 Start local development environment
- 📋 Display next steps for deployment

### Manual Setup
```bash
# Install dependencies and start services
docker-compose up --build

# Access the application
# Frontend: http://localhost:3000
# Backend API: http://localhost:8000
# API Documentation: http://localhost:8000/docs
```

## 📦 Deployment

### Local Development
```bash
# Start all services
docker-compose up

# Stop all services  
docker-compose down

# View logs
docker-compose logs
```

### Production Deployment

#### Option 1: Automated CI/CD (Recommended)
1. **Setup GitHub Secrets**:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY` 
   - `SLACK_WEBHOOK_URL` (optional)

2. **Deploy**:
   ```bash
   git push origin main
   ```

#### Option 2: Manual AWS Deployment
```bash
# Setup Terraform backend
./scripts/setup-terraform-backend.sh

# Deploy infrastructure
cd terraform
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

📖 **Full deployment guide**: [docs/PRODUCTION_DEPLOYMENT.md](docs/PRODUCTION_DEPLOYMENT.md)

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React Frontend│    │  FastAPI Backend│    │    MongoDB      │
│   (Port 3000)   │◄──►│   (Port 8000)   │◄──►│   (Port 27017)  │
│                 │    │                 │    │                 │
│ • Dashboard     │    │ • REST APIs     │    │ • Student Data  │
│ • Student Portal│    │ • Authentication│    │ • Course Info   │
│ • Teacher Portal│    │ • Data Logic    │    │ • User Records  │
│ • Admin Panel   │    │ • Validation    │    │ • Analytics     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### AWS Production Architecture
```
Internet → ALB → ECS Fargate → ECR Images
              ↓
          CloudWatch Logs
```

## 📁 Project Structure

```
School-MIS/
├── 📁 frontend/          # React application
│   ├── public/           # Static assets
│   ├── src/             # Source code
│   └── package.json     # Dependencies
├── 📁 backend/           # FastAPI application  
│   ├── server.py        # Main application
│   └── requirements.txt # Python dependencies
├── 📁 terraform/         # Infrastructure as Code
│   ├── main.tf          # Main configuration
│   ├── ecs.tf           # Container orchestration
│   └── *.tf             # Other AWS resources
├── 📁 .github/workflows/ # CI/CD pipeline
├── 📁 scripts/           # Deployment scripts
├── 📁 docs/             # Documentation
├── docker-compose.yml   # Local development
└── README.md           # This file
```

## 🔧 Configuration

### Environment Variables (.env)
```bash
# Application
NODE_ENV=development
REACT_APP_API_URL=http://localhost:8000

# Database
MONGODB_URI=mongodb://localhost:27017/school_mis

# AWS (for deployment)
AWS_REGION=us-east-1
AWS_ACCOUNT_ID=your-account-id
```

### Terraform Variables (terraform/terraform.tfvars)
```hcl
project_name = "school-mis"
environment  = "production" 
aws_region   = "us-east-1"

# Container sizing
backend_cpu    = 256
backend_memory = 512
frontend_cpu   = 256  
frontend_memory = 512
```

## 🧪 Testing

```bash
# Backend tests
cd backend
python -m pytest

# Frontend tests  
cd frontend
npm test

# Integration tests
python backend_test.py
```

## 📊 Monitoring

### Local Development
- **Application**: http://localhost:3000
- **API Docs**: http://localhost:8000/docs
- **Container Logs**: `docker-compose logs`

### Production
- **CloudWatch Logs**: Centralized logging
- **ECS Metrics**: Container performance
- **ALB Health Checks**: Service availability

## 🛡️ Security Features

- **🔐 Authentication** - Secure user authentication
- **🛡️ Authorization** - Role-based access control
- **🔍 Vulnerability Scanning** - Automated security checks
- **🌐 HTTPS** - Encrypted communication
- **🏗️ Network Security** - VPC with private subnets

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **📖 Documentation**: Check the [docs/](docs/) folder
- **🐛 Issues**: Report bugs on GitHub Issues
- **💬 Discussions**: Use GitHub Discussions for questions

## 🎯 Roadmap

- [ ] **Advanced Analytics** - Enhanced reporting dashboard
- [ ] **Mobile App** - Native mobile application
- [ ] **API v2** - GraphQL API implementation
- [ ] **Multi-tenancy** - Support for multiple schools
- [ ] **Real-time Updates** - WebSocket integration

---

Built with ❤️ for educational institutions
