resource "random_integer" "random_id" {
    max = 2
    min = 0
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "devops-challenge"
  cidr = local.cidr_block
  azs               = local.azs
  private_subnets   = [for k, v in local.azs : cidrsubnet(local.cidr_block, 8, k)]
  public_subnets    = [for k, v in local.azs : cidrsubnet(local.cidr_block, 8, k + 48)]

  tags = local.common_tags
}

module "security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "devops-challenge"
  description = "Security group, allows 80 y 443 ports"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow Port 80"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow Port 443"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  tags = local.common_tags
}


module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "devops-single-instance-${terraform.workspace}"

  instance_type          = "t2.micro"
  monitoring             = true
  vpc_security_group_ids = [module.security_group.security_group_id]
  availability_zone      = element(module.vpc.azs, 0)
  subnet_id              = element(module.vpc.private_subnets, 0)

  user_data_base64       = base64encode(local.user_data)
  tags = local.common_tags
}