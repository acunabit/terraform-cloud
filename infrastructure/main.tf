locals {
    terraform_configuration = ""
}

terraform {
    required_version = "0.14.5"
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
    session_name = "terraform-${var.identifier}-remote-state-network"
  }
}

data "terraform_remote_state" "network_secondary" {
  backend = "s3"
  workspace = var.environment
  config = {
    bucket = var.state_bucket
    key = local.network_key
    encrypt = true
    dynamodb_table = "terraformstatelock"
    region = "ap-southeast-1"
    role_arn = "arn:aws:iam::${var.account_id}:role/terraform-state-manager"
    session_name = "terraform-${var.identifier}-remote-state-network"
  }
}

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

data "aws_subnet" "dmz_subnets" {
  count = var.global ? 0 : length(data.terraform_remote_state.network.outputs.dmz_subnet_ids)
  id = data.terraform_remote_state.network.outputs.dmz_subnet_ids[count.index]
}

data "aws_subnet" "core_subnets" {
  count = length(data.terraform_remote_state.network.outputs.core_subnet_ids)
  id = data.terraform_remote_state.network.outputs.core_subnet_ids[count.index]
}

data "aws_subnet" "bastion_subnet" {
  id = data.terraform_remote_state.network.outputs.bastion_subnet_id
}
