variable "environment" {
  description = "Environment name"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "ec2_role_name" {
  description = "Name of the EC2 IAM role"
  type        = string
}