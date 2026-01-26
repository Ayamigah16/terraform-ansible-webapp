# Security Hardening Implementation

## Overview
This document describes the comprehensive security hardening measures implemented for the terraform-ansible-webapp project.

## Security Changes Implemented

### 1. Network Architecture Security

#### Backend in Private Subnet ✅
- **Change**: Moved backend instance from public to private subnet
- **File**: `terraform/main.tf`
- **Impact**: Backend API is no longer directly accessible from the internet
- **Access**: Only accessible via frontend proxy

#### Security Group Hardening ✅
- **Removed**: Direct public access to ports 3000 (Next.js) and 3001 (NestJS API)
- **Removed**: Public HTTP access to backend
- **Added**: Security group rules allowing only frontend-to-backend communication
- **File**: `terraform/modules/networking/security-groups-fullstack.tf`

#### SSH Access Restriction ✅
- **Change**: Restricted SSH access from `0.0.0.0/0` to specific IP: `154.161.180.62/32`
- **File**: `terraform/variables.tf`, `terraform/terraform.tfvars`
- **Impact**: Only authorized IP can SSH into instances

### 2. Infrastructure Security

#### IMDSv2 Enforcement ✅
- **Change**: Enabled IMDSv2 (Instance Metadata Service v2) for all EC2 instances
- **File**: `terraform/modules/compute/main.tf`
- **Protection**: Prevents SSRF attacks on EC2 metadata endpoint
- **Configuration**:
  ```hcl
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
  ```

#### Storage Encryption ✅
- **RDS**: Storage encryption enabled by default
- **EBS**: Root volumes encrypted
- **File**: `terraform/terraform.tfvars`

### 3. Nginx Rate Limiting & DDoS Protection ✅

#### Rate Limiting Implementation
- **Location**: Nginx configuration templates
- **Files**: 
  - `ansible/roles/frontend/templates/frontend-nginx.conf.j2`
  - `ansible/roles/backend/templates/backend-nginx.conf.j2`

#### Rate Limit Configuration
```nginx
# Frontend rate limits
limit_req_zone $binary_remote_addr zone=general:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=api:10m rate=5r/s;

# Backend rate limits
limit_req_zone $binary_remote_addr zone=backend_api:10m rate=10r/s;
```

#### Protection Features
- **General traffic**: 10 requests/second per IP (burst: 20)
- **API traffic**: 5 requests/second per IP (burst: 10)
- **Backend API**: 10 requests/second per IP (burst: 20)
- **Response**: 429 Too Many Requests when exceeded
- **Memory**: 10MB per zone (tracks ~160,000 IPs)

### 4. Secrets Management ✅

#### Ansible Vault Implementation
- **File**: `ansible/group_vars/all/vault.yml`
- **Encryption**: Encrypted using `.vault_pass`
- **Contents**:
  - Database credentials
  - API keys
  - JWT secrets
  - Session secrets
  - Backend API URLs
  - Monitoring tokens

#### Vault Configuration
- **File**: `ansible/ansible.cfg`
- **Setting**: `vault_password_file = .vault_pass`
- **Usage**:
  ```bash
  # Edit vault
  ansible-vault edit group_vars/all/vault.yml --vault-password-file=.vault_pass
  
  # View vault
  ansible-vault view group_vars/all/vault.yml --vault-password-file=.vault_pass
  ```

### 5. Nginx Reverse Proxy Configuration ✅

#### Frontend Proxy to Private Backend
- **File**: `ansible/roles/frontend/templates/frontend-nginx.conf.j2`
- **Configuration**: Frontend nginx proxies `/api` requests to backend private IP
- **Benefit**: Backend remains isolated in private subnet

#### Security Headers
Enhanced security headers in Nginx:
- X-Frame-Options: SAMEORIGIN
- X-Content-Type-Options: nosniff
- X-XSS-Protection: 1; mode=block
- Referrer-Policy: strict-origin-when-cross-origin

### 6. Least Privilege Access

#### Security Group Rules
- **Frontend**: Only ports 22 (SSH from specific IP) and 80 (HTTP public)
- **Backend**: Only ports from frontend security group
- **Database**: Only port 5432 from backend security group

#### IAM and Permissions
- RDS enhanced monitoring with dedicated IAM role
- Principle of least privilege applied

## Architecture Changes

### Before Hardening
```
Internet → Frontend (Public) → Backend (Public) → Database (Private)
          ↓
        Direct access to ports 3000, 3001
```

### After Hardening
```
Internet → Frontend (Public:80) → Backend (Private) → Database (Private)
             ↓ Nginx Proxy + Rate Limiting
           /api → Private Backend
```

## Configuration Files Modified

### Terraform Files
1. `terraform/main.tf` - Backend subnet change
2. `terraform/variables.tf` - SSH CIDR restriction
3. `terraform/terraform.tfvars` - Restricted SSH IP
4. `terraform/outputs.tf` - Updated outputs for private backend
5. `terraform/modules/compute/main.tf` - IMDSv2 configuration
6. `terraform/modules/networking/security-groups-fullstack.tf` - Hardened security rules

### Ansible Files
1. `ansible/ansible.cfg` - Vault password file, removed hardcoded key path
2. `ansible/group_vars/all/vault.yml` - Encrypted secrets
3. `ansible/group_vars/all/vars.yml` - Non-sensitive configuration
4. `ansible/roles/frontend/templates/frontend-nginx.conf.j2` - Backend proxy + rate limiting
5. `ansible/roles/backend/templates/backend-nginx.conf.j2` - Rate limiting configuration

## Deployment Instructions

### 1. Initialize and Apply Terraform
```bash
cd terraform

# Initialize (for new WAF module)
terraform init

# Plan changes
terraform plan

# Apply with auto-approve (or review first)
terraform apply
```

### 2. Run Ansible Playbooks
```bash
cd ../ansible

# Deploy frontend with vault
ansible-playbook deploy-frontend.yml --vault-password-file=.vault_pass

# Deploy backend (now in private subnet)
# Note: Backend needs to be accessible via bastion or Systems Manager
```

### 3. Access the Application
- **Frontend**: `http://<frontend-public-ip>`
- **Backend API**: Accessible only via frontend proxy at `http://<frontend-public-ip>/api`

## Security Compliance

### Standards Met
- ✅ Network segmentation (public/private subnets)
- ✅ Least privilege access control
- ✅ Encryption at rest (RDS, EBS)
- ✅ Encryption in transit (HTTPS ready)
- ✅ Secrets management (Ansible Vault)
- ✅ Rate limiting & DDoS protection (Nginx)
- ✅ Secure metadata service (IMDSv2)
- ✅ Security monitoring (Nginx logs)
- ✅ IP-based access control

### Recommended Next Steps
1. Enable HTTPS with SSL certificates (Let's Encrypt or ACM)
2. Implement AWS Systems Manager Session Manager for SSH-less access
3. Enable AWS GuardDuty for threat detection
4. Set up CloudWatch alarms for security events
5. Implement log aggregation and SIEM integration
6. Add AWS Config for compliance monitoring
7. Enable AWS Security Hub
8. Implement database connection pooling with SSL
9. Add API authentication (JWT, OAuth)
10. Implement CI/CD pipeline security scanning

## Testing Security

### Verify Backend Privacy
```bash
# This should fail (no public IP or access)
curl http://<backend-ip>:3001

# This should work through frontend proxy
curl http://<frontend-ip>/api/health
```

### Verify SSH Restriction
```bash
# Only works from 154.161.180.62
ssh -i keys/terraform-ansible-webapp-key.pem ec2-user@<frontend-ip>
```

### Verify Rate Limiting
```bash
# Test rate limiting (should get 429 after exceeding limits)
for i in {1..100}; do curl http://<frontend-ip>/api/health; done
```

## Rollback Procedure

If issues occur:
```bash
# Terraform rollback
cd terraform
git checkout main  # or previous commit
terraform apply

# Ansible vault decrypt (if needed for troubleshooting)
ansible-vault decrypt group_vars/all/vault.yml --vault-password-file=.vault_pass
```

## Maintenance

### Rotating Secrets
```bash
# Edit vault
ansible-vault edit group_vars/all/vault.yml --vault-password-file=.vault_pass

# Re-run playbooks
ansible-playbook deploy-fullstack.yml --vault-password-file=.vault_pass
```

### Updating Rate Limits
Edit Nginx configuration templates and re-run Ansible:
```nginx
# Adjust in frontend-nginx.conf.j2 / backend-nginx.conf.j2
limit_req_zone $binary_remote_addr zone=general:10m rate=20r/s;  # Increase if needed
```

Then deploy:
```bash
ansible-playbook deploy-frontend.yml --vault-password-file=.vault_pass
```

## Monitoring and Alerts

### Nginx Metrics
Monitor `/var/log/nginx/` for:
- `frontend-access.log` - Frontend access patterns
- `frontend-error.log` - Rate limit violations (429 errors)
- `backend-access.log` - Backend API access
- `backend-error.log` - Backend errors

### Rate Limit Monitoring
```bash
# Check rate limit violations
grep "limiting requests" /var/log/nginx/frontend-error.log
grep "limiting requests" /var/log/nginx/backend-error.log
```

## Cost Impact

Estimated monthly cost:
- **No additional cost** - All security features use existing infrastructure
- Nginx rate limiting: Free
- IMDSv2: Free
- Private subnets: Free (already part of VPC)

**Total additional cost: $0/month**

## Support and Documentation

- Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- AWS WAF: https://docs.aws.amazon.com/waf/
- Ansible Vault: https://docs.ansible.com/ansible/latest/user_guide/vault.html
- IMDSv2: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-service.html
