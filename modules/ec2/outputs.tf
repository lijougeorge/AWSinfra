output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = aws_instance.linux_server[*].id
}

output "instance_private_ips" {
  description = "The private IP addresses of the EC2 instances"
  value       = aws_instance.linux_server[*].private_ip
}