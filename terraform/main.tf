terraform {
    required_version = ">= 1.5.0"

    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = var.aws_region
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/../ansible/keys/${var.key_name_prefix}.pem"
  file_permission = "0400"
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "${var.key_name_prefix}-${var.project_name}"
  public_key = tls_private_key.ssh_key.public_key_openssh

  tags = {
    Name    = "${var.project_name}-key"
    Project = var.project_name
  }
}