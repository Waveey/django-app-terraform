variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "desired_capacity" {
  description = "Desired number of EC2 instances"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of EC2 instances"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of EC2 instances"
  type        = number
  default     = 4
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "iam_instance_profile" {
  description = "Name of the IAM instance profile"
  type        = string
}

variable "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  type        = string
}

variable "admin_cidr_blocks" {
  description = "CIDR blocks allowed for SSH access"
  type        = string
}


