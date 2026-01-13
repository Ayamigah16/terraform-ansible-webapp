output "region" {
  description = "AWS region used for deployment"
  value       = var.aws_region
}

output "key_name" {
  description = "EC2 key pair name"
  value       = aws_key_pair.ec2_key.key_name
}

output "private_key_path" {
  description = "Path to the private SSH key for Ansible"
  value       = local_file.private_key.filename
}

output "project_name" {
  description = "Project name used for tagging"
  value       = var.project_name
}