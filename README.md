# Terraform + Ansible Full-Stack Deployment

Automated deployment of a three-tier **Notes Application** on AWS using Terraform and Ansible.

## 🎯 Overview

**Stack:** Terraform | Ansible | NestJS | Next.js | PostgreSQL | Nginx | PM2

**Architecture:**

```bash
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

#### 1. Deploy Infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

- Save outputs

```bash
cat APPLY.txt  # View infrastructure changes
```

#### 2. Deploy Applications

- Deploy infrastructure
  
```bash
terraform apply
```

#### 3. Deploy Applications

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

## 🏗️ Project Structure

```bash
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
```

For detailed troubleshooting, see [README-DEPLOYMENT.md](README-DEPLOYMENT.md)

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

---

- **Happy deploying! 🚀**
