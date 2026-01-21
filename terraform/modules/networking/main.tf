# Frontend / Bastion
resource "aws_security_group" "frontend" {
  name        = "${var.project}-frontend-sg"
  description = "Frontend web server + bastion"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.project}-frontend"
    Tier = "frontend"
  })
}

# SSH from developer host only
resource "aws_security_group_rule" "frontend_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.ssh_cidr_blocks
  security_group_id = aws_security_group.frontend.id
  description       = "SSH access from developer host"
}

# HTTP / HTTPS public access
resource "aws_security_group_rule" "frontend_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.frontend.id
}

resource "aws_security_group_rule" "frontend_https" {
  count             = var.enable_https ? 1 : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.frontend.id
}

# Outbound allowed to anywhere
resource "aws_security_group_rule" "frontend_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.frontend.id
}

# Backend (Private, only accessible via frontend)
resource "aws_security_group" "backend" {
  name        = "${var.project}-backend-sg"
  description = "Private backend API"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.project}-backend"
    Tier = "backend"
  })
}

# SSH from frontend/bastion only
resource "aws_security_group_rule" "backend_ssh_from_frontend" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.frontend.id
  security_group_id        = aws_security_group.backend.id
  description              = "SSH from frontend/bastion"
}

# API access from frontend
resource "aws_security_group_rule" "backend_api_from_frontend" {
  type                     = "ingress"
  from_port                = 3001
  to_port                  = 3001
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.frontend.id
  security_group_id        = aws_security_group.backend.id
}

# Optional HTTP from frontend (nginx proxy)
resource "aws_security_group_rule" "backend_http_from_frontend" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.frontend.id
  security_group_id        = aws_security_group.backend.id
}

# Outbound allowed to anywhere (DB, updates, external APIs)
resource "aws_security_group_rule" "backend_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.backend.id
}


# Database (RDS)
resource "aws_security_group" "database" {
  name        = "${var.project}-db-sg"
  description = "PostgreSQL database"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.project}-database"
    Tier = "database"
  })
}

# Access only from backend
resource "aws_security_group_rule" "db_from_backend" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.backend.id
  security_group_id        = aws_security_group.database.id
}

# Outbound allowed
resource "aws_security_group_rule" "db_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.database.id
}
