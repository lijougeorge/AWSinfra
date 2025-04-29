variable "vpc_id" {
  description = "VPC ID for the EFS"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for EKS"
  type        = list(string)
}