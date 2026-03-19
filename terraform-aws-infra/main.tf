# =============================================================================
# Root Module: terraform-aws-infra
# =============================================================================
# This is the root configuration that wires all modules together to provision
# the complete AWS infrastructure for the Django deployment.
#
# Modules called:
#   - vpc      — core networking (VPC, subnets, IGW, NAT Gateways, route tables)
#   - security — security groups for ALB and ECS
#   - iam      — IAM roles and policies for ECS execution and task roles
#   - alb      — Application Load Balancer, target group, and listener
#   - ecs      — ECS cluster, task definition, service, and CloudWatch log group
#
# Module dependency chain:
#   vpc → security → alb → ecs
#   vpc → ecs
#   iam → ecs
#
# Remote state:
#   Stored in S3 bucket: django-deployment-state-bucket-terraform
#   State locking via DynamoDB: django-deployment-terraform-lock-table
#
# Usage:
#   terraform init
#   terraform plan
#   terraform apply
#
# Note:
#   django-container-image must be supplied at apply time by the CI/CD pipeline.
#   Do not hardcode the image URI in terraform.tfvars.
# =============================================================================

# Terraform configuration for AWS infrastructure
# Mapping vpc module variables to main.tf variables
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

# Mapping security module variables to main.tf variables
module "security" {
  source = "./modules/security"
  vpc-id = module.vpc.vpc-id
  environment = var.environment
  project-owner = var.project-owner
}

# Mapping iam module variables to main.tf variables
module "iam" {
  source = "./modules/iam"
  environment = var.environment
  project-owner = var.project-owner
  github-repo = var.github-repo
}

# Mapping alb module variables to main.tf variables
module "alb" {
  source = "./modules/alb"
  environment = var.environment
  project-owner = var.project-owner
  vpc-id = module.vpc.vpc-id
  alb-sg-id = module.security.alb-sg-id
  public-subnet-1 = module.vpc.public-subnet-1-id
  public-subnet-2 = module.vpc.public-subnet-2-id
}

# Mapping ecs module variables to main.tf variables
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

module "secrets" {
  source = "./modules/secrets"
  environment = var.environment
  project-owner = var.project-owner
  django-secret-key = var.django-secret-key
}