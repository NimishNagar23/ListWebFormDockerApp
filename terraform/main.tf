module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = "10.0.0.0/16"
}

module "security" {
  source = "./modules/security"

  project_name  = var.project_name
  vpc_id        = module.vpc.vpc_id
  s3_bucket_arn = "arn:aws:s3:::webpageimage-nimish-project"
}

module "database" {
  source = "./modules/database"

  project_name           = var.project_name
  vpc_security_group_ids = [module.security.db_sg_id]
  subnet_ids             = module.vpc.private_subnet_ids
  db_name                = "userdb"
  db_username            = "appuser"
  db_password            = "password"
}

module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment
}

module "ecs" {
  source = "./modules/ecs"

  project_name              = var.project_name
  environment               = var.environment
  vpc_id                    = module.vpc.vpc_id
  public_subnet_ids         = module.vpc.public_subnet_ids
  private_subnet_ids        = module.vpc.private_subnet_ids
  
  # Image URLs (Manual step required to build/push these)
  backend_image_url         = module.ecr.backend_repo_url
  frontend_image_url        = module.ecr.frontend_repo_url
  
  db_endpoint               = module.database.db_endpoint
  db_username               = "appuser"
  s3_bucket_name            = "webpageimage-nimish-project"
  aws_region                = var.aws_region
  
  # Wiring ALB to ECS
  alb_target_group_arn_backend  = module.alb.target_group_arn_backend
  alb_target_group_arn_frontend = module.alb.target_group_arn_frontend
  backend_security_group_id     = module.security.app_sg_id
}

module "alb" {
  source = "./modules/alb"

  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [module.security.alb_sg_id]
}
