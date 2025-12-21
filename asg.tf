data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  # Autoscaling group
  name = "custodian-asg"

  min_size            = 1
  max_size            = 5
  desired_capacity    = 2
  vpc_zone_identifier = module.vpc.public_subnets

  # Launch template
  launch_template_name        = "example-asg"
  launch_template_description = "Launch template example"
  update_default_version      = true

  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Environment       = "dev"
    Project           = "offhours"
    Custodian         = "Present"
    ExtendedHours     = "on"
    CustodianOffHours = "Default"
  }
}