# Deployment Fixes & Cleanup Documentation

## 🔧 Issues Fixed

### 1. **NAT Gateway Configuration Error**
**Problem**: Terraform NAT gateway resources were hardcoded to `count = 0` but routes still referenced them.
**Fix**: Updated `terraform/modules/vpc/main.tf` to properly handle conditional NAT gateway creation based on `enable_nat_gateway` variable.

### 2. **SSH Security Group Access**
**Problem**: Security group only allowed SSH from old IP `154.161.147.98/32`, current IP was `196.61.44.164/32`.
**Fix**: Updated `terraform/terraform.tfvars` with correct IP address.

### 3. **Ansible Inventory SSH Configuration**
**Problem**: Backend in private subnet couldn't be reached directly; needed bastion configuration.
**Fix**: Updated inventory to use ProxyCommand through frontend as SSH bastion:
```ini
[role_backend]
10.0.10.124 ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -i ./keys/terraform-ansible-webapp-key.pem ec2-user@3.254.75.195"'
```

### 4. **Deployment Script Vault Error**
**Problem**: Deploy script referenced undefined `$VAULT_PASSWORD_FILE` variable.
**Fix**: Updated `ansible/scripts/deploy.sh` to use proper ansible-playbook command without vault dependency.

### 5. **Inventory Update Script**
**Problem**: Script tried to get `backend_public_ip` but backend is in private subnet.
**Fix**: Updated `ansible/scripts/update-inventory.sh` to use `backend_private_ip` instead.

## 🧹 Cleanup Actions

### Files Created
- `verify-and-fix.sh` - Comprehensive environment validation
- `refresh-aws-credentials.sh` - AWS credential helper
- `quick-fix.sh` - Common issues resolver  
- `health-check.sh` - Infrastructure health checker
- `simple-health-check.sh` - Service-focused health check

### Files Modified
- `terraform/modules/vpc/main.tf` - Fixed NAT gateway logic
- `terraform/terraform.tfvars` - Updated SSH IP address
- `ansible/inventory.ini` - Fixed bastion SSH configuration
- `ansible/scripts/deploy.sh` - Removed vault dependency
- `ansible/scripts/update-inventory.sh` - Use private IP for backend

## ✅ Final Working State

### Infrastructure
- **VPC**: Custom VPC with public/private subnets ✅
- **Frontend**: EC2 in public subnet (3.254.75.195) ✅
- **Backend**: EC2 in private subnet (10.0.10.124) ✅
- **Database**: RDS PostgreSQL in private subnet ✅
- **NAT Gateway**: Enabled for backend internet access ✅

### Applications
- **Frontend**: Next.js + Nginx on port 80 ✅
- **Backend**: NestJS + Nginx on port 80 ✅
- **Process Manager**: PM2 managing both applications ✅
- **Database**: PostgreSQL connected to backend ✅

### Security
- **Network Isolation**: Backend in private subnet ✅
- **SSH Bastion**: Frontend acts as jump host ✅
- **Security Groups**: Least privilege access ✅
- **SSH Keys**: Proper permissions (600) ✅

## 🚀 Access URLs
- **Frontend**: http://3.254.75.195
- **Backend API**: Internal only via frontend proxy

## 📋 Management Commands
```bash
# Health check
./simple-health-check.sh

# Application status
cd ansible/scripts && ./check-status.sh

# Redeploy applications
cd ansible/scripts && ./deploy.sh

# Full redeployment
./deploy-project.sh

# Infrastructure cleanup
cd terraform && terraform destroy
```

## 🎯 Key Learnings
1. **Private subnet architecture** requires proper bastion configuration
2. **Security group IP updates** needed when public IP changes
3. **NAT gateway conditional logic** must be consistent across resources
4. **Ansible vault** not always necessary for simple deployments
5. **Health checks** should test actual services, not just state files