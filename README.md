# Terraform + Ansible Full-Stack Deployment

Enterprise-grade Infrastructure as Code (IaC) project deploying a complete three-tier **Notes Application** on AWS with separate servers for frontend, backend, and database. Features automated deployment, Nginx reverse proxy, and comprehensive management scripts.

## 🎯 Project Overview

**Purpose:** Deploy production-ready full-stack web application using modern DevOps practices with complete automation from infrastructure provisioning to application deployment.

**Technology Stack:**
- **Infrastructure:** Terraform 1.5+, AWS (VPC, EC2, RDS)
- **Configuration:** Ansible 2.14+, Dynamic Inventory
- **Backend:** NestJS 10, TypeORM, PostgreSQL
- **Frontend:** Next.js 14, React, TypeScript
- **Reverse Proxy:** Nginx (Amazon Linux Extras)
- **Process Manager:** PM2
- **Operating System:** Amazon Linux 2

**Architecture:**
```
┌────────────────────────────────────────────────────────────────┐
│              Custom VPC (10.0.0.0/16)                          │
│                                                                │
│  Public Subnets                    Private Subnets            │
│  ┌─────────────────┐               ┌─────────────┐           │
│  │   Frontend      │               │ PostgreSQL  │           │
│  │   EC2 Instance  │──────┐        │     RDS     │           │
│  │                 │      │        │  Port 5432  │           │
│  │  Nginx :80 ─────┼──┐   │        └─────────────┘           │
│  │    ↓            │  │   │                ↑                  │
│  │  Next.js :3000  │  │   │                │                  │
│  └─────────────────┘  │   │                │                  │
│                       │   ↓                │                  │
│  ┌─────────────────┐  │  ┌───────────────┐│                  │
│  │   Backend       │←─┘  │   Backend     ││                  │
│  │   EC2 Instance  │     │   API         ││                  │
│  │                 │     │               ││                  │
│  │  Nginx :80 ─────┼──┐  └───────────────┘│                  │
│  │    ↓            │  │                   │                  │
│  │  NestJS :3001 ──┼──┼───────────────────┘                  │
│  └─────────────────┘  │                                      │
│                       └─► Public Access via Nginx            │
└────────────────────────────────────────────────────────────────┘

External Access:
• Frontend: http://<frontend-ip> (Nginx → Next.js:3000)
• Backend API: http://<backend-ip> (Nginx → NestJS:3001)
• Database: Private access only (RDS in private subnet)
```

## 📝 Notes Application Features

### Application Capabilities
- ✅ Full CRUD operations on notes
- ✅ Pin important notes to top
- ✅ Search by title and content
- ✅ Filter by category (Work, Personal, Ideas)
- ✅ Responsive modern UI
- ✅ RESTful API with validation
- ✅ PostgreSQL database with TypeORM
- ✅ Production-ready with PM2

### Infrastructure & DevOps Features
- ✅ **Nginx Reverse Proxy** - Production-grade HTTP access on port 80
- ✅ **Automated Deployment** - Single command full-stack deployment
- ✅ **Health Monitoring** - Automated status checking and verification
- ✅ **Inventory Management** - Automatic inventory updates from Terraform
- ✅ **Infrastructure Destruction** - Safe teardown with confirmation
- ✅ **Comprehensive Logging** - Detailed logs for all operations
- ✅ **Security Groups** - Properly configured for HTTP/HTTPS access
- ✅ **PM2 Ecosystem** - Environment variable management

## 🚀 Quick Start

### Prerequisites

- AWS account with credentials configured
- Terraform >= 1.5.0
- Ansible >= 2.14
- Python 3 with boto3
- SSH client

### Full Project Deployment

Use the main deployment script for complete end-to-end deployment:

```bash
./deploy-project.sh
```

This automated script will:
1. Validate environment (Terraform, Ansible, AWS credentials)
2. Deploy infrastructure with Terraform
3. Update Ansible inventory
4. Deploy applications with Ansible
5. Verify deployment health

### Manual Deployment Steps

If you prefer manual control:

**1. Deploy Infrastructure**

```bash
cd terraform
terraform init
terraform plan
terraform apply

# Save outputs
cat APPLY.txt  # View infrastructure changes
```

**2. Deploy Applications**

# Deploy infrastructure
terraform apply

# Save outputs for Ansible
terraform output > ../infrastructure-outputs.txt
```

### 3. Deploy Applications

```bash
cd ../ansible

# Test connectivity
ansible-inventory -i aws_ec2.yml --list
ansible all -m ping

# Deploy full stack
ansible-playbook -i aws_ec2.yml deploy-fullstack.yml \
  -e "db_endpoint=$(cd ../terraform && terraform output -raw database_address)" \
  -e "db_password=YourSecurePassword123!"

# Check deployment
ansible all -m shell -a "pm2 status" -b --become-user=ec2-user
```

### 4. Access Application

```bash
# Get URLs
cd terraform
terraform output

# Access applications
# Frontend: http://<frontend-ip>:3000
# Backend API: http://<backend-ip>:3001/health
```

For detailed deployment guide, see [README-DEPLOYMENT.md](README-DEPLOYMENT.md)

## 📚 Documentation

### Main Documentation

- **[README-DEPLOYMENT.md](README-DEPLOYMENT.md)** - Complete deployment guide
  - Main project deployment script
  - Terraform operations
  - Ansible operations
  - Troubleshooting

- **[ansible/README.md](ansible/README.md)** - Ansible configuration guide
  - Deployment scripts
  - Playbooks and roles
  - Static and dynamic inventory
  - Application management

- **[terraform/scripts/README.md](terraform/scripts/README.md)** - Terraform utilities
  - Infrastructure deployment script
  - State migration
  - Terraform operations

- **[apps/README.md](apps/README.md)** - Application documentation
  - Backend API (NestJS)
  - Frontend UI (Next.js)
  - Local development
  - Features and endpoints

### Quick Reference

| Task | Command |
|------|---------|
| **Deployment** | |
| Full deployment | `./deploy-project.sh` |
| Deploy infrastructure only | `cd terraform/scripts && ./deploy-infrastructure.sh` |
| Deploy applications only | `cd ansible/scripts && ./deploy.sh` |
| Update inventory from Terraform | `cd ansible/scripts && ./update-inventory.sh` |
| **Monitoring** | |
| Check application status | `cd ansible/scripts && ./check-status.sh` |
| Verify Nginx reverse proxies | `cd ansible/scripts && ./verify-nginx.sh` |
| View deployment logs | `tail -f deploy-project.log` |
| View Terraform apply summary | `cat terraform/APPLY.txt` |
| View Terraform destroy summary | `cat terraform/DESTROY.txt` |
| **Destruction** | |
| Destroy all infrastructure | `cd terraform/scripts && ./destroy.sh` |
| Force destroy (no confirmation) | `cd terraform/scripts && ./destroy.sh -y` |
| Manual Terraform destroy | `cd terraform && terraform destroy` |
| **Access** | |
| Frontend (via Nginx) | `http://<frontend-ip>` |
| Frontend (direct) | `http://<frontend-ip>:3000` |
| Backend API (via Nginx) | `http://<backend-ip>` |
| Backend API (direct) | `http://<backend-ip>:3001` |
| Backend health check | `curl http://<backend-ip>/health` |

## 🏗️ Project Structure

```
.
├── README.md                     # This file
├── README-DEPLOYMENT.md          # Deployment guide
├── deploy-project.sh             # Main deployment script
├── deploy-project.log            # Deployment log
│
├── terraform/                    # Infrastructure as Code
│   ├── main.tf                   # Root configuration
│   ├── variables.tf              # Variables
│   ├── outputs.tf                # Outputs
│   ├── backend.tf                # Remote state configuration
│   ├── APPLY.txt                 # Apply summary (auto-generated)
│   ├── DESTROY.txt               # Destroy summary (auto-generated)
│   ├── terraform.tfstate         # State file
│   ├── modules/                  # Terraform modules
│   │   ├── compute/              # EC2 instances
│   │   ├── networking/           # Security groups
│   │   ├── vpc/                  # VPC and subnets
│   │   ├── keys/                 # SSH key pairs
│   │   └── rds/                  # Database
│   └── scripts/                  # Terraform utilities
│       ├── deploy-infrastructure.sh
│       ├── destroy.sh            # Infrastructure destruction
│       └── migrate-state.sh
│
├── ansible/                      # Configuration management
│   ├── README.md                 # Ansible guide
│   ├── deploy-fullstack.yml      # Main playbook
│   ├── deploy-backend.yml        # Backend playbook
│   ├── deploy-frontend.yml       # Frontend playbook
│   ├── inventory.ini             # Static inventory (auto-updated)
│   ├── aws_ec2.yml               # Dynamic inventory
│   ├── ansible.cfg               # Configuration
│   ├── keys/                     # SSH keys
│   │   └── terraform-ansible-webapp-key.pem
│   ├── roles/                    # Service roles
│   │   ├── backend/              # NestJS deployment
│   │   │   └── tasks/
│   │   │       ├── main.yml
│   │   │       └── nginx.yml     # Nginx reverse proxy
│   │   └── frontend/             # Next.js deployment
│   │       └── tasks/
│   │           ├── main.yml
│   │           └── nginx.yml     # Nginx reverse proxy
│   └── scripts/                  # Deployment scripts
│       ├── deploy.sh             # Interactive deployment
│       ├── deploy-dynamic.sh     # Dynamic inventory deployment
│       ├── check-status.sh       # PM2 status checker
│       ├── update (Terraform)
- ✅ **Modular Architecture** - 5 reusable modules (VPC, compute, networking, keys, RDS)
- ✅ **Custom VPC** - Multi-AZ with public/private subnets (10.0.0.0/16)
- ✅ **Remote State** - S3 backend with DynamoDB locking
- ✅ **Security Groups** - HTTP (80), SSH (22), App ports (3000, 3001), PostgreSQL (5432)
- ✅ **Automated Outputs** - JSON outputs for Ansible integration
- ✅ **State Management** - Migration scripts and backups
- ✅ **Destruction Script** - Safe teardown with confirmation prompts

### Configuration Management (Ansible)
- ✅ **Dual Inventory** - Static (inventory.ini) and dynamic (AWS EC2 plugin)
- ✅ **Auto-sync Inventory** - Updates from Terraform outputs automatically
- ✅ **Idempotent Playbooks** - Safe to run multiple times without side effects
- ✅ **Role-based Design** - Modular, reusable roles for frontend/backend
- ✅ **Nginx Integration** - Reverse proxy configuration for both servers
- ✅ **Environment Management** - Secure credential injection via PM2 ecosystem
- ✅ **Process Management** - PM2 with auto-restart and monitoring
- ✅ **Health Checking** - Automated status verification scripts

### Reverse Proxy & Networking
- ✅ **Nginx on Port 80** - Production HTTP access for both frontend and backend
- ✅ **Amazon Linux Extras** - Proper nginx repository enablement
- ✅ **Proxy Configuration** - Frontend (Next.js:3000), Backend (NestJS:3001)
- ✅ **Direct Access** - Application ports also accessible for debugging
- ✅ **Health Endpoints** - Backend /health endpoint for monitoring

### Applications
- ✅ **Standalone Apps** - Independent of infrastructure code
- ✅ **TypeScript** - Type-safe frontend and backend
- ✅ **RESTful API** - Well-structured NestJS endpoints
- ✅ **Modern UI** - Responsive Next.js React app
- ✅ **Database ORM** - TypeORM with PostgreSQL
- ✅ **Environment Variables** - PM2 ecosystem.config.js for reliable env loading

### Automation & Scripts
- ✅ **One-command Deployment** - `./deploy-project.sh` for complete setup
- ✅ **Automated Verification** - Post-deployment health checks
- ✅ **Status Monitoring** - Real-time PM2 status across all servers
- ✅ **Comprehensive Logging** - All operations logged with timestamps
- ✅ **Error Handling** - Graceful failure handling and recovery suggestions
- ✅ **Dynamic Inventory** - Automatic AWS resource discovery
- ✅ **Idempotent Playbooks** - Safe to run multiple times
- ✅ **Role-based** - Modular, reusable Ansible roles
- ✅ **Environment Injection** - Secure credential management
- ✅ **Process Management** - PM2 for zero-downtime

### Applications
- ✅ **Standalone Apps** - Independent of infrastructure code
- ✅ **TypeScript** - Type-safe frontend and backend
- ✅ **RESTful API** - Well-structured NestJS endpoints
- ✅ **Modern UI** - Responsive Next.js React app
- ✅ **Database ORM** - TypeORM with PostgreSQL

## 🔧 Common Operations

### Update Application Code

```bash
# Update backend only
cd ansible/scripts
./deploy.sh  # Select backend when prompted

# Update frontend only
cd ansible/scripts
./deploy.sh  # Select frontend when prompted

# Check current status
cd ansible/scripts
./check-status.sh

# SSH to backend and restart
ssh -i ../keys/terraform-ansible-webapp-key.pem ec2-user@<backend-ip>
pm2 restart backend

# SSH to frontend and restart
ssh -i ../keys/terraform-ansible-webapp-key.pem ec2-user@<frontend-ip>
pm2 restart frontend

# Restart Nginx
sudo systemctl restart nginx
```

### Verify Nginx Reverse Proxy

```bash
# Run verification script
cd ansible/scripts
./verify-nginx.sh

# Manual verification
curl http://<frontend-ip>          # Should return Next.js app
curl http://<backend-ip>           # Should return NestJS API
curl http://<backend-ip>/health    # Should return {"status":"healthy"}
```bash
# Edit terraform/terraform.tfvars (if exists) or modify variables
cd terraform
terraform plan
terraform app                      # Apply summary
terraform output                   # Current outputs

# Check Ansible logs
cd ansible/scripts
tail -f deploy.log

# Test connectivity
./check-status.sh

# Verify inventory is updated
cat ../inventory.ini
```

### Nginx Issues

```bash
# Verify Nginx is running
cd ansible/scripts
./verify-nginx.sh

# Check Nginx status directly
ssh -i ../keys/terraform-ansible-webapp-key.pem ec2-user@<server-ip>
sudo systemctl status nginx
sudo nginx -t                      # Test configuration

# View Nginx logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

### Application Issues

```bash
# Check PM2 status
cd ansible/scripts
./check-status.sh

# SSH to server and check PM2 logs
ssh -i ../keys/terraform-ansible-webapp-key.pem ec2-user@<server-ip>
pm2 status
pm2 logs backend                   # or 'frontend'
pm2 describe backend               # Detailed info

# Test direct application access
curl http://<backend-ip>:3001/health    # Direct to app
curl http://<backend-ip>/health         # Via Nginx

# Check environment variables
cd ~/backend  # or ~/frontend
cat ecosystem.config.js            # PM2 config with env vars
```

### Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| **Nginx pack & Destruction

### Recommended Method (Safe with Confirmation)

```bash
# Interactive destruction with confirmation
cd terraform/scripts
./destroy.sh

# This will:
# 1. Generate destroy plan
# 2. Show resources to be deleted
# 3. Require typing "destroy" to confirm
# 4. Execute destruction
# 5.Infrastructure Enhancements
- [ ] Add Application Load Balancer (ALB)
- [ ] Implement Auto Scaling Groups
- [ ] Add CloudWatch monitoring and metrics
- [ ] Configure CloudFront CDN for frontend
- [ ] Add SSL/TLS certificates (ACM + Route53)
- [ ] Set up CloudWatch alarms and SNS notifications
- [ ] Implement automated backups for RDS
- [ ] Add ElastiCache for Redis caching
- [ ] Configure VPC Flow Logs
- [ ] Implement WAF for security

### Deployment & DevOps
- [x] ✅ Nginx reverse proxy configuration
- [x] ✅ Automated deployment scripts
- [x] ✅ Health monitoring and verification
- [x] ✅ Infrastructure destruction script
- [ ] Implement CI/CD pipeline (GitHub Actions/Jenkins)
- [ ] Add blue-green deployment
- [ ] Implement canary deployments
- [ ] Add infrastructure testing (Terratest)
- [ ] Set up centralized logging (ELK stack)
- [ ] Add APM (Application Performance Monitoring)

### Application Features
- [ ] User authentication (JWT/Passport)
- [ ] User authorization (RBAC)
- [ ] Note sharing and collaboration
- [ ] Rich text editor (TipTap/Slate)
- [ ] File attachments (S3 upload)
- [ ] Tags and labels
- [ ] Full-text search (Elasticsearch)
- [ ] Dark mode theme
- [ ] Mobile responsive improvements
- [ ] PWA (Progressive Web App)
- [ ] Real-time updates (WebSockets) be destroyed
terraform plan -destroy
```

### Complete Cleanup

```bash
# 1. Destroy infrastructure
cd terraform/scripts
./destroy.sh

# 2. Delete S3 state bucket (optional - only if no longer needed)
cd ../backend-setup
terraform destroy

# 3. Clean up local files (optional)
rm -f terraform/APPLY.txt
rm -f terraform/DESTROY.txt
rm -f deploy-project.log
rm -f ansible/scripts/*.log

# 4. Remove SSH keys (optional)
rm -f ansible/keys/*.pem
```

**Files preserved after destruction:**
- Terraform configuration (*.tf files)
- Terraform state files (for recovery)
- Application source code
- Documentation files
## 🛠️ Troubleshooting

### Deployment Issues

```bash
# Check main deployment log
tail -f deploy-project.log

# Check Terraform outputs
cd terraform
cat APPLY.txt

# Check Ansible logs
cd ansible
cat deploy.log

# Test connectivity
cd ansible/scripts
./check-status.sh
```

### Application Issues

```bash
# Check application status
cd ansible/scripts
./check-status.sh

# View detailed logs
tail -f ansible/deploy.log

# Test endpoints
curl http://<backend-ip>:3001/health
curl http://<frontend-ip>:3000
```

For detailed troubleshooting, see [README-DEPLOYMENT.md](README-DEPLOYMENT.md)

## 🔒 Security Best Practices

1. **Never commit secrets** - Use `.gitignore` for:
   - `terraform.tfvars`
   - `*.pem` keys
   - `.vault_pass`
   - `*.tfstate` files

2. **Use Ansible Vault** for sensitive variables
3. **Rotate database passwords** regularly
4. **Review security groups** - Only open required ports
5. **Enable MFA** on AWS account
6. **Use IAM roles** for EC2 instances when possible

## 🚨 Cost Management

**Estimated monthly cost** (us-east-1, as of 2026):
- EC2 t2.micro (3 instances): ~$27/month
- RDS db.t3.micro: ~$17/month
- S3 state bucket: <$1/month
- DynamoDB on-demand: <$1/month
- **Total: ~$46/month**

**Cost optimization:**
- Stop instances when not in use
- Use reserved instances for production
- Enable auto-scaling for variable load
- Monitor with AWS Cost Explorer

## 🗑️ Cleanup

```bash
# Destroy all infrastructure
cd terraform
terraform destroy

# Delete S3 state bucket (optional)
cd backend-setup
terraform destroy
```

## 📈 Next Steps

### Enhancements
- [ ] Add Application Load Balancer
- [ ] Implement Auto Scaling Groups
- [ ] Add CloudWatch monitoring
- [ ] Configure CloudFront CDN
- [ ] Implement CI/CD pipeline
- [ ] Add SSL/TLS certificates
- [ ] Set up CloudWatch alarms
- [ ] Add backup automation

### Application Features
- [ ] User authentication (JWT)
- [ ] User authorization (RBAC)
- [ ] Note sharing capabilities
- [ ] Rich text editor
- [ ] File attachments
- [ ] Tags and labels
- [ ] Dark mode
- [ ] Mobile app

## 🤝 Contributing

This is a demonstration project. Feel free to:
- Fork and customize for your needs
- Add new features
- Improve documentation
- Share feedback

## 📄 License

MIT License - See LICENSE file

## 🙏 Acknowledgments

Built with:
- [Terraform](https://www.terraform.io/)
- [Ansible](https://www.ansible.com/)
- [NestJS](https://nestjs.com/)
- [Next.js](https://nextjs.org/)
- [AWS](https://aws.amazon.com/)

## 📞 Support

For issues and questions:
1. Check [README-DEPLOYMENT.md](README-DEPLOYMENT.md)
2. Check [ansible/README.md](ansible/README.md)
3. Review troubleshooting sections above
4. Check logs: `deploy-project.log`, `terraform/APPLY.txt`, `ansible/deploy.log`

---

**Happy deploying! 🚀**
