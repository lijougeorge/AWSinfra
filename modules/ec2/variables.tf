variable "server_name" {
  description = "Name of the EC2 instance"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the EC2"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID of the VPC"
  type        = string
}

variable "root_block_device" {
  description = "Root block device configuration"
  type = object({
    volume_size           = number
    volume_type           = string
    throughput            = optional(number)
    delete_on_termination = bool
  })
}

variable "persistent_block_device" {
  description = "Persistent block device configuration"
  type = object({
    volume_size           = number
    volume_type           = string
    throughput            = optional(number)
    delete_on_termination = bool
  })
}

variable "ec2_key_name" {
  description = "Key Pair of the EC2 Instance"
  type        = string
}

variable "prefix" {
  description = "Prefix for all the resouces"
  type        = string
}

variable "private_ips" {
  description = "List of private IPs to assign to the EC2 instances"
  type        = list(string)
}

variable "environment" {
  description = "The deployment environment (e.g. dev, uat, prod)"
  type        = string
}

variable "os_type" {
  description = "Operating system type: windows, amz2, al2023"
  type        = string
  validation {
    condition     = contains(["windows", "amz2", "al2023"], lower(var.os_type))
    error_message = "Allowed values for os_type are 'windows', 'amz2', 'al2023'."
  }
}