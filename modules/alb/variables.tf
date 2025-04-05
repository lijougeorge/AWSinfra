variable "prefix" {
  description = "Prefix for all the resouces"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to create the ALB"
  type        = string
}

variable "internal" {
  description = "Boolean indicating whether the ALB is internal"
  type        = bool
}

variable "alb_subnets" {
  description = "Subnet ID to the ALB"
  type        = list(string)
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
}

variable "access_logs_bucket" {
  description = "Access S3 bucket for ALB logging"
}

variable "access_logs_prefix" {
  description = "Prefix for the ALB logs"
}

variable "aws_account_id" {
  description = "AWS Account ID"
}

variable "target_group_name" {
  description = "Name of the Target Group"
  type        = string
}

variable "target_group_port" {
  description = "Port for the Target Group"
  type        = number
}

variable "health_check_path" {
  description = "Health check path for the Target Group"
  type        = string
}