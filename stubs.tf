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
  to_port = 65535
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
  source = "git@github.com:AfterpayTouch/afterpay-terraform-modules.git//database"
  
  state_bucket = "afterpay.alpha2.tfstate"
  environment = "k8s"

  account_id = var.account_id
  account_name = var.account_name
  application_role_arn = "arn:aws:iam::${var.account_id}:role/paylaterEcsFargateTaskExecutionRole"
  application_user = "testuser"
  # MySQL host (i.e. route53 dns entry)
  cname = "k8s-test-db"
  database_name = "k8s-test"
  iam_database_authentication_enabled = false
  # The cluster name will follow this convention -> environment-identifier-db
  identifier = "k8s-test"
  instance_class = "db.t3.small"
  instance_count = 1
  monitoring_interval = 0
  preferred_backup_window = "17:00-18:00"
  preferred_maintenance_window = "wed:16:00-wed:16:30"
  terraform_configuration = "paylater-containers"
  terraform_role_name = "terraform-paylater-deploynow-ecs"
}
