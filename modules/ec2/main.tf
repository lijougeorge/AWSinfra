locals {
  environment = var.environment
  project     = "dalim"
  os_type     = lower(var.os_type)

  common_tags = {
    Project     = local.project
    Owner       = "EvidenDevOpsTeam"
    Environment = local.environment
  }

  ec2_name_prefix   = "${local.environment}-${local.project}-ec2"
  ec2_sg_name       = "${local.environment}-${local.project}-ec2-sg"
  ec2_ebs_root_name = "${local.environment}-${local.project}-ec2-root-volume"
  ec2_ebs_data_name = "${local.environment}-${local.project}-ec2-data-volume"
  ec2_role_name     = "${local.environment}-${local.project}-ec2-role"
  ec2_profile_name  = "${local.environment}-${local.project}-ec2-instance-profile"
  ebs_device_name   = local.os_type == "windows" ? "xvdf" : "/dev/xvdf"
  user_data_file    = local.os_type == "windows" ? "${path.module}/user_script/windows_setup.ps1" : "${path.module}/user_script/linux_setup.sh"
}

data "aws_ami" "ec2_ami" {
  most_recent = true
  owners      = ["amazon"]

  dynamic "filter" {
    for_each = local.os_type == "windows" ? [1] : []
    content {
      name   = "name"
      values = ["Windows_Server-2022-English-Full-Base-*"]
    }
  }

  dynamic "filter" {
    for_each = local.os_type == "amz2" ? [1] : []
    content {
      name   = "name"
      values = ["amzn2-ami-hvm*"]
    }
  }

  dynamic "filter" {
    for_each = local.os_type == "al2023" ? [1] : []
    content {
      name   = "name"
      values = ["al2023-ami-*-x86_64"]
    }
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = local.ec2_profile_name
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role" "ec2_role" {
  name = local.ec2_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_security_group" "ec2_sg" {
  name        = local.ec2_sg_name
  description = "Security group for EC2 access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "Allow NFS traffic from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    {
      Name = local.ec2_sg_name
    },
    local.common_tags
  )
}

resource "aws_instance" "linux_server" {
  count                  = length(var.server_name)
  ami                    = data.aws_ami.ec2_ami.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.ec2_key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  private_ip = length(var.private_ips) > 0 ? var.private_ips[count.index] : null
  ebs_optimized = true

  root_block_device {
    volume_size           = var.root_block_device.volume_size
    volume_type           = var.root_block_device.volume_type
    throughput            = var.root_block_device.throughput
    encrypted             = true
    delete_on_termination = var.root_block_device.delete_on_termination
  }

  ebs_block_device {
    device_name           = local.ebs_device_name
    volume_size           = var.persistent_block_device.volume_size
    volume_type           = var.persistent_block_device.volume_type
    throughput            = var.persistent_block_device.throughput
    encrypted             = true
    delete_on_termination = var.persistent_block_device.delete_on_termination
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.ec2_name_prefix}-${count.index + 1}-${var.server_name[count.index]}"
    }
  )

  user_data = file(local.user_data_file)

  lifecycle {
    ignore_changes = [user_data]
  }
}
