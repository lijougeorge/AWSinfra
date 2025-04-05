resource "aws_security_group" "endpoint_sg" {
  name        = "${var.prefix}-endpoint-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.166.44.0/22"]
    description = "Allow HTTP Rule"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  tags = {
    Name = "${var.prefix}-endpoint-sg"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
  ip_address_type     = "ipv4"
  tags = {
    Name = "${var.prefix}-ssm-endpoint"
  }
  policy = <<POLICY
  {
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "*",
        "Resource": "*"
      }
    ]
  }
  POLICY
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
  ip_address_type     = "ipv4"
  tags = {
    Name = "${var.prefix}-ssmmessages-endpoint"
  }
  policy = <<POLICY
  {
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "*",
        "Resource": "*"
      }
    ]
  }
  POLICY
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
  ip_address_type     = "ipv4"
  tags = {
    Name = "${var.prefix}-ec2-endpoint"
  }
  policy = <<POLICY
  {
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "*",
        "Resource": "*"
      }
    ]
  }
  POLICY
}

resource "aws_vpc_endpoint" "s3_interface" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
  ip_address_type     = "ipv4"
  tags = {
    Name = "${var.prefix}-s3-endpoint"
  }
  policy = <<POLICY
  {
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "*",
        "Resource": "*"
      }
    ]
  }
  POLICY
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_table_ids
  tags = {
    Name = "${var.prefix}-s3-endpoint"
  }
  policy = <<POLICY
  {
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "*",
        "Resource": "*"
      }
    ]
  }
  POLICY
}

