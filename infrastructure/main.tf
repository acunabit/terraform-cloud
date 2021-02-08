locals {
    terraform_configuration = ""
    network_key = "network/network.tfstate"
    bastion_key = "bastion/bastion.tfstate"
}

terraform {
    required_version = "0.14.6"
}

provider "aws" {
    region = var.region
    assume_role {
        role_arn = "arn:aws:iam::${var.account_id}:role/terraform-paylater-deploynow-ecs"
        session_name = "terraform-cloud-aws-provider"
    }
    version = "~> 2.0"
}

data "terraform_remote_state" "network" {
  backend = "s3"
  workspace = var.environment
  config = {
    bucket = var.state_bucket
    key = local.network_key
    encrypt = true
    dynamodb_table = "terraformstatelock"
    region = "ap-southeast-2"
    role_arn = "arn:aws:iam::${var.account_id}:role/terraform-state-manager"
    session_name = "terraform-remote-state-network"
  }
}

//data "terraform_remote_state" "network_secondary" {
//  backend = "s3"
//  workspace = var.environment
//  config = {
//    bucket = var.state_bucket
//    key = local.network_key
//    encrypt = true
//    dynamodb_table = "terraformstatelock"
//    region = "ap-southeast-1"
//    role_arn = "arn:aws:iam::${var.account_id}:role/terraform-state-manager"
//    session_name = "terraform-remote-state-network"
//  }
//}

data "terraform_remote_state" "bastion" {
  backend = "s3"
  workspace = var.environment
  config = {
    bucket = var.state_bucket
    key = local.bastion_key
    encrypt = true
    dynamodb_table = "terraformstatelock"
    region = "ap-southeast-2"
    role_arn = "arn:aws:iam::${var.account_id}:role/terraform-state-manager"
    session_name = "terraform-databases-remote-state-bastion"
  }
}

data "terraform_remote_state" "monitoring" {
  backend = "s3"
  workspace = var.environment
  config = {
    bucket = var.state_bucket
    key = "monitoring/monitoring.tfstate"
    encrypt = true
    dynamodb_table = "terraformstatelock"
    region = "ap-southeast-2"
    role_arn = "arn:aws:iam::${var.account_id}:role/terraform-state-manager"
    session_name = "terraform-databases-remote-state-monitoring"
  }
}

data "aws_subnet" "primary_dmz_subnets" {
  count = length(data.terraform_remote_state.network.outputs.dmz_subnet_ids)
  id = data.terraform_remote_state.network.outputs.dmz_subnet_ids[count.index]
}

data "aws_subnet" "primary_core_subnets" {
  count = length(data.terraform_remote_state.network.outputs.core_subnet_ids)
  id = data.terraform_remote_state.network.outputs.core_subnet_ids[count.index]
}

data "aws_subnet" "primary_bastion_subnet" {
  id = data.terraform_remote_state.network.outputs.bastion_subnet_id
}

//data "aws_subnet" "secondary_dmz_subnets" {
//  count = length(data.terraform_remote_state.network_secondary.outputs.dmz_subnet_ids)
//  id = data.terraform_remote_state.network_secondary.outputs.dmz_subnet_ids[count.index]
//}
//
//data "aws_subnet" "secondary_core_subnets" {
//  count = length(data.terraform_remote_state.network_secondary.outputs.core_subnet_ids)
//  id = data.terraform_remote_state.network_secondary.outputs.core_subnet_ids[count.index]
//}
//
//data "aws_subnet" "secondary_bastion_subnet" {
//  id = data.terraform_remote_state.network_secondary.outputs.bastion_subnet_id
//}
