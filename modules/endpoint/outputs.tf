output "ssm_endpoint_id" {
  description = "ID of the SSM VPC Interface Endpoint"
  value       = aws_vpc_endpoint.ssm.id
}

output "ec2_endpoint_id" {
  description = "ID of the EC2 VPC Interface Endpoint"
  value       = aws_vpc_endpoint.ec2.id
}

output "ssmmessages_endpoint_id" {
  description = "ID of the SSM Messages VPC Interface Endpoint"
  value       = aws_vpc_endpoint.ssmmessages.id
}

output "s3_endpoint_id" {
  description = "ID of the EC2 VPC Interface Endpoint"
  value       = aws_vpc_endpoint.s3_interface.id
}

output "s3_gateway_endpoint_id" {
  description = "ID of the S3 VPC Gateway Endpoint"
  value       = aws_vpc_endpoint.s3.id
}
