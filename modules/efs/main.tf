locals {
  environment = var.environment
  project     = "ihub"

  efs_name         = "${local.environment}-${local.project}-efs"
  efs_sg_name      = "${local.environment}-${local.project}-efs-sg"
  backup_plan      = "${local.environment}-${local.project}-efs-backup-plan"
  backup_vault     = "${local.environment}-${local.project}-efs-backup-vault"
  backup_selection = "${local.environment}-${local.project}-efs-backup-selection"

  common_tags = {
    Project     = local.project
    Environment = local.environment
    Owner       = "EvidenDevOpsTeam"
    ManagedBy   = "Terraform"
  }
}

resource "aws_security_group" "efs_sg" {
  name        = local.efs_sg_name
  description = "Security group for EFS access"
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
      Name = local.efs_sg_name
    },
    local.common_tags
  )
}

resource "aws_efs_file_system" "efs" {
  performance_mode = var.efs_performance_mode
  throughput_mode  = var.efs_throughput_mode
  encrypted        = true

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = merge(
    {
      Name = local.efs_name
    },
    local.common_tags
  )
}

resource "aws_efs_mount_target" "efs_mount_target" {
  for_each = toset(var.subnet_ids)

  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_backup_vault" "efs_backup_vault" {
  name = local.backup_vault

  tags = local.common_tags
}

resource "aws_backup_plan" "efs_backup_plan" {
  name = local.backup_plan

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.efs_backup_vault.name
    schedule          = "cron(0 1 * * ? *)"

    lifecycle {
      delete_after = 30
    }
  }

  tags = local.common_tags
}

resource "aws_backup_selection" "efs_backup_selection" {
  name         = local.backup_selection
  iam_role_arn = aws_iam_role.efs_role.arn
  plan_id      = aws_backup_plan.efs_backup_plan.id

  resources = [aws_efs_file_system.efs.arn]
}

resource "aws_iam_role" "efs_role" {
  name = "${local.environment}-${local.project}-efs-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "backup.amazonaws.com"
      }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "efs_backup_attachment" {
  role       = aws_iam_role.efs_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

