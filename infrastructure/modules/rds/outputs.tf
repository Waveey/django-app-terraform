output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.main.port
}

output "rds_security_group_id" {
  description = "Security group ID of the RDS instance"
  value       = aws_security_group.rds.id
}