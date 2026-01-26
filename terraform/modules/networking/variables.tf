variable "vpc_id" {
  description = "ID of the VPC where security groups will be created"
  type        = string
}

variable "project" {
  description = "Project name prefix for resources"
  type        = string
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed to SSH into frontend/bastion"
  type        = list(string)
}

variable "enable_https" {
  description = "Enable HTTPS ingress rule"
  type        = bool
  default     = true
}

variable "enable_backend_http" {
  description = "Enable HTTP ingress rule for backend"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
