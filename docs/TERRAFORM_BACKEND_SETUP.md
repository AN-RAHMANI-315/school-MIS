# 🏗️ Terraform Backend Setup Guide

This guide explains how to resolve the Terraform S3 backend initialization error and set up the infrastructure properly.

## ❌ The Problem

```
Error: Failed to get existing workspaces: S3 bucket does not exist.
Error: NoSuchBucket: The specified bucket does not exist
```

This happens because Terraform is configured to use an S3 backend for state storage, but the required S3 bucket and DynamoDB table don't exist yet.

## ✅ Solution Options

### Option 1: Automated Backend Setup (Recommended)

Run the automated setup script:

```bash
# Navigate to the project directory
cd /path/to/School-MIS

# Run the backend setup script
./scripts/setup-terraform-backend.sh
```

This script will:
- ✅ Create S3 bucket: `school-mis-terraform-state`
- ✅ Enable versioning and encryption
- ✅ Block public access
- ✅ Create DynamoDB table: `school-mis-terraform-locks`
- ✅ Configure proper permissions

### Option 2: Manual Backend Setup

If you prefer manual setup:

```bash
# 1. Create S3 bucket
aws s3 mb s3://school-mis-terraform-state --region us-east-1

# 2. Enable versioning
aws s3api put-bucket-versioning \
  --bucket school-mis-terraform-state \
  --versioning-configuration Status=Enabled

# 3. Enable encryption
aws s3api put-bucket-encryption \
  --bucket school-mis-terraform-state \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# 4. Block public access
aws s3api put-public-access-block \
  --bucket school-mis-terraform-state \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# 5. Create DynamoDB table for locking
aws dynamodb create-table \
  --table-name school-mis-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1
```

### Option 3: Start with Local State

If you want to start without S3 backend:

```bash
# 1. Use the local state configuration
cd terraform
cp main-local.tf main.tf

# 2. Initialize with local state
terraform init

# 3. Deploy infrastructure
terraform plan
terraform apply

# 4. Later migrate to S3 backend
# - Run backend setup script
# - Uncomment S3 backend in main.tf
# - Run: terraform init -migrate-state
```

## 🚀 After Backend Setup

Once the backend is configured, run:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## 🔧 GitHub Actions Integration

The CI/CD pipeline now automatically:
1. ✅ Sets up the backend infrastructure
2. ✅ Initializes Terraform
3. ✅ Runs plan and apply

## 📋 Backend Configuration Details

### S3 Bucket Configuration:
- **Name**: `school-mis-terraform-state`
- **Region**: `us-east-1`
- **Versioning**: Enabled
- **Encryption**: AES256
- **Public Access**: Blocked

### DynamoDB Table Configuration:
- **Name**: `school-mis-terraform-locks`
- **Partition Key**: `LockID` (String)
- **Read Capacity**: 5 units
- **Write Capacity**: 5 units

## 🛡️ Security Best Practices

The setup includes:
- ✅ Encryption at rest
- ✅ Versioning for state history
- ✅ State locking to prevent concurrent modifications
- ✅ Public access blocked
- ✅ Proper IAM permissions

## 🔄 State Management Commands

```bash
# View current state
terraform show

# List resources in state
terraform state list

# Import existing resources
terraform import <resource_type>.<name> <resource_id>

# Refresh state
terraform refresh

# Lock state manually
terraform force-unlock <lock_id>
```

## 🚨 Troubleshooting

### Issue: Bucket already exists (owned by someone else)
```bash
# Use a unique bucket name with your account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="school-mis-terraform-state-${AWS_ACCOUNT_ID}"
```

### Issue: DynamoDB table already exists
```bash
# Check if table exists
aws dynamodb describe-table --table-name school-mis-terraform-locks
```

### Issue: Permission denied
```bash
# Check your AWS credentials
aws sts get-caller-identity

# Ensure your IAM user/role has required permissions:
# - S3: CreateBucket, PutBucketVersioning, PutBucketEncryption
# - DynamoDB: CreateTable, DescribeTable
```

## ✅ Verification

After setup, verify everything works:

```bash
# Test Terraform
cd terraform
terraform init
terraform validate
terraform plan

# Should show: "Successfully configured the backend 's3'!"
```

---

**📝 Note**: The backend setup only needs to be done once per AWS account/region. After that, all team members can use the shared state.
