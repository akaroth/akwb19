data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
module "ec2_instance" {
source  = "terraform-aws-modules/ec2-instance/aws"
version = "~> 3.0"

name = "cdc"

ami                    = data.aws_ami.ubuntu.id
instance_type          = var.instance-type
key_name               = var.key_name
vpc_security_group_ids = [module.ec2_sg_cdc.security_group_id]
subnet_id              = element(aws_subnet.public_subnet.*.id, 0)
iam_instance_profile   = aws_iam_instance_profile.cdc_profile.name
user_data              = file("init.sh")
tags = {
    Terraform = "true"
  }
}