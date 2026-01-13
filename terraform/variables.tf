variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name used for tagging"
  type        = string
  default     = "terraform-ansible-webapp"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name_prefix" {
  description = "Prefix for the EC2 key pair name"
  type        = string
  default     = "terraform-ansible-webapp-key"
}
