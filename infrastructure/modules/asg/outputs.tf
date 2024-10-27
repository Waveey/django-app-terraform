# outputs.tf
output "asg_name" {
  description = "Name of the created Auto Scaling Group"
  value       = aws_autoscaling_group.main.name
}

output "asg_arn" {
  description = "ARN of the created Auto Scaling Group"
  value       = aws_autoscaling_group.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "ec2_security_group_id" {
  description = "Security group ID for EC2 instances"
  value       = aws_security_group.ec2.id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "instance_public_ips" {
  description = "Public IPs of the EC2 instances"
  value       = aws_autoscaling_group.main.*.instances[*].public_ip
}