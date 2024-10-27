resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.public_subnet_ids  # Changed to public subnets only

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  # Allow access from anywhere (use cautiously)
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Consider restricting this to specific IPs for better security
  }

  # Allow access from EC2 security group
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.ec2_security_group_id]  # Correctly reference the EC2 security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # You can restrict this as needed
  }

  tags = {
    Name        = "${var.environment}-rds-sg"
    Environment = var.environment
  }
}
resource "aws_db_instance" "main" {
  identifier           = "${var.environment}-postgres"
  engine              = "postgres"
  engine_version      = "16.3"  # Updated version
  instance_class      = "db.t4g.micro"
  allocated_storage   = 20
  storage_type        = "gp3"   # Updated to GP3
  storage_encrypted   = true
  
  db_name             = var.db_name
  username            = var.db_username
  password            = var.db_password
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  publicly_accessible    = true  # Changed to false for security
  skip_final_snapshot    = true  # Changed to false
  final_snapshot_identifier = "${var.environment}-db-final-snapshot"


  tags = {
    Name        = "${var.environment}-postgres"
    Environment = var.environment
  }
}