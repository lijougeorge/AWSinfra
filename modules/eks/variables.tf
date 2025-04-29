variable "max_unavailable" {
  description = "The maximum number of nodes that can be unavailable during an update"
  type        = number
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for EKS"
  type        = list(string)
}

variable "enable_cluster_log_types" {
  description = "Enable Cluster Logs"
  type        = list(string)
}

variable "desired_size" {
  description = "The desired number of nodes for the EKS node group"
  type        = number
}

variable "max_size" {
  description = "The maximum number of nodes for the EKS node group"
  type        = number
}

variable "min_size" {
  description = "The minimum number of nodes for the EKS node group"
  type        = number
}

variable "Account_ID" {
  description = "AWS Account ID"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "iam_roles" {
  description = "List of IAM role ARNs to grant EKS access"
  type        = list(string)
}

variable "environment" {
  description = "The deployment environment (e.g. dev, uat, prod)"
  type        = string
}