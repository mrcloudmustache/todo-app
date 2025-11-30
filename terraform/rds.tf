resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.db_name}-subnet-group"
  subnet_ids = data.aws_subnets.default_vpc_subnets.ids
  tags = {
    Name = "${var.db_name}-subnet-group"
  }
}

# Security group for the DB
resource "aws_security_group" "rds_sg" {
  name        = "${var.db_name}-rds-sg"
  description = "Allow DB access for ${var.db_name}"
  vpc_id      = data.aws_vpc.default.id
}

# Allow inbound from a CIDR if provided
resource "aws_security_group_rule" "allow_cidr" {
  count             = length(trimspace(var.allowed_cidr)) > 0 ? 1 : 0
  security_group_id = aws_security_group.rds_sg.id
  type              = "ingress"
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "tcp"
  cidr_blocks       = [var.allowed_cidr]
  description       = "Allow Postgres from specified CIDR"
}

# Allow inbound from a EB security group
resource "aws_security_group_rule" "allow_eb" {
  security_group_id        = aws_security_group.rds_sg.id
  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = data.aws_security_groups.eb_instance_sg.ids[0]
  description              = "Allow Postgres from allowed SG"
}

# Egress allow all
resource "aws_security_group_rule" "allow_all_egress" {
  security_group_id = aws_security_group.rds_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Configure the RDS instance using Postgres engine
resource "aws_db_instance" "main" {
  identifier             = "${var.db_name}-rds"
  engine                 = "postgres"
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  storage_type           = "gp2"
  db_name                = var.db_name
  port                   = var.db_port
  username               = var.db_username
  password               = local.db_password != "" ? local.db_password : var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = var.publicly_accessible
  multi_az               = var.multi_az
  skip_final_snapshot    = true
  apply_immediately      = true

  # Disable automated backups
  backup_retention_period = 0

  tags = {
    Name        = "${var.db_name}-rds"
    Environment = var.environment
  }
}
