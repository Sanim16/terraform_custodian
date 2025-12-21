data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

locals {
  name    = var.name
  region  = "us-east-1"
  region2 = "us-west-2"

  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-rds"
  }
}

# Create VPC using a module
module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=c182453f881ae77afd14c826dc8e23498b957907" # commit hash of version 5.7.1

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs              = local.azs
  public_subnets   = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]
  private_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 3)]
  database_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 6)]

  create_database_subnet_group = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_dns_hostnames   = true
  one_nat_gateway_per_az = false

  map_public_ip_on_launch = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name        = var.vpc_name
    Application = var.name
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = local.name
  description = "Custodian example security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = local.tags
}
