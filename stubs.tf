data "aws_ami" "stubs_ami" {
  most_recent = true
  owners = ["self"]

  filter {
    name = "image-id"
    values = [var.ami_id]
  }
}

variable "instance_type" {
  type = string
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
  associate_public_ip_address = true
  key_name = var.key_pair_name
  tags = {
    Name = "${terraform.workspace} stubs"
    Env = terraform.workspace
    TerraformConfiguration = local.terraform_configuration
  }

  lifecycle {
    create_before_destroy = true
  }
}

