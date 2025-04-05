module "alb" {
  source                     = "./modules/alb"
  prefix                     = var.prefix
  vpc_id                     = var.vpc_id
  internal                   = var.internal
  alb_subnets                = var.alb_subnets
  enable_deletion_protection = var.enable_deletion_protection
  access_logs_bucket         = var.access_logs_bucket
  access_logs_prefix         = var.access_logs_prefix
  aws_account_id             = var.aws_account_id
  target_group_name          = var.target_group_name
  target_group_port          = var.target_group_port
  health_check_path          = var.health_check_path
}

module "endpoint" {
  source          = "./modules/endpoint"
  vpc_id          = var.vpc_id
  region          = var.region
  subnet_ids      = var.subnet_ids
  route_table_ids = var.route_table_ids
  prefix          = var.prefix
}

module "eks" {
  source = "./modules/eks"
  Account_ID = var.Account_ID
  vpc_id = var.vpc_id
  prefix = var.prefix
  max_unavailable = var.max_unavailable
  cluster_name = var.cluster_name
  cluster_version = var.cluster_version
  subnet_ids = var.subnet_ids
  enable_cluster_log_types = var.enable_cluster_log_types
  desired_size = var.desired_size
  max_size = var.max_size
  min_size = var.min_size
}
