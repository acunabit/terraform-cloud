data "aws_ami" "stubs_ami" {
  most_recent = true
  owners = ["568431661506"]

  filter {
    name = "image-id"
    values = [var.ami_id]
  }
}

resource "aws_security_group" "stubs_sg" {
  name = "${terraform.workspace}-stubs-sg"
  description = "${terraform.workspace} stubs sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "${terraform.workspace}-stubs-sg"
    Env = terraform.workspace
  }
}


resource "aws_security_group_rule" "stubs_egress_sg_rule" {
  type = "egress"
  from_port = 0
  to_port = 65534
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.stubs_sg.id
}

resource "aws_instance" "stubs" {
  ami = data.aws_ami.stubs_ami.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.stubs_sg.id]
  subnet_id = var.subnet_id
  associate_public_ip_address = false
  key_name = var.key_pair_name
  tags = {
    Name = "${terraform.workspace} stubs tech-pod"
    Env = terraform.workspace
    TerraformConfiguration = local.terraform_configuration
  }

  lifecycle {
    create_before_destroy = true
  }
}

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
  db_ingress_cidr_blocks = [
    data.aws_subnet.primary_dmz_subnets.*.cidr_block,
    data.aws_subnet.primary_core_subnets.*.cidr_block,
    data.aws_subnet.primary_bastion_subnet.cidr_block,
    "172.31.0.0/16"
//    data.aws_subnet.secondary_dmz_subnets.*.cidr_block,
//    data.aws_subnet.secondary_core_subnets.*.cidr_block,
//    data.aws_subnet.secondary_bastion_subnet.cidr_block
  ]
  iam_database_authentication_enabled = false
  # The cluster name will follow this convention -> environment-identifier-db
  identifier = "k8stest"
  instance_class = "db.t3.medium"
  #instance_count = 1
  internal_hosted_zone_id = data.terraform_remote_state.network.outputs.internal_hosted_zone_id
  monitoring_interval = 0
  preferred_backup_window = "17:00-18:00"
  preferred_maintenance_window = "wed:16:00-wed:16:30"
  primary_subnet_ids = data.terraform_remote_state.network.outputs.data_subnet_ids
  primary_vpc_cidr = data.terraform_remote_state.network.outputs.vpc_cidr
  primary_vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  region = data.terraform_remote_state.network.outputs.region
  secondary_subnet_ids = ["subnet-60e1de26"] //data.terraform_remote_state.network_secondary.outputs.data_subnet_ids
  secondary_vpc_cidr = "172.31.0.0/16" //data.terraform_remote_state.network_secondary.outputs.vpc_cidr
  secondary_vpc_id = "vpc-99edb9fd" //data.terraform_remote_state.network_secondary.outputs.vpc_id
  sns_info_topic_arn = data.terraform_remote_state.monitoring.outputs.paylater_core_info_sns_topic_arn
  sns_critical_topic_arn = data.terraform_remote_state.monitoring.outputs.paylater_core_critical_sns_topic_arn  
  terraform_configuration = "paylater-containers"
  terraform_role_name = "terraform-paylater-deploynow-ecs"
}
