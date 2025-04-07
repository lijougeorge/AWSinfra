locals {
  common_tags = {
    Environment = "uat"
    Project     = "ihub"
    Owner       = "EvidenDevOpsTeam"
  }
}

resource "aws_security_group" "eks_sg" {
  name        = "${var.prefix}-eks-sg-uat-ihub-cluster-ControlPlaneSecurityGroup"
  description = "EKS Security Group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge({
    Name = "${var.prefix}-eks-sg"
  }, local.common_tags)
}

resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-${var.cluster_name}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids           = var.subnet_ids
    security_group_ids   = [aws_security_group.eks_sg.id]
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.eks_secrets.arn
    }
  }

  enabled_cluster_log_types = var.enable_cluster_log_types

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  tags = merge({
    Name = var.cluster_name
  }, local.common_tags)

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

resource "aws_kms_key" "eks_secrets" {
  description             = "KMS key for EKS secrets encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge({
    Name = "eks-secrets-kms-key"
  }, local.common_tags)
}

resource "aws_kms_alias" "eks_secrets_alias" {
  name          = "alias/eks-secrets"
  target_key_id = aws_kms_key.eks_secrets.key_id
}

resource "aws_eks_access_entry" "devops_admin_access" {
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = "arn:aws:iam::232247293372:role/Eviden-DSS-Automation"
  type          = "STANDARD"
}

resource "aws_iam_role" "eks_worker_nodes" {
  name = "eks-node-group-nodes"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "nodes_worker_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_worker_nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_worker_nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes_ec2_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_worker_nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes_ssm_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_worker_nodes.name
}

resource "aws_launch_template" "eks_nodes" {
  name_prefix   = "${var.cluster_name}-nodes"
  description   = "Launch template for EKS managed nodes"
  instance_type = "m5.xlarge"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 200
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  ebs_optimized = true

  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "required"
    instance_metadata_tags = "enabled"
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge({
      Name = "${var.cluster_name}-eks-node"
    }, local.common_tags)
  }

  tag_specifications {
    resource_type = "volume"

    tags = local.common_tags
  }

  tags = local.common_tags
}

resource "aws_eks_node_group" "managed_nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster_name}-managed-nodes"
  node_role_arn   = aws_iam_role.eks_worker_nodes.arn
  subnet_ids      = var.subnet_ids

  capacity_type = "ON_DEMAND"
  ami_type      = "AL2023_x86_64_STANDARD"

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = var.max_unavailable
  }

  labels = {
    role = "workers"
  }

  tags = merge({
    Name = "${var.cluster_name}-managed-nodes"
  }, local.common_tags)

  depends_on = [
    aws_iam_role_policy_attachment.nodes_worker_policy,
    aws_iam_role_policy_attachment.nodes_cni_policy,
    aws_iam_role_policy_attachment.nodes_ec2_registry_policy,
    aws_iam_role_policy_attachment.nodes_ssm_policy,
  ]
}
