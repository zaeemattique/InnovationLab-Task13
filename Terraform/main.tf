module "networking" {
  source = "./modules/networking"
  private_subnetA_cidr = var.private_subnetA_cidr
  private_subnetB_cidr = var.private_subnetB_cidr
  public_subnetA_cidr = var.public_subnetA_cidr
  public_subnetB_cidr = var.public_subnetB_cidr
  vpc_cidr = var.vpc_cidr
}

module "storage" {
  source = "./modules/storage"
  private_subnetA_id = module.networking.private_subnetA_id
  private_subnetB_id = module.networking.private_subnetB_id
  efs_security_group_id = module.networking.efs_sg_id
}

module "iam" {
  source = "./modules/iam"
  codepipeline_bucket = module.storage.codepipeline_bucket
  efs_arn = module.storage.efs_arn
}

module "loadbalancer" {
  source = "./modules/loadbalancer"
  vpc_id = module.networking.vpc_id
  public_subnetA_id = module.networking.public_subnetA_id
  public_subnetB_id = module.networking.public_subnetB_id
  alb_security_group_id = module.networking.alb_security_group_id
}

module "compute" {
  source = "./modules/compute"
  instance_security_group_id = module.networking.instance_security_group_id
  public_subnetA_id = module.networking.public_subnetA_id
  public_subnetB_id = module.networking.public_subnetB_id
  ecs_instance_profile_name = module.iam.ecs_instance_profile_name
}

module "ecs" {
  source = "./modules/ecs"
  public_subnetA_id = module.networking.public_subnetA_id
  public_subnetB_id = module.networking.public_subnetB_id
  task_role_arn = module.iam.task_role_arn
  exec_role_arn = module.iam.exec_role_arn
  target_group_arn = module.loadbalancer.tg_arn
  instance_security_group_id = module.networking.instance_security_group_id
  asg_arn = module.compute.asg_arn
  efs_ap_id = module.storage.efs_ap_id
  efs_id = module.storage.efs_id
  image_tag = var.image_tag
}

