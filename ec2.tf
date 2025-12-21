module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  for_each = toset(["one", "two", "three"])

  name = "instance-${each.key}"

  instance_type = "t2.micro"
  subnet_id     = module.vpc.public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "ec2_instance_tagged_extended" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "single-instance"

  instance_type = "t2.micro"
  subnet_id     = module.vpc.public_subnets[1]

  tags = {
    Terraform         = "true"
    Environment       = "dev"
    Custodian         = "Present"
    CustodianOffHours = "Extended hours"
  }
}

module "ec2_instance_tagged_default" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "single-instance"

  instance_type = "t2.micro"
  subnet_id     = module.vpc.public_subnets[1]

  tags = {
    Terraform         = "true"
    Environment       = "dev"
    Custodian         = "Present"
    CustodianOffHours = "Default"
  }
}
