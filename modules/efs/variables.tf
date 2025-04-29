variable "vpc_id" {
  description = "VPC ID for the EFS"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for EKS"
  type        = list(string)
}

variable "efs_performance_mode" {
  description = "Performance mode of the EFS file system"
  type        = string
}

variable "efs_throughput_mode" {
  description = "Throughput mode of the EFS file system"
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g. dev, uat, prod)"
  type        = string
}
