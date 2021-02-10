
module "test_mysql" {
  source = "git@github.com:AfterpayTouch/afterpay-terraform-modules.git//global-database?ref=CLDP-395"

  state_bucket = "afterpay.${var.account_name}.tfstate"
  environment = "dev"

  account_id = var.account_id
  account_name = var.account_name
  application_role_arn = "arn:aws:iam::${var.account_id}:role/paylaterEcsFargateTaskExecutionRole"
  application_user = "testuser"
  # MySQL host (i.e. route53 dns entry)
  cname = "k8s-test-db"
  database_name = "k8stest"
  db_ingress_cidr_blocks = flatten([
    data.aws_subnet.primary_core_subnets.*.cidr_block,
    data.aws_subnet.primary_bastion_subnet.cidr_block,
    data.aws_subnet.primary_dmz_subnets.*.cidr_block,
    "172.31.0.0/16"
//    data.aws_subnet.secondary_dmz_subnets.*.cidr_block,
//    data.aws_subnet.secondary_core_subnets.*.cidr_block,
//    data.aws_subnet.secondary_bastion_subnet.cidr_block
  ])
  iam_database_authentication_enabled = true
  # The cluster name will follow this convention -> environment-identifier-db
  identifier = "k8stest"
  instance_class = "db.r5.large"
  internal_hosted_zone_id = data.terraform_remote_state.network.outputs.internal_hosted_zone_id
  lambda_subnet_ids = data.terraform_remote_state.network.outputs.core_subnet_ids
  preferred_backup_window = "17:00-18:00"
  preferred_maintenance_window = "wed:16:00-wed:16:30"
  primary_subnet_ids = data.terraform_remote_state.network.outputs.data_subnet_ids
  primary_vpc_cidr = data.terraform_remote_state.network.outputs.vpc_cidr
  primary_vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  primary_instance_count = 0
  region = data.terraform_remote_state.network.outputs.region
  secondary_subnet_ids = ["subnet-60e1de26", "subnet-c1b7b5b7", "subnet-49cad32d"] //data.terraform_remote_state.network_secondary.outputs.data_subnet_ids
  secondary_vpc_cidr = "172.31.0.0/16" //data.terraform_remote_state.network_secondary.outputs.vpc_cidr
  secondary_vpc_id = "vpc-99edb9fd" //data.terraform_remote_state.network_secondary.outputs.vpc_id
  secondary_instance_class = "db.r5.large"
  secondary_instance_count = 0
  primary_upgraded_instance_count = 1
  upgraded_secondary_instance_count = 1
  upgraded_instance_class = "db.r5.xlarge"
  upgraded_promotion_tier = 1
  sns_info_topic_arn = data.terraform_remote_state.monitoring.outputs.paylater_core_info_sns_topic_arn
  sns_critical_topic_arn = data.terraform_remote_state.monitoring.outputs.paylater_core_critical_sns_topic_arn
  terraform_configuration = "paylater-containers"
  terraform_role_name = "terraform-paylater-deploynow-ecs"
}

//module "test_postgres" {
//  source = "git@github.com:AfterpayTouch/afterpay-terraform-modules.git//global-database?ref=CLDP-395"
//
//  state_bucket = "afterpay.${var.account_name}.tfstate"
//  environment = "dev"
//
//  account_id = var.account_id
//  account_name = var.account_name
//  application_role_arn = "arn:aws:iam::${var.account_id}:role/paylaterEcsFargateTaskExecutionRole"
//  application_user = "testuser"
//  # MySQL host (i.e. route53 dns entry)
//  cname = "k8s-test-db2"
//  database_name = "k8stestpg"
//  db_ingress_cidr_blocks = flatten([
//    data.aws_subnet.primary_core_subnets.*.cidr_block,
//    data.aws_subnet.primary_bastion_subnet.cidr_block,
//    data.aws_subnet.primary_dmz_subnets.*.cidr_block,
//    "172.31.0.0/16"
//    //    data.aws_subnet.secondary_dmz_subnets.*.cidr_block,
//    //    data.aws_subnet.secondgggary_core_subnets.*.cidr_block,
//    //    data.aws_subnet.secondary_bastion_subnet.cidr_block
//  ])
//  iam_database_authentication_enabled = false
//  # The cluster name will follow this convention -> environment-identifier-db
//  identifier = "k8stest2"
//  instance_class = "db.r5.large"
//  internal_hosted_zone_id = data.terraform_remote_state.network.outputs.internal_hosted_zone_id
//  lambda_subnet_ids = data.terraform_remote_state.network.outputs.core_subnet_ids
//  preferred_backup_window = "17:00-18:00"
//  preferred_maintenance_window = "wed:16:00-wed:16:30"
//  primary_subnet_ids = data.terraform_remote_state.network.outputs.data_subnet_ids
//  primary_vpc_cidr = data.terraform_remote_state.network.outputs.vpc_cidr
//  primary_vpc_id = data.terraform_remote_state.network.outputs.vpc_id
//  primary_instance_count = 1
//  region = data.terraform_remote_state.network.outputs.region
//  secondary_subnet_ids = ["subnet-60e1de26", "subnet-c1b7b5b7", "subnet-49cad32d"] //data.terraform_remote_state.network_secondary.outputs.data_subnet_ids
//  secondary_vpc_cidr = "172.31.0.0/16" //data.terraform_remote_state.network_secondary.outputs.vpc_cidr
//  secondary_vpc_id = "vpc-99edb9fd" //data.terraform_remote_state.network_secondary.outputs.vpc_id
//  secondary_instance_class = "db.r5.large"
//  secondary_instance_count = 1
//  sns_info_topic_arn = data.terraform_remote_state.monitoring.outputs.paylater_core_info_sns_topic_arn
//  sns_critical_topic_arn = data.terraform_remote_state.monitoring.outputs.paylater_core_critical_sns_topic_arn
//  terraform_configuration = "paylater-containers"
//  terraform_role_name = "terraform-paylater-deploynow-ecs"
//  postgres_enabled = true
//}
