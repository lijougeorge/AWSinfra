resource "aws_security_group" "alb_sg" {
  name        = "${var.prefix}-alb-sg"
  description = "Application LoadBalancer Security Groups"
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
    Name = "${var.prefix}-alb-sg"
  }
}

resource "aws_lb" "alb" {
  name                       = "${var.prefix}-PA-DAL-ALB"
  internal                   = var.internal
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = var.alb_subnets
  enable_deletion_protection = var.enable_deletion_protection
  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    prefix  = var.access_logs_prefix
    enabled = true
  }
  tags = {
    Name = "${var.prefix}-PA-DAL-ALB"
  }
}

resource "aws_s3_bucket" "alb_logs" {
  bucket = "my-prod-alb-logs-992382407348"
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_ownership_controls" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_lb_target_group" "alb_tg" {
  name     = var.target_group_name
  port     = var.target_group_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    interval            = 30
    path                = var.health_check_path
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

resource "aws_s3_bucket_policy" "alb_logs_policy" {
  bucket = "my-prod-alb-logs-992382407348"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "elasticloadbalancing.amazonaws.com"
        }
        Action = [
          "s3:PutObject",
          "s3:GetBucketAcl"
        ]
        Resource = "arn:aws:s3:::my-prod-alb-logs-992382407348/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = "YOUR_AWS_ACCOUNT_ID"
          }
        }
      }
    ]
  })
}
