module "vpc" {
  source = "./modules/vpc"
  vpc-cidr-block = var.vpc-cidr-block
  environment = var.environment
  project-owner = var.project-owner
  subnet-index-public = var.subnet-index-public
  subnet-index-public-2 = var.subnet-index-public-2
  subnet-index-private = var.subnet-index-private
  subnet-index-private-2 = var.subnet-index-private-2
  availability-zone = var.availability-zone
  availability-zone-2 = var.availability-zone-2
}

module "security" {
  source = "./modules/security"
  vpc-id = module.vpc.vpc-id
  environment = var.environment
  project-owner = var.project-owner
}

module "iam" {
  source = "./modules/iam"
  environment = var.environment
  project-owner = var.project-owner
}

module "alb" {
  source = "./modules/alb"
  environment = var.environment
  project-owner = var.project-owner
  vpc-id = module.vpc.vpc-id
  alb-sg-id = module.security.alb-sg-id
  public-subnet-1 = module.vpc.public-subnet-1.id
  public-subnet-2 = module.vpc.public-subnet-2.id
}

module "ecs" {
  source = "./modules/ecs"
  environment = var.environment
  project-owner = var.project-owner
  aws-region = var.aws-region
  retention-in-days = var.retention-in-days
  ecs-task-cpu = var.ecs-task-cpu
  ecs-task-memory = var.ecs-task-memory
  ecs-execution-role-arn = module.iam.ecs-execution-role-arn
  ecs-task-role-arn = module.iam.ecs-task-role-arn
  django-container-image = var.django-container-image
  container-port = var.container-port
  desired-count = var.desired-count
  ecs-sg-id = module.security.ecs-sg-id
  private-subnet-1-id = module.vpc.private-subnet-1-id
  private-subnet-2-id = module.vpc.private-subnet-2-id
  alb-target-group-arn = module.alb.alb-target-group-arn
}
