terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Local variables for common tags
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.managed_by
    CreatedAt   = timestamp()
  }
  
  availability_zones = slice(data.aws_availability_zones.available.names, 0, var.vpc_azs_count)
}

# Module: VPC
module "vpc" {
  source = "./modules/vpc"

  vpc_name             = "${var.project_name}-vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = local.availability_zones
  
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  enable_flow_logs     = var.enable_vpc_flow_logs
  
  common_tags = local.common_tags
}

# Module: SSH Keys
module "keys" {
  source = "./modules/keys"

  key_pair_name        = var.key_name_prefix
  private_key_path     = "${path.module}/../ansible/keys/${var.project_name}-key.pem"
  key_algorithm        = "RSA"
  key_rsa_bits         = 4096
  private_key_permission = "0400"

  common_tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-key"
    }
  )
}

# Module: Networking (Security Group)
module "networking" {
  source = "./modules/networking"

  vpc_id                     = module.vpc.vpc_id
  security_group_name        = "${var.project_name}-sg"
  security_group_description = "Security group for ${var.project_name}"
  ssh_cidr_blocks            = var.ssh_cidr_blocks
  http_cidr_blocks           = var.http_cidr_blocks
  https_cidr_blocks          = var.https_cidr_blocks
  enable_https               = var.enable_https

  common_tags = local.common_tags
}

# Module: Compute (EC2 Instance)
module "compute" {
  source = "./modules/compute"

  subnet_id            = module.vpc.public_subnet_ids[0]
  instance_name        = "${var.project_name}-ec2"
  instance_type        = var.instance_type
  instance_role        = "web"
  key_pair_name        = module.keys.key_pair_name
  security_group_ids   = [module.networking.security_group_id]
  
  associate_public_ip  = true
  enable_monitoring    = var.enable_detailed_monitoring
  root_volume_size     = var.root_volume_size
  root_volume_type     = var.root_volume_type
  enable_encryption    = var.enable_ebs_encryption
  
  ssh_user             = var.ssh_user
  private_key_path     = module.keys.private_key_path
  inventory_file_path  = "${path.module}/../ansible/inventory.ini"

  common_tags = local.common_tags
}
