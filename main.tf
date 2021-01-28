locals {
    terraform_configuration = ""
}

terraform {
    required_version = "0.14.5"
}

provider "aws" {
    region = var.region
    /*assume_role {
        role_arn = "arn:aws:iam::${var.account_id}:role/terraform-paylater-core"
        session_name = "terraform-paylater-core-aws-provider"
    }*/
    version = "~> 2.0"
}

