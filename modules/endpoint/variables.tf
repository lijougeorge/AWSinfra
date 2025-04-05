variable "vpc_id" {
  description = "VPC ID where the endpoints will be created"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "subnet_ids" {
  description = "List of Subnet IDs where the endpoints will be created"
  type        = list(string)
}

variable "route_table_ids" {
  description = "List of Subnet IDs where the endpoints will be created"
  type        = list(string)
}

variable "prefix" {
  description = "Prefix for naming resources"
  type        = string
}
