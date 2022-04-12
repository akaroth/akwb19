module "ec2_sg_cdc" {
  source             = "terraform-aws-modules/security-group/aws"
  version            = "4.3.0"
  name               = "ec2_sg_cdc"
  vpc_id             = aws_vpc.vpc.id
  egress_cidr_blocks = ["0.0.0.0/0"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "http"
      cidr_blocks = "10.1.0.0/16"
    },
  ]
}