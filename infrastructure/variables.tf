variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

# variable "environment" {
#   description = "Environment name"
#   type        = string
# }

# variable "vpc_id" {
#   description = "ID of the VPC"
#   type        = string
# }

# variable "public_subnet_ids" {
#   description = "List of public subnet IDs"
#   type        = list(string)
# }

variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_username" {
  description = "Database master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "instance_type" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"
}

# variable "ec2_security_group_id" {
#   description = "Security group ID of EC2 instances"
#   type        = string
# }

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "admin_cidr_blocks" {
  description = "CIDR blocks allowed for SSH access"
  type        = string
  default     = "0.0.0.0" # Change this to your admin IP range
}

variable "iam_instance_profile" {
  description = "Name of the IAM instance profile"
  type        = string
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

variable "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  type        = string
}