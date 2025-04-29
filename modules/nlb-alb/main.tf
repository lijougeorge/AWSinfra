locals {
  environment = "uat"
  project     = "ihub"

  common_tags = {
    Project      = local.project
    Owner        = "EvidenDevOpsTeam"
    environments = local.environment
    ManagedBy    = "Terraform"
  }

  alb_name    = "${local.environment}-${local.project}-alb"
  alb_sg_name = "${local.environment}-${local.project}-alb-sg"
  alb_tg_name = "${local.environment}-${local.project}-alb-tg"

  nlb_name    = "${local.environment}-${local.project}-nlb"
  nlb_sg_name = "${local.environment}-${local.project}-nlb-sg"
  nlb_tg_name = "${local.environment}-${local.project}-nlb-tg"
}

resource "aws_security_group" "alb_sg" {
  name        = local.alb_sg_name
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = local.alb_sg_name
    },
    local.common_tags
  )
}

resource "aws_security_group" "nlb_sg" {
  name        = local.nlb_sg_name
  description = "Security group for NLB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = local.nlb_sg_name
    },
    local.common_tags
  )
}

resource "aws_lb" "alb" {
  name                       = local.alb_name
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = var.subnet_ids
  enable_deletion_protection = false

  tags = merge(
    {
      Name = local.alb_name
    },
    local.common_tags
  )
}

resource "aws_lb_target_group" "alb_tg" {
  name        = local.alb_tg_name
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = var.vpc_id
  target_type = "instance"

  tags = merge(
    {
      Name = local.alb_tg_name
    },
    local.common_tags
  )
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

resource "aws_lb" "nlb" {
  name                       = local.nlb_name
  internal                   = true
  load_balancer_type         = "network"
  security_groups            = [aws_security_group.nlb_sg.id]
  subnets                    = var.subnet_ids
  enable_deletion_protection = false

  tags = merge(
    {
      Name = local.nlb_name
    },
    local.common_tags
  )
}

resource "aws_lb_target_group" "nlb_tg" {
  name        = local.nlb_tg_name
  port        = 443
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "alb"

  tags = merge(
    {
      Name = local.nlb_tg_name
    },
    local.common_tags
  )
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "nlb_to_alb" {
  target_group_arn = aws_lb_target_group.nlb_tg.arn
  target_id        = aws_lb.alb.arn
}

